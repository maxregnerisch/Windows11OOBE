# Windows 11 ISO Modification Guide - MaxRegneRos Integration

## Overview
This guide details how to integrate our custom MaxRegneRos OOBE into a Windows 11 ISO using DISM (Deployment Image Servicing and Management).

## Prerequisites
- Windows 11 ADK (Assessment and Deployment Kit)
- Windows PE add-on
- Original Windows 11 ISO
- Administrative privileges
- Our custom MaxRegneRos OOBE files

## Step-by-Step Process

### 1. Download and Install Required Tools
```powershell
# Download Windows 11 ADK from Microsoft
# https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install

# Install only "Deployment Tools" component
# Install Windows PE add-on
```

### 2. Prepare Working Directories
```powershell
# Create working directories
mkdir C:\Windows11_Custom
mkdir C:\Mount
mkdir C:\MaxRegneRos_OOBE

# Extract ISO contents
# Mount Windows 11 ISO and copy all files to C:\Windows11_Custom
```

### 3. Extract and Modify Boot.wim
```powershell
# Check boot.wim info
dism /get-wiminfo /wimfile:"C:\Windows11_Custom\sources\boot.wim"

# Mount boot.wim (usually index 2 for Windows Setup)
dism /mount-wim /wimfile:"C:\Windows11_Custom\sources\boot.wim" /index:2 /mountdir:C:\Mount
```

### 4. Replace OOBE Files
```powershell
# Navigate to OOBE location in mounted image
cd "C:\Mount\Windows\System32\oobe"

# Backup original OOBE files
mkdir "C:\Mount\Windows\System32\oobe_backup"
xcopy "C:\Mount\Windows\System32\oobe\*" "C:\Mount\Windows\System32\oobe_backup\" /E /H /Y

# Copy our custom MaxRegneRos OOBE files
# Replace with our customized files from the repository
```

### 5. Modify Install.wim (Main Windows Image)
```powershell
# Unmount boot.wim first
dism /unmount-wim /mountdir:C:\Mount /commit

# Check install.wim editions
dism /get-wiminfo /wimfile:"C:\Windows11_Custom\sources\install.wim"

# Mount install.wim (choose appropriate index, usually 1 for Windows 11 Pro)
dism /mount-wim /wimfile:"C:\Windows11_Custom\sources\install.wim" /index:1 /mountdir:C:\Mount

# Replace OOBE files in install.wim as well
cd "C:\Mount\Windows\System32\oobe"
# Copy MaxRegneRos OOBE files here too
```

### 6. Apply Registry Modifications (Optional)
```powershell
# Load registry hives for modifications
reg load HKLM\OFFLINE_SOFTWARE "C:\Mount\Windows\System32\config\SOFTWARE"
reg load HKLM\OFFLINE_SYSTEM "C:\Mount\Windows\System32\config\SYSTEM"

# Add custom registry entries for MaxRegneRos branding
# Example: Set custom OEM information
reg add "HKLM\OFFLINE_SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Manufacturer /t REG_SZ /d "MaxRegneRos" /f
reg add "HKLM\OFFLINE_SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Model /t REG_SZ /d "MaxRegneRos Edition" /f

# Unload registry hives
reg unload HKLM\OFFLINE_SOFTWARE
reg unload HKLM\OFFLINE_SYSTEM
```

### 7. Commit Changes and Unmount
```powershell
# Unmount and commit install.wim
dism /unmount-wim /mountdir:C:\Mount /commit
```

### 8. Create Custom ISO
```powershell
# Use oscdimg.exe to create new ISO
# Located at: C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg

oscdimg.exe -m -o -u2 -udfver102 -bootdata:2#p0,e,b"C:\Windows11_Custom\boot\etfsboot.com"#pEF,e,b"C:\Windows11_Custom\efi\microsoft\boot\efisys.bin" "C:\Windows11_Custom" "C:\MaxRegneRos_Windows11.iso"
```

## MaxRegneRos OOBE Integration Points

### Files to Replace:
1. **CloudExperienceHost Package**
   - Location: `Windows\SystemApps\Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy\`
   - Replace with our custom OOBE files

2. **OOBE Resources**
   - Location: `Windows\System32\oobe\`
   - Replace HTML, CSS, JS, and image files

3. **System Resources**
   - Location: `Windows\SystemResources\`
   - Update branding resources

### Key Files to Modify:
- `default.html` - Main OOBE entry point
- `css/oobe-desktop.css` - Styling
- `images/logo.png` - Branding images
- `webapps/inclusiveOobe/` - OOBE screens
- `maxregneros-branding/` - Our custom assets

## Testing the Custom ISO

### Virtual Machine Testing:
1. Create new VM with sufficient resources
2. Boot from custom MaxRegneRos ISO
3. Verify OOBE displays MaxRegneRos branding
4. Test all OOBE screens and functionality
5. Confirm app installation works

### Validation Checklist:
- [ ] Purple gradient background appears
- [ ] MaxRegneRos logos display correctly
- [ ] Custom app selection screen works
- [ ] All text shows MaxRegneRos branding
- [ ] OOBE completes successfully
- [ ] Windows boots with custom branding

## Automation Script

We can create a PowerShell script to automate this entire process:

```powershell
# MaxRegneRos ISO Builder Script
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceISO,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputISO,
    
    [string]$WorkDir = "C:\MaxRegneRos_Build"
)

# Script would automate all the above steps
```

## Upload to BashUpload

Once the custom ISO is created and tested:

```powershell
# Upload to bashupload.com using curl
curl -F "file=@C:\MaxRegneRos_Windows11.iso" https://bashupload.com/
```

## Notes
- Always test in VM before physical deployment
- Keep backups of original files
- Ensure compliance with Windows licensing
- Document all modifications for future updates
