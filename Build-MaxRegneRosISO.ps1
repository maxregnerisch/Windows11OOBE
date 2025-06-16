# MaxRegneRos Windows 11 ISO Builder Script
# This script automates the process of creating a custom Windows 11 ISO with MaxRegneRos OOBE

param(
    [Parameter(Mandatory=$true)]
    [string]$SourceISO,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputISO = "C:\MaxRegneRos_Windows11.iso",
    
    [Parameter(Mandatory=$false)]
    [string]$WorkDir = "C:\MaxRegneRos_Build",
    
    [Parameter(Mandatory=$false)]
    [string]$OOBESourceDir = ".",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipDownload,
    
    [Parameter(Mandatory=$false)]
    [switch]$TestMode
)

# Requires Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script requires Administrator privileges. Please run as Administrator."
    exit 1
}

# Function to write colored output
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

# Function to check if required tools are installed
function Test-RequiredTools {
    Write-ColorOutput "🔍 Checking required tools..." "Cyan"
    
    # Check for DISM
    try {
        $dismVersion = dism /? 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ DISM found" "Green"
        } else {
            throw "DISM not found"
        }
    } catch {
        Write-Error "❌ DISM not found. Please install Windows ADK."
        return $false
    }
    
    # Check for oscdimg.exe
    $oscdimgPaths = @(
        "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe",
        "${env:ProgramFiles}\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
    )
    
    $oscdimgFound = $false
    foreach ($path in $oscdimgPaths) {
        if (Test-Path $path) {
            $script:oscdimgPath = $path
            $oscdimgFound = $true
            Write-ColorOutput "✅ oscdimg.exe found at: $path" "Green"
            break
        }
    }
    
    if (-not $oscdimgFound) {
        Write-Error "❌ oscdimg.exe not found. Please install Windows ADK with Deployment Tools."
        return $false
    }
    
    return $true
}

# Function to download Windows 11 ISO
function Get-Windows11ISO {
    param([string]$Url, [string]$Destination)
    
    if ($SkipDownload) {
        Write-ColorOutput "⏭️ Skipping ISO download as requested" "Yellow"
        return
    }
    
    Write-ColorOutput "📥 Downloading Windows 11 ISO..." "Cyan"
    Write-ColorOutput "Source: $Url" "Gray"
    Write-ColorOutput "Destination: $Destination" "Gray"
    
    try {
        # Use curl for download with progress
        $curlArgs = @(
            "-L",
            "-o", $Destination,
            "--progress-bar",
            $Url
        )
        
        & curl @curlArgs
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ ISO downloaded successfully" "Green"
        } else {
            throw "Download failed with exit code $LASTEXITCODE"
        }
    } catch {
        Write-Error "❌ Failed to download ISO: $_"
        exit 1
    }
}

