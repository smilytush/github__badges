@echo off
echo Green Commits - GitHub Setup
echo ==========================
echo.
echo This script will help you set up your GitHub repository.
echo.
echo Options:
echo 1. Create repository and push (recommended)
echo 2. Use Personal Access Token (advanced)
echo.
set /p choice="Enter your choice (1 or 2): "

if "%choice%"=="1" (
    powershell -ExecutionPolicy Bypass -File "%~dp0create_github_repo.ps1"
) else if "%choice%"=="2" (
    powershell -ExecutionPolicy Bypass -File "%~dp0setup_github_with_pat.ps1"
) else (
    echo Invalid choice. Please run the script again and enter 1 or 2.
    pause
    exit /b 1
)

echo.
echo GitHub setup complete!
echo.
echo Press any key to exit...
pause > nul
