@echo off
echo Enhanced GitHub Contribution Pattern
echo =================================
echo.
echo This script will:
echo 1. Create a natural yet impressive GitHub contribution pattern
echo 2. Make 22-24 out of 30 days have contributions (about 73-80%%)
echo 3. Use intensity levels 3-5 (medium to dark green)
echo 4. Ensure at least 3 days with high intensity (level 5) in each 10-day period
echo.

set /p start_year="Enter start year (default: 2022): "
set /p start_month="Enter start month (default: 11): "
set /p end_year="Enter end year (default: 2025): "
set /p end_month="Enter end month (default: 3): "
set /p cleanup="Clean up unused files and directories? (Y/N, default: N): "
set /p force="Force push to GitHub? (Y/N, default: N): "

if "%start_year%"=="" set start_year=2022
if "%start_month%"=="" set start_month=11
if "%end_year%"=="" set end_year=2025
if "%end_month%"=="" set end_month=3
if "%cleanup%"=="" set cleanup=N
if "%force%"=="" set force=N

echo.
echo You entered:
echo - Start: %start_month%/%start_year%
echo - End: %end_month%/%end_year%
echo - Clean up: %cleanup%
echo - Force push: %force%
echo.

set /p confirm="Do you want to proceed? (Y/N): "

if /i "%confirm%"=="Y" (
    echo.
    if /i "%force%"=="Y" (
        if /i "%cleanup%"=="Y" (
            echo Starting to create enhanced GitHub contribution pattern with force push and cleanup...
            powershell -ExecutionPolicy Bypass -Command "& { & '.\enhanced_github_pattern.ps1' -StartYear %start_year% -StartMonth %start_month% -EndYear %end_year% -EndMonth %end_month% -Force -CleanupUnused }"
        ) else (
            echo Starting to create enhanced GitHub contribution pattern with force push...
            powershell -ExecutionPolicy Bypass -Command "& { & '.\enhanced_github_pattern.ps1' -StartYear %start_year% -StartMonth %start_month% -EndYear %end_year% -EndMonth %end_month% -Force }"
        )
    ) else (
        if /i "%cleanup%"=="Y" (
            echo Starting to create enhanced GitHub contribution pattern with cleanup...
            powershell -ExecutionPolicy Bypass -Command "& { & '.\enhanced_github_pattern.ps1' -StartYear %start_year% -StartMonth %start_month% -EndYear %end_year% -EndMonth %end_month% -CleanupUnused }"
        ) else (
            echo Starting to create enhanced GitHub contribution pattern...
            powershell -ExecutionPolicy Bypass -Command "& { & '.\enhanced_github_pattern.ps1' -StartYear %start_year% -StartMonth %start_month% -EndYear %end_year% -EndMonth %end_month% }"
        )
    )
) else (
    echo.
    echo Operation cancelled.
)

echo.
echo Press any key to exit...
pause > nul
