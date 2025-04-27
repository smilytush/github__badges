@echo off
echo Green GitHub Workflow Automation (DARK GREEN)
echo =========================================
echo.
echo Starting green menu with dark green focus...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0green_menu_fixed.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo Error running the green menu script.
    echo Error code: %ERRORLEVEL%
    pause
)
pause
