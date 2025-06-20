@echo off
setlocal enabledelayedexpansion
title Repository Cleanup and Badge Automation
color 0A

echo.
echo ================================================================
echo    REPOSITORY CLEANUP AND BADGE AUTOMATION
echo    Fixing current state and running clean automation
echo ================================================================
echo.

echo [INFO] Step 1: Cleaning up current repository state...

REM Add all current changes
echo [INFO] Adding all current changes...
git add . >nul 2>&1

REM Commit everything to clean up
echo [INFO] Committing current state...
git commit -m "Cleanup: Add all badge automation files and progress" >nul 2>&1

REM Push current commits
echo [INFO] Pushing current commits to GitHub...
git push origin main >nul 2>&1

echo [SUCCESS] Repository cleaned up successfully!

echo.
echo [INFO] Step 2: Running simple badge automation...
echo.

REM Now run the simple automation
call SIMPLE-FREE-BADGE-AUTOMATION.bat

echo.
echo [SUCCESS] All operations completed!
echo [INFO] Your repository is now clean and badges are automated.
echo [INFO] Check your GitHub profile in 24-48 hours for new badges.
echo.
pause
exit /b 0
