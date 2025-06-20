@echo off
REM ===============================================
REM GREEN COMMITS DAILY AUTOMATION BATCH FILE
REM ===============================================
REM Simple batch file for daily commit automation
REM Can be scheduled with Windows Task Scheduler
REM ===============================================

echo [%date% %time%] Starting Green Commits Daily Automation...

REM Change to the script directory
cd /d "J:\green-commits"

REM Run the daily commit script
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "GreenCommits-Simple.ps1" -Mode Daily

echo [%date% %time%] Daily automation completed.

REM Log the execution
echo [%date% %time%] Daily automation executed >> daily-automation.log
