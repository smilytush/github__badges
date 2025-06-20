# Force Full System Execution
# This script forces the full historical backdating system to run

Write-Host "=== FORCING FULL HISTORICAL SYSTEM EXECUTION ===" -ForegroundColor Green
Write-Host "This will create commits for 779 days from November 1, 2022 to present" -ForegroundColor Yellow
Write-Host "Bypassing ALL test mode logic..." -ForegroundColor Cyan
Write-Host ""

# Set environment variable to force full mode
$env:FORCE_FULL_MODE = "true"

Write-Host "Environment variable FORCE_FULL_MODE set to: $env:FORCE_FULL_MODE" -ForegroundColor Cyan
Write-Host ""

# Confirm with user one more time
$confirmation = Read-Host "Are you absolutely sure you want to create 779 days of backdated commits? This will take a while and significantly modify your GitHub contribution graph. (yes/no)"

if ($confirmation.ToLower() -eq "yes" -or $confirmation.ToLower() -eq "y") {
    Write-Host "Starting full execution..." -ForegroundColor Green
    Write-Host ""
    
    # Run the script with explicit parameters
    & ".\enhanced_historical_system_v2.ps1" -SkipConfirmation:$true -TestMode:$false -Force:$false
}
else {
    Write-Host "Execution cancelled by user." -ForegroundColor Red
}

# Clean up environment variable
$env:FORCE_FULL_MODE = $null
