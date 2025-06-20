@echo off
echo ===============================================
echo Comprehensive Backdated GitHub Commit System
echo ===============================================
echo.
echo This script will create 300 backdated commits
echo for the past year with realistic patterns.
echo.
echo GitHub Configuration:
echo - Username: smilytush
echo - Repository: github-commits
echo - Coverage: 300 days out of 365 (82%%)
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul

cd /d "J:\green-commits"

echo.
echo Starting comprehensive backdated commit system...
echo.

powershell.exe -ExecutionPolicy Bypass -File "comprehensive_backdate_system.ps1"

echo.
echo Script execution completed!
echo Check your GitHub profile: https://github.com/smilytush
echo.
pause
