@echo off
echo ===============================================
echo FOOLPROOF Enhanced Historical Backdate System
echo ===============================================
echo.
echo This is the simplest way to run the system.
echo It will automatically:
echo - Test all functionality
echo - Validate GitHub access
echo - Create backdated commits from Nov 1, 2022 to present
echo - Show progress and results
echo.
echo GitHub Target: smilytush/github-commits
echo Period: November 1st, 2022 to Present
echo Coverage: 82%% of all days
echo.
echo Choose your option:
echo 1. Quick Test Mode (5 sample commits - fastest)
echo 2. Validation Only (Check everything works)
echo 3. Full System (Create all historical commits)
echo 4. Exit
echo.
set /p choice="Enter your choice (1-4): "

cd /d "J:\green-commits"

if "%choice%"=="1" (
    echo.
    echo Running quick test mode...
    powershell.exe -ExecutionPolicy Bypass -File "quick_test_mode.ps1"
) else if "%choice%"=="2" (
    echo.
    echo Running validation only...
    powershell.exe -ExecutionPolicy Bypass -File "run_foolproof_system.ps1" -ValidateOnly
) else if "%choice%"=="3" (
    echo.
    echo *** WARNING ***
    echo This will create thousands of backdated commits!
    echo This process may take 30-60 minutes to complete.
    echo.
    echo Starting full system execution...
    echo Note: The PowerShell script will ask for final confirmation.
    powershell.exe -ExecutionPolicy Bypass -File "run_foolproof_system.ps1"
) else if "%choice%"=="4" (
    echo Exiting...
    exit /b 0
) else (
    echo Invalid choice. Please run the script again.
)

echo.
pause
