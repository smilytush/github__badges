@echo off
echo GitHub Workflow Automation
echo ========================
echo.
echo Starting enhanced menu...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0enhanced_menu_fixed.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo Error running the enhanced menu script.
    echo Error code: %ERRORLEVEL%
    pause
)
pause
