# Direct execution of the full historical backdating system
# This bypasses all test mode logic and runs the complete system

Write-Host "=== DIRECT FULL SYSTEM EXECUTION ===" -ForegroundColor Green
Write-Host "This will create commits for 779 days from November 1, 2022 to present" -ForegroundColor Yellow
Write-Host "Bypassing all test mode logic..." -ForegroundColor Cyan
Write-Host ""

# Set parameters explicitly
$Force = $false
$ValidateOnly = $false
$TestMode = $false
$DryRun = $false
$SkipConfirmation = $true

# Source the main script functions
. ".\enhanced_historical_system_v2.ps1"

# Override the TestMode parameter to ensure it's false
$global:TestMode = $false

Write-Host "TestMode is set to: $TestMode" -ForegroundColor Cyan
Write-Host "Starting direct execution..." -ForegroundColor Green

# Call the main function directly with explicit parameters
try {
    # Manually execute the main logic without going through parameter parsing
    Write-Host "Executing full historical system..." -ForegroundColor Green
    
    # This should execute the full system
    Start-EnhancedHistoricalSystem
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}
