@echo off
echo ===============================================
echo DIRECT Full Historical Backdate System
echo ===============================================
echo.
echo This script will immediately start the full historical
echo backdating system without additional confirmations.
echo.
echo WARNING: This will create thousands of backdated commits!
echo This process may take 30-60 minutes to complete.
echo.
echo GitHub Target: smilytush/github-commits
echo Period: November 1st, 2022 to Present
echo Coverage: 82%% of all days
echo.
echo Press Ctrl+C now if you want to cancel.
echo Otherwise, the system will start in 5 seconds...
echo.

timeout /t 5 /nobreak >nul

echo Starting full system execution with force mode...
cd /d "J:\green-commits"
powershell.exe -ExecutionPolicy Bypass -File "run_foolproof_system.ps1" -Force

echo.
pause
