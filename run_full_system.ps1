# Run the full historical backdating system
# This script bypasses test mode and runs the complete system

Write-Host "Starting Full Historical Backdating System..." -ForegroundColor Green
Write-Host "This will create commits for 779 days from November 1, 2022 to present" -ForegroundColor Yellow
Write-Host ""

# Confirm with user
$confirmation = Read-Host "Are you sure you want to proceed with the FULL system? (yes/no)"

if ($confirmation.ToLower() -eq "yes" -or $confirmation.ToLower() -eq "y") {
    Write-Host "Starting full execution..." -ForegroundColor Green
    
    # Run the script with explicit parameters to avoid test mode
    & ".\enhanced_historical_system_v2.ps1" -Force:$false -ValidateOnly:$false -TestMode:$false -DryRun:$false -SkipConfirmation:$true
}
else {
    Write-Host "Execution cancelled by user." -ForegroundColor Red
}
