@echo off
REM ===============================================
REM GREEN COMMITS MASTER CONTROL LAUNCHER v1.0
REM ===============================================
REM Convenient Windows batch launcher for the Green Commits Master Control System
REM Handles PowerShell execution policies and provides error handling
REM 
REM Author: Green Commits Master System
REM Version: 1.0
REM Compatibility: Windows 10/11 with PowerShell 5.1+ or PowerShell Core 7+
REM ===============================================

setlocal enabledelayedexpansion

REM Set console title
title Green Commits Master Control Launcher

REM Set working directory to script location
cd /d "%~dp0"

REM Initialize variables
set "SCRIPT_NAME=GreenCommits-MasterControl.ps1"
set "LOG_FILE=Launch-GreenCommits-MasterControl.log"
set "TIMESTAMP=%date% %time%"
set "POWERSHELL_FOUND=false"
set "EXECUTION_SUCCESS=false"

REM Create log entry function
echo [%TIMESTAMP%] Green Commits Master Control Launcher started >> "%LOG_FILE%"
echo [%TIMESTAMP%] Working directory: %CD% >> "%LOG_FILE%"
echo [%TIMESTAMP%] Command line arguments: %* >> "%LOG_FILE%"

REM Display header
echo.
echo ================================================================
echo           GREEN COMMITS MASTER CONTROL LAUNCHER v1.0
echo        Convenient Windows Batch Launcher with Error Handling
echo ================================================================
echo.

REM Check if the PowerShell script exists
if not exist "%SCRIPT_NAME%" (
    echo ERROR: PowerShell script not found: %SCRIPT_NAME%
    echo Please ensure you are running this batch file from the correct directory.
    echo Expected location: %CD%\%SCRIPT_NAME%
    echo.
    echo [%TIMESTAMP%] ERROR: PowerShell script not found: %SCRIPT_NAME% >> "%LOG_FILE%"
    goto :error_exit
)

echo Found PowerShell script: %SCRIPT_NAME%
echo [%TIMESTAMP%] PowerShell script found: %SCRIPT_NAME% >> "%LOG_FILE%"

REM Test PowerShell availability and versions
echo.
echo Testing PowerShell availability...
echo.

REM Test PowerShell Core 7+ first (preferred)
echo Checking for PowerShell Core 7+...
pwsh -Command "Write-Host 'PowerShell Core detected:' $PSVersionTable.PSVersion" 2>nul
if !errorlevel! equ 0 (
    set "POWERSHELL_FOUND=true"
    set "POWERSHELL_CMD=pwsh"
    echo [%TIMESTAMP%] PowerShell Core 7+ detected and working >> "%LOG_FILE%"
    echo SUCCESS: PowerShell Core 7+ is available and will be used.
    echo.
) else (
    echo PowerShell Core 7+ not available or not working.
    echo.
)

REM Test Windows PowerShell 5.1 if Core not available
if "!POWERSHELL_FOUND!"=="false" (
    echo Checking for Windows PowerShell 5.1+...
    powershell -Command "Write-Host 'Windows PowerShell detected:' $PSVersionTable.PSVersion" 2>nul
    if !errorlevel! equ 0 (
        set "POWERSHELL_FOUND=true"
        set "POWERSHELL_CMD=powershell"
        echo [%TIMESTAMP%] Windows PowerShell 5.1+ detected and working >> "%LOG_FILE%"
        echo SUCCESS: Windows PowerShell 5.1+ is available and will be used.
        echo.
    ) else (
        echo ERROR: Windows PowerShell 5.1+ not available or not working.
        echo.
    )
)

REM Exit if no PowerShell found
if "!POWERSHELL_FOUND!"=="false" (
    echo ERROR: No compatible PowerShell version found.
    echo.
    echo Requirements:
    echo   - PowerShell Core 7+ ^(recommended^) or
    echo   - Windows PowerShell 5.1+
    echo.
    echo Please install PowerShell Core from: https://github.com/PowerShell/PowerShell
    echo Or ensure Windows PowerShell 5.1+ is properly installed.
    echo.
    echo [%TIMESTAMP%] ERROR: No compatible PowerShell version found >> "%LOG_FILE%"
    goto :error_exit
)

REM Prepare PowerShell command with execution policy bypass
set "PS_COMMAND=!POWERSHELL_CMD! -ExecutionPolicy Bypass -NoProfile -File %SCRIPT_NAME%"

REM Add command line parameters if provided (excluding quiet flags)
set "PS_PARAMS="
for %%i in (%*) do (
    if /i not "%%i"=="/Q" if /i not "%%i"=="-Q" if /i not "%%i"=="--quiet" (
        set "PS_PARAMS=!PS_PARAMS! %%i"
    )
)

if not "!PS_PARAMS!"=="" (
    set "PS_COMMAND=!PS_COMMAND!!PS_PARAMS!"
    echo Command line parameters detected:!PS_PARAMS!
    echo [%TIMESTAMP%] Command line parameters:!PS_PARAMS! >> "%LOG_FILE%"
)

echo.
echo Launching Green Commits Master Control System...
echo PowerShell Command: !PS_COMMAND!
echo.
echo [%TIMESTAMP%] Executing PowerShell command: !PS_COMMAND! >> "%LOG_FILE%"

REM Execute the PowerShell script
!PS_COMMAND!
set "EXIT_CODE=!errorlevel!"

REM Log execution result
echo.
if !EXIT_CODE! equ 0 (
    set "EXECUTION_SUCCESS=true"
    echo [%TIMESTAMP%] PowerShell script executed successfully ^(Exit Code: !EXIT_CODE!^) >> "%LOG_FILE%"
    echo SUCCESS: Green Commits Master Control System completed successfully.
) else (
    echo [%TIMESTAMP%] PowerShell script failed ^(Exit Code: !EXIT_CODE!^) >> "%LOG_FILE%"
    echo ERROR: Green Commits Master Control System failed with exit code: !EXIT_CODE!
    echo.
    echo Common solutions:
    echo   1. Check the PowerShell script for syntax errors
    echo   2. Verify GitHub token and configuration
    echo   3. Ensure Git is properly installed
    echo   4. Check network connectivity
    echo   5. Review the log files for detailed error information
)

echo.
echo ================================================================
echo                        EXECUTION SUMMARY
echo ================================================================
echo Script: %SCRIPT_NAME%
echo PowerShell: !POWERSHELL_CMD!
echo Exit Code: !EXIT_CODE!
echo Success: !EXECUTION_SUCCESS!
echo Log File: %LOG_FILE%
echo ================================================================

REM Log session end
echo [%TIMESTAMP%] Green Commits Master Control Launcher session ended >> "%LOG_FILE%"
echo [%TIMESTAMP%] Final exit code: !EXIT_CODE! >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM Pause for interactive use (unless running with /Q parameter for quiet mode)
echo.
if /i not "%1"=="/Q" (
    if /i not "%1"=="-Q" (
        if /i not "%1"=="--quiet" (
            echo Press any key to exit...
            pause >nul
        )
    )
)

REM Exit with the same code as the PowerShell script
exit /b !EXIT_CODE!

:error_exit
echo.
echo ================================================================
echo                           ERROR EXIT
echo ================================================================
echo The Green Commits Master Control Launcher encountered an error.
echo Please check the error messages above and the log file: %LOG_FILE%
echo ================================================================
echo.
echo [%TIMESTAMP%] Launcher exited with error >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

if /i not "%1"=="/Q" (
    if /i not "%1"=="-Q" (
        if /i not "%1"=="--quiet" (
            echo Press any key to exit...
            pause >nul
        )
    )
)

exit /b 1