# Function to prepare working directories
function Initialize-WorkingDirectories {
    Write-ColorOutput "📁 Preparing working directories..." "Cyan"
    
    $directories = @(
        $WorkDir,
        "$WorkDir\ISO_Extract",
        "$WorkDir\Mount",
        "$WorkDir\OOBE_Backup"
    )
    
    foreach ($dir in $directories) {
        if (Test-Path $dir) {
            Write-ColorOutput "🗑️ Cleaning existing directory: $dir" "Yellow"
            Remove-Item $dir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-ColorOutput "✅ Created: $dir" "Green"
    }
}

# Function to extract ISO contents
function Expand-ISOContents {
    param([string]$ISOPath, [string]$ExtractPath)
    
    Write-ColorOutput "📦 Extracting ISO contents..." "Cyan"
    
    try {
        # Mount ISO
        $mountResult = Mount-DiskImage -ImagePath $ISOPath -PassThru
        $driveLetter = ($mountResult | Get-Volume).DriveLetter
        
        Write-ColorOutput "💿 ISO mounted to drive $driveLetter" "Green"
        
        # Copy all files
        $sourceDir = "${driveLetter}:\"
        Write-ColorOutput "📋 Copying files from $sourceDir to $ExtractPath..." "Cyan"
        
        robocopy $sourceDir $ExtractPath /E /R:3 /W:10 /MT:8 | Out-Null
        
        # Unmount ISO
        Dismount-DiskImage -ImagePath $ISOPath | Out-Null
        Write-ColorOutput "✅ ISO contents extracted successfully" "Green"
        
    } catch {
        Write-Error "❌ Failed to extract ISO: $_"
        exit 1
    }
}

# Function to modify boot.wim
function Edit-BootWim {
    param([string]$ExtractPath, [string]$MountPath)
    
    Write-ColorOutput "🔧 Modifying boot.wim..." "Cyan"
    
    $bootWimPath = "$ExtractPath\sources\boot.wim"
    
    try {
        # Get WIM info
        Write-ColorOutput "📊 Getting boot.wim information..." "Gray"
        dism /get-wiminfo /wimfile:"$bootWimPath" | Out-Null
        
        # Mount boot.wim (index 2 is usually Windows Setup)
        Write-ColorOutput "🔗 Mounting boot.wim index 2..." "Gray"
        dism /mount-wim /wimfile:"$bootWimPath" /index:2 /mountdir:"$MountPath" | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to mount boot.wim"
        }
        
        # Replace OOBE files
        Replace-OOBEFiles -MountPath $MountPath
        
        # Unmount and commit
        Write-ColorOutput "💾 Committing changes to boot.wim..." "Gray"
        dism /unmount-wim /mountdir:"$MountPath" /commit | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to commit boot.wim changes"
        }
        
        Write-ColorOutput "✅ boot.wim modified successfully" "Green"
        
    } catch {
        Write-Error "❌ Failed to modify boot.wim: $_"
        # Try to unmount if still mounted
        dism /unmount-wim /mountdir:"$MountPath" /discard 2>$null | Out-Null
        exit 1
    }
}

# Function to modify install.wim
function Edit-InstallWim {
    param([string]$ExtractPath, [string]$MountPath)
    
    Write-ColorOutput "🔧 Modifying install.wim..." "Cyan"
    
    $installWimPath = "$ExtractPath\sources\install.wim"
    
    try {
        # Get WIM info
        Write-ColorOutput "📊 Getting install.wim information..." "Gray"
        dism /get-wiminfo /wimfile:"$installWimPath" | Out-Null
        
        # Mount install.wim (index 1 is usually the main edition)
        Write-ColorOutput "🔗 Mounting install.wim index 1..." "Gray"
        dism /mount-wim /wimfile:"$installWimPath" /index:1 /mountdir:"$MountPath" | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to mount install.wim"
        }
        
        # Replace OOBE files
        Replace-OOBEFiles -MountPath $MountPath
        
        # Apply registry modifications
        Set-RegistryBranding -MountPath $MountPath
        
        # Unmount and commit
        Write-ColorOutput "💾 Committing changes to install.wim..." "Gray"
        dism /unmount-wim /mountdir:"$MountPath" /commit | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to commit install.wim changes"
        }
        
        Write-ColorOutput "✅ install.wim modified successfully" "Green"
        
    } catch {
        Write-Error "❌ Failed to modify install.wim: $_"
        # Try to unmount if still mounted
        dism /unmount-wim /mountdir:"$MountPath" /discard 2>$null | Out-Null
        exit 1
    }
}

