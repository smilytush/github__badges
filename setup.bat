@echo off
echo Green Commits Setup
echo =================
echo.
echo This script will set up the Green Commits automation.
echo.
echo Steps:
echo 1. Connect to GitHub
echo 2. Set up the Windows Task Scheduler task
echo.
echo Press Ctrl+C to cancel or any key to continue...
pause > nul

echo.
echo Step 1: Connecting to GitHub...
powershell -ExecutionPolicy Bypass -File "%~dp0setup_github.ps1"

echo.
echo Step 2: Setting up Windows Task Scheduler task...
echo This requires administrator privileges.
echo.
powershell -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0setup_task.ps1\"' -Verb RunAs"

echo.
echo Setup complete!
echo.
echo Your Green Commits automation is now set up and will run each time you log in to your computer.
echo.
echo Press any key to exit...
pause > nul
