@echo off
echo Green Commits - Task Scheduler Setup
echo ================================
echo.
echo This script will set up the Windows Task Scheduler task to run the green_commit.ps1 script daily.
echo This requires administrator privileges.
echo.
echo Press any key to continue...
pause > nul

powershell -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0setup_task.ps1\"' -Verb RunAs"

echo.
echo If a UAC prompt appeared and you clicked Yes, the task should now be set up.
echo.
echo To verify the task was created correctly:
echo 1. Open Task Scheduler (taskschd.msc)
echo 2. Look for the task named 'GitHub Green Commit' in the Task Scheduler Library
echo 3. Right-click on it and select 'Run' to test it immediately
echo.
echo Press any key to exit...
pause > nul
