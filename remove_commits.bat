@echo off
echo Remove Specific Commits from GitHub
echo ================================
echo.
echo This script will help you remove specific commits from your Git history
echo and update your GitHub contribution graph.
echo.
echo WARNING: This operation rewrites Git history and requires a force push.
echo Make sure you understand the consequences before proceeding.
echo.

set /p confirm="Do you want to proceed? (Y/N): "

if /i "%confirm%"=="Y" (
    echo.
    echo Starting commit removal process...
    powershell -ExecutionPolicy Bypass -Command "& { & '.\remove_commits.ps1' }"
) else (
    echo.
    echo Operation cancelled.
)

echo.
echo Press any key to exit...
pause > nul