# Function to replace OOBE files
function Replace-OOBEFiles {
    param([string]$MountPath)
    
    Write-ColorOutput "🎨 Replacing OOBE files with MaxRegneRos customization..." "Cyan"
    
    $oobeDestPath = "$MountPath\Windows\System32\oobe"
    $cloudExperienceHostPath = "$MountPath\Windows\SystemApps\Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy"
    
    try {
        # Backup original OOBE files
        if (Test-Path $oobeDestPath) {
            $backupPath = "$WorkDir\OOBE_Backup\oobe_original"
            Write-ColorOutput "💾 Backing up original OOBE files..." "Gray"
            robocopy $oobeDestPath $backupPath /E /R:1 /W:1 | Out-Null
        }
        
        # Copy our custom OOBE files
        if (Test-Path "$OOBESourceDir\default.html") {
            Write-ColorOutput "📋 Copying MaxRegneRos OOBE files..." "Gray"
            
            # Copy main OOBE files
            $filesToCopy = @(
                "default.html",
                "css\oobe-desktop.css",
                "images\logo.png",
                "images\smalllogo.png", 
                "images\splashscreen.png"
            )
            
            foreach ($file in $filesToCopy) {
                $sourcePath = "$OOBESourceDir\$file"
                $destPath = "$oobeDestPath\$file"
                
                if (Test-Path $sourcePath) {
                    $destDir = Split-Path $destPath -Parent
                    if (-not (Test-Path $destDir)) {
                        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                    }
                    Copy-Item $sourcePath $destPath -Force
                    Write-ColorOutput "✅ Copied: $file" "Green"
                } else {
                    Write-ColorOutput "⚠️ Source file not found: $sourcePath" "Yellow"
                }
            }
            
            # Copy MaxRegneRos branding directory
            $brandingSource = "$OOBESourceDir\maxregneros-branding"
            $brandingDest = "$oobeDestPath\maxregneros-branding"
            
            if (Test-Path $brandingSource) {
                robocopy $brandingSource $brandingDest /E /R:1 /W:1 | Out-Null
                Write-ColorOutput "✅ Copied MaxRegneRos branding assets" "Green"
            }
            
            # Copy webapp files
            $webappSource = "$OOBESourceDir\webapps\inclusiveOobe"
            $webappDest = "$oobeDestPath\webapps\inclusiveOobe"
            
            if (Test-Path $webappSource) {
                robocopy $webappSource $webappDest /E /R:1 /W:1 | Out-Null
                Write-ColorOutput "✅ Copied MaxRegneRos webapp files" "Green"
            }
            
        } else {
            Write-ColorOutput "⚠️ MaxRegneRos OOBE source files not found in: $OOBESourceDir" "Yellow"
        }
        
    } catch {
        Write-Error "❌ Failed to replace OOBE files: $_"
        throw
    }
}

# Function to set registry branding
function Set-RegistryBranding {
    param([string]$MountPath)
    
    Write-ColorOutput "🔧 Applying MaxRegneRos registry branding..." "Cyan"
    
    try {
        # Load registry hives
        $softwareHive = "$MountPath\Windows\System32\config\SOFTWARE"
        $systemHive = "$MountPath\Windows\System32\config\SYSTEM"
        
        Write-ColorOutput "📝 Loading registry hives..." "Gray"
        reg load HKLM\OFFLINE_SOFTWARE $softwareHive | Out-Null
        reg load HKLM\OFFLINE_SYSTEM $systemHive | Out-Null
        
        # Set OEM Information
        $oemPath = "HKLM\OFFLINE_SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"
        reg add $oemPath /v Manufacturer /t REG_SZ /d "MaxRegneRos" /f | Out-Null
        reg add $oemPath /v Model /t REG_SZ /d "MaxRegneRos Edition" /f | Out-Null
        reg add $oemPath /v SupportURL /t REG_SZ /d "https://maxregneros.com/support" /f | Out-Null
        
        # Set custom branding
        $brandingPath = "HKLM\OFFLINE_SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        reg add $brandingPath /v SystemUsesLightTheme /t REG_DWORD /d 0 /f | Out-Null
        
        Write-ColorOutput "✅ Registry branding applied" "Green"
        
        # Unload registry hives
        reg unload HKLM\OFFLINE_SOFTWARE | Out-Null
        reg unload HKLM\OFFLINE_SYSTEM | Out-Null
        
    } catch {
        Write-ColorOutput "⚠️ Registry modification failed: $_" "Yellow"
        # Try to unload hives if they're still loaded
        reg unload HKLM\OFFLINE_SOFTWARE 2>$null | Out-Null
        reg unload HKLM\OFFLINE_SYSTEM 2>$null | Out-Null
    }
}

