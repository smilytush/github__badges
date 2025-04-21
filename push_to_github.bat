@echo off
echo Green Commits - Push to GitHub
echo ===========================
echo.
echo This script will help you push your repository to GitHub.
echo You will need a GitHub Personal Access Token (PAT).
echo.
echo Press any key to continue...
pause > nul

powershell -ExecutionPolicy Bypass -File "%~dp0push_to_github.ps1"

echo.
echo Press any key to exit...
pause > nul
