# MaxRegneRos Windows 11 ISO Builder

## 🚀 Overview

This toolkit creates a custom Windows 11 ISO with MaxRegneRos branding, custom OOBE experience, and pre-configured applications. The process automatically downloads the Windows 11 Ultra Lite ISO, applies our custom modifications, and creates a ready-to-use installation media.

## 📋 Prerequisites

### Required Software
1. **Windows 11 ADK (Assessment and Deployment Kit)**
   - Download from: https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install
   - Install only the "Deployment Tools" component
   
2. **Windows PE Add-on for ADK**
   - Download from the same Microsoft page
   - Required for WinPE functionality

3. **Administrator Privileges**
   - The script must be run as Administrator
   - Required for DISM operations and system file modifications

### System Requirements
- Windows 10/11 with PowerShell 5.1 or later
- At least 10GB free disk space
- Stable internet connection for ISO download (1.7GB)

## 🛠️ Quick Start

### Method 1: Batch File (Recommended)
1. Right-click `build-maxregneros-iso.bat`
2. Select "Run as administrator"
3. Follow the prompts
4. Wait for completion

### Method 2: PowerShell Direct
```powershell
# Run as Administrator
.\Build-MaxRegneRosISO.ps1 -SourceISO "https://archive.org/download/windows-11-ultra.lite.-x-22000.100.x-64/Windows11_Ultra.lite.X_22000.100.x64.iso"
```

## 📁 File Structure

```
MaxRegneRos-OOBE/
├── Build-MaxRegneRosISO.ps1      # Main PowerShell script
├── build-maxregneros-iso.bat     # Batch launcher
├── windows-iso-modification-guide.md  # Detailed guide
├── ISO-BUILD-README.md           # This file
├── default.html                  # Custom OOBE entry point
├── css/
│   └── oobe-desktop.css          # Custom styling
├── images/
│   ├── logo.png                  # MaxRegneRos logos
│   ├── smalllogo.png
│   └── splashscreen.png
├── maxregneros-branding/
│   ├── colors.css                # Color scheme
│   ├── strings.js                # Custom text
│   └── *.png                     # Logo assets
└── webapps/inclusiveOobe/
    ├── view/
    │   └── maxregnerosapps-main.html  # App selection screen
    └── js/
        └── maxregnerosapps-page.js    # App logic
```

## ⚙️ Build Process

### Step 1: Tool Verification
- Checks for DISM availability
- Locates oscdimg.exe from Windows ADK
- Validates Administrator privileges

### Step 2: ISO Download
- Downloads Windows 11 Ultra Lite ISO (1.7GB)
- Source: `https://archive.org/download/windows-11-ultra.lite.-x-22000.100.x-64/Windows11_Ultra.lite.X_22000.100.x64.iso`
- Uses curl with progress indication

### Step 3: ISO Extraction
- Mounts the downloaded ISO
- Extracts all contents to working directory
- Prepares for modification

### Step 4: Boot.wim Modification
- Mounts boot.wim (Windows Setup environment)
- Replaces OOBE files with MaxRegneRos versions
- Commits changes back to boot.wim

### Step 5: Install.wim Modification
- Mounts install.wim (main Windows image)
- Replaces OOBE files and applies registry branding
- Sets OEM information to MaxRegneRos
- Commits changes back to install.wim

### Step 6: Custom ISO Creation
- Uses oscdimg.exe to create bootable ISO
- Maintains UEFI and legacy boot compatibility
- Generates final MaxRegneRos Windows 11 ISO

### Step 7: Upload to BashUpload
- Automatically uploads completed ISO
- Provides download link for distribution

## 🎨 Customizations Applied

### Visual Branding
- **Purple Gradient Theme**: #2D1B69 → #7C3AED → #A855F7
- **MaxRegneRos Logos**: Custom "MR" logo throughout OOBE
- **Custom Backgrounds**: Purple gradient replacing Microsoft blue

### OOBE Experience
- **Welcome Screen**: "Welcome to MaxRegneRos" instead of Windows
- **App Selection**: Custom screen with 6 MaxRegneRos applications
- **Branding Elements**: MaxRegneRos copyright and system information

### Registry Modifications
- **OEM Information**: Manufacturer set to "MaxRegneRos"
- **Model**: "MaxRegneRos Edition"
- **Support URL**: Custom support link
- **Theme Settings**: Dark theme by default

### Custom Applications
1. **MaxRegneRos Hub** (Essential - pre-selected)
2. **MaxRegneRos Store**
3. **MaxRegneRos Cloud**
4. **MaxRegneRos Secure**
5. **MaxRegneRos Media**
6. **MaxRegneRos Productivity Suite**

## 🧪 Testing

### Virtual Machine Testing
1. Create VM with 4GB+ RAM and 64GB+ storage
2. Boot from custom MaxRegneRos ISO
3. Verify purple branding appears during OOBE
4. Test app selection functionality
5. Complete installation and verify branding

### Validation Checklist
- [ ] Purple gradient background in OOBE
- [ ] MaxRegneRos logos display correctly
- [ ] Custom app selection screen works
- [ ] All text shows MaxRegneRos branding
- [ ] OOBE completes without errors
- [ ] Windows boots with custom OEM info

## 📊 Output Information

### Generated Files
- **MaxRegneRos_Windows11.iso**: Final custom ISO (~1.7GB)
- **Build logs**: Detailed operation logs
- **Backup files**: Original OOBE files preserved

### Upload Details
- **Platform**: BashUpload.com
- **Retention**: Files available for download
- **Access**: Public download link provided

## 🔧 Advanced Usage

### Custom Parameters
```powershell
.\Build-MaxRegneRosISO.ps1 `
    -SourceISO "path\to\your\windows11.iso" `
    -OutputISO "C:\Custom\MaxRegneRos.iso" `
    -WorkDir "D:\Build" `
    -OOBESourceDir ".\custom-oobe" `
    -TestMode `
    -SkipDownload
```

### Parameters Explained
- **SourceISO**: Path or URL to source Windows 11 ISO
- **OutputISO**: Path for final custom ISO
- **WorkDir**: Working directory for build process
- **OOBESourceDir**: Directory containing custom OOBE files
- **TestMode**: Skip upload to BashUpload
- **SkipDownload**: Use existing ISO file

## 🚨 Troubleshooting

### Common Issues

#### "DISM not found"
- Install Windows 11 ADK with Deployment Tools
- Ensure ADK is in system PATH

#### "oscdimg.exe not found"
- Install Windows ADK completely
- Check installation path in script

#### "Access Denied" errors
- Run as Administrator
- Disable antivirus temporarily
- Check file permissions

#### ISO download fails
- Check internet connection
- Try different download source
- Use -SkipDownload with local ISO

### Error Recovery
```powershell
# Clean up failed build
Remove-Item "C:\MaxRegneRos_Build" -Recurse -Force

# Check for mounted images
dism /get-mountedwiminfo

# Unmount if stuck
dism /unmount-wim /mountdir:"C:\MaxRegneRos_Build\Mount" /discard
```

## 📄 Legal Notes

- Based on Windows 11 Ultra Lite ISO
- Respects Windows licensing terms
- Custom branding for educational/personal use
- Ensure compliance with Microsoft licensing

## 🤝 Support

For issues or questions:
1. Check the troubleshooting section
2. Review build logs in working directory
3. Verify all prerequisites are installed
4. Test with a clean working directory

---

**MaxRegneRos** - Your Personalized Computing Experience  
© 2024 MaxRegneRos. All rights reserved.