# Function to create custom ISO
function New-CustomISO {
    param([string]$ExtractPath, [string]$OutputPath)
    
    Write-ColorOutput "📀 Creating MaxRegneRos custom ISO..." "Cyan"
    
    try {
        $oscdimgArgs = @(
            "-m",
            "-o",
            "-u2",
            "-udfver102",
            "-bootdata:2#p0,e,b`"$ExtractPath\boot\etfsboot.com`"#pEF,e,b`"$ExtractPath\efi\microsoft\boot\efisys.bin`"",
            "`"$ExtractPath`"",
            "`"$OutputPath`""
        )
        
        Write-ColorOutput "🔨 Running oscdimg.exe..." "Gray"
        & $script:oscdimgPath @oscdimgArgs
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Custom ISO created successfully: $OutputPath" "Green"
            
            # Get file size
            $isoSize = (Get-Item $OutputPath).Length / 1GB
            Write-ColorOutput "📊 ISO Size: $([math]::Round($isoSize, 2)) GB" "Cyan"
        } else {
            throw "oscdimg.exe failed with exit code $LASTEXITCODE"
        }
        
    } catch {
        Write-Error "❌ Failed to create custom ISO: $_"
        exit 1
    }
}

# Function to upload to BashUpload
function Publish-ToBashUpload {
    param([string]$FilePath)
    
    if ($TestMode) {
        Write-ColorOutput "🧪 Test mode: Skipping upload to BashUpload" "Yellow"
        return
    }
    
    Write-ColorOutput "🌐 Uploading to BashUpload.com..." "Cyan"
    
    try {
        $uploadResult = curl -F "file=@$FilePath" https://bashupload.com/
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Upload successful!" "Green"
            Write-ColorOutput "🔗 Download URL: $uploadResult" "Cyan"
        } else {
            throw "Upload failed with exit code $LASTEXITCODE"
        }
        
    } catch {
        Write-Error "❌ Failed to upload to BashUpload: $_"
    }
}

# Main execution
function Main {
    Write-ColorOutput "🚀 MaxRegneRos Windows 11 ISO Builder" "Magenta"
    Write-ColorOutput "=====================================" "Magenta"
    
    # Check prerequisites
    if (-not (Test-RequiredTools)) {
        exit 1
    }
    
    # Initialize working directories
    Initialize-WorkingDirectories
    
    # Download ISO if needed
    if (-not $SkipDownload) {
        Get-Windows11ISO -Url $SourceISO -Destination "$WorkDir\source.iso"
        $SourceISO = "$WorkDir\source.iso"
    }
    
    # Verify source ISO exists
    if (-not (Test-Path $SourceISO)) {
        Write-Error "❌ Source ISO not found: $SourceISO"
        exit 1
    }
    
    # Extract ISO contents
    Expand-ISOContents -ISOPath $SourceISO -ExtractPath "$WorkDir\ISO_Extract"
    
    # Modify boot.wim
    Edit-BootWim -ExtractPath "$WorkDir\ISO_Extract" -MountPath "$WorkDir\Mount"
    
    # Modify install.wim
    Edit-InstallWim -ExtractPath "$WorkDir\ISO_Extract" -MountPath "$WorkDir\Mount"
    
    # Create custom ISO
    New-CustomISO -ExtractPath "$WorkDir\ISO_Extract" -OutputPath $OutputISO
    
    # Upload to BashUpload
    Publish-ToBashUpload -FilePath $OutputISO
    
    Write-ColorOutput "🎉 MaxRegneRos Windows 11 ISO creation completed!" "Green"
    Write-ColorOutput "📁 Output ISO: $OutputISO" "Cyan"
}

# Run the main function
Main
