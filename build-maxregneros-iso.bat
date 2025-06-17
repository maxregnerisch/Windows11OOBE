@echo off
REM MaxRegneRos Windows 11 ISO Builder - Batch Launcher
REM This batch file launches the PowerShell script with the correct parameters

echo.
echo ========================================
echo   MaxRegneRos Windows 11 ISO Builder
echo ========================================
echo.

REM Check if running as Administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [INFO] Running with Administrator privileges
) else (
    echo [ERROR] This script requires Administrator privileges
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

REM Set default parameters
set "ISO_URL=https://archive.org/download/windows-11-ultra.lite.-x-22000.100.x-64/Windows11_Ultra.lite.X_22000.100.x64.iso"
set "OUTPUT_ISO=C:\MaxRegneRos_Windows11.iso"
set "WORK_DIR=C:\MaxRegneRos_Build"

echo [INFO] Configuration:
echo   Source ISO URL: %ISO_URL%
echo   Output ISO: %OUTPUT_ISO%
echo   Work Directory: %WORK_DIR%
echo.

REM Ask user for confirmation
set /p "CONFIRM=Do you want to proceed with the ISO build? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Build cancelled by user
    pause
    exit /b 0
)

echo.
echo [INFO] Starting PowerShell script...
echo.

REM Execute PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "Build-MaxRegneRosISO.ps1" -SourceISO "%ISO_URL%" -OutputISO "%OUTPUT_ISO%" -WorkDir "%WORK_DIR%" -OOBESourceDir "."

if %errorLevel% == 0 (
    echo.
    echo [SUCCESS] MaxRegneRos ISO build completed successfully!
    echo Output file: %OUTPUT_ISO%
) else (
    echo.
    echo [ERROR] ISO build failed with error code %errorLevel%
)

echo.
pause
