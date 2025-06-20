@echo off
echo ===============================================
echo Enhanced Historical Backdated GitHub Commit System v2.0
echo ===============================================
echo.
echo This system creates backdated commits from November 1st, 2022 to present
echo with 82%% coverage and comprehensive validation.
echo.
echo GitHub Configuration:
echo - Username: smilytush
echo - Repository: github-commits
echo - Period: November 1st, 2022 to Present
echo - Coverage: 82%% of all days in the period
echo.
echo Options:
echo 1. Run Comprehensive Tests (Recommended First)
echo 2. Test Mode (5 sample commits)
echo 3. Validation Only (Check configuration)
echo 4. Full System (Create all historical commits)
echo 5. Foolproof Execution (All-in-one)
echo 6. Exit
echo.
set /p choice="Enter your choice (1-6): "

cd /d "J:\green-commits"

if "%choice%"=="1" (
    echo.
    echo Running comprehensive tests...
    powershell.exe -ExecutionPolicy Bypass -File "comprehensive_test_system.ps1"
) else if "%choice%"=="2" (
    echo.
    echo Starting test mode...
    powershell.exe -ExecutionPolicy Bypass -File "enhanced_historical_system_v2.ps1" -TestMode
) else if "%choice%"=="3" (
    echo.
    echo Running validation only...
    powershell.exe -ExecutionPolicy Bypass -File "enhanced_historical_system_v2.ps1" -ValidateOnly
) else if "%choice%"=="4" (
    echo.
    echo Starting full historical system...
    echo WARNING: This will create thousands of commits!
    pause
    powershell.exe -ExecutionPolicy Bypass -File "enhanced_historical_system_v2.ps1"
) else if "%choice%"=="5" (
    echo.
    echo Starting foolproof execution...
    powershell.exe -ExecutionPolicy Bypass -File "run_foolproof_system.ps1"
) else if "%choice%"=="6" (
    echo Exiting...
    exit /b 0
) else (
    echo Invalid choice. Please run the script again.
)

echo.
pause
