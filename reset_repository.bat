@echo off
echo Reset Repository and Clear Contribution Graph
echo =========================================
echo.
echo This script will remove ALL commits from your repository
echo and create a fresh initial commit, effectively clearing
echo your GitHub contribution graph.
echo.
echo WARNING: This is a destructive operation that rewrites Git history!
echo A backup branch will be created before proceeding.
echo.

set /p confirm="Do you want to proceed? (Y/N): "

if /i "%confirm%"=="Y" (
    echo.
    echo Starting repository reset process...
    powershell -ExecutionPolicy Bypass -Command "& { & '.\reset_repository.ps1' }"
) else (
    echo.
    echo Operation cancelled.
)

echo.
echo Press any key to exit...
pause > nul
