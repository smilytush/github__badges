@echo off
echo Natural GitHub Contribution Pattern
echo =================================
echo.
echo This script will:
echo 1. Create a natural yet impressive GitHub contribution pattern
echo 2. Make 280 out of 365 days have contributions (about 77%%)
echo 3. Focus on darker green intensities (levels 4-5)
echo 4. Ensure 3 out of 10 days have the darkest green (level 5)
echo.

set /p start_year="Enter start year (default: 2022): "
set /p start_month="Enter start month (default: 11): "
set /p end_year="Enter end year (default: 2025): "
set /p end_month="Enter end month (default: 3): "
set /p cleanup="Clean up unused files and directories? (Y/N, default: N): "

if "%start_year%"=="" set start_year=2022
if "%start_month%"=="" set start_month=11
if "%end_year%"=="" set end_year=2025
if "%end_month%"=="" set end_month=3

echo.
echo You entered:
echo - Start: %start_month%/%start_year%
echo - End: %end_month%/%end_year%
echo - Clean up: %cleanup%
echo.
set /p confirm="Do you want to proceed? (Y/N): "

if /i "%confirm%"=="Y" (
    echo.
    set /p force="Do you want to force push changes? (Y/N): "
    
    if /i "%force%"=="Y" (
        echo.
        if /i "%cleanup%"=="Y" (
            echo Starting to create natural GitHub contribution pattern with force push and cleanup...
            powershell -ExecutionPolicy Bypass -Command "& { & 'J:\green-commits\natural_github_pattern.ps1' -StartYear %start_year% -StartMonth %start_month% -EndYear %end_year% -EndMonth %end_month% -Force -CleanupUnused }"
        ) else (
            echo Starting to create natural GitHub contribution pattern with force push...
            powershell -ExecutionPolicy Bypass -Command "& { & 'J:\green-commits\natural_github_pattern.ps1' -StartYear %start_year% -StartMonth %start_month% -EndYear %end_year% -EndMonth %end_month% -Force }"
        )
    ) else (
        echo.
        if /i "%cleanup%"=="Y" (
            echo Starting to create natural GitHub contribution pattern with cleanup...
            powershell -ExecutionPolicy Bypass -Command "& { & 'J:\green-commits\natural_github_pattern.ps1' -StartYear %start_year% -StartMonth %start_month% -EndYear %end_year% -EndMonth %end_month% -CleanupUnused }"
        ) else (
            echo Starting to create natural GitHub contribution pattern...
            powershell -ExecutionPolicy Bypass -Command "& { & 'J:\green-commits\natural_github_pattern.ps1' -StartYear %start_year% -StartMonth %start_month% -EndYear %end_year% -EndMonth %end_month% }"
        )
    )
) else (
    echo.
    echo Operation cancelled.
)

echo.
echo Press any key to exit...
pause > nul
