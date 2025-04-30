@echo off
echo Green GitHub Workflow Manual Runner
echo ================================
echo.

echo This script will run the green-commits workflow manually.
echo.

set /p session="Choose session (morning/afternoon): "

if /i "%session%"=="morning" (
    echo Running morning session...
    powershell -ExecutionPolicy Bypass -Command "& { $env:WORKFLOW_SESSION = 'morning'; & 'J:\green-commits\green_workflow_4levels.ps1' }"
) else if /i "%session%"=="afternoon" (
    echo Running afternoon session...
    powershell -ExecutionPolicy Bypass -Command "& { $env:WORKFLOW_SESSION = 'afternoon'; & 'J:\green-commits\green_workflow_4levels.ps1' }"
) else (
    echo Invalid session. Please choose 'morning' or 'afternoon'.
    pause
    exit /b 1
)

echo.
echo Workflow completed!
pause
