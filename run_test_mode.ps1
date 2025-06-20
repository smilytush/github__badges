# PowerShell wrapper for running test mode
# This script provides easy access to test the backdating functionality

Write-Host "=== HISTORICAL BACKDATE SYSTEM - TEST MODE ===" -ForegroundColor Magenta
Write-Host ""
Write-Host "This will create 5 test backdated commits across different historical dates:" -ForegroundColor Cyan
Write-Host "- 2022-11-15 (Early historical period)" -ForegroundColor White
Write-Host "- 2023-03-10 (Q1 2023)" -ForegroundColor White
Write-Host "- 2023-08-20 (Q3 2023)" -ForegroundColor White
Write-Host "- 2024-01-05 (Q1 2024)" -ForegroundColor White
Write-Host "- Recent date (30 days ago)" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Choose an option: [1] Test GitHub API, [2] Run Test Mode, [3] Exit"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Running GitHub API test..." -ForegroundColor Yellow
        & "$PSScriptRoot\test_github_api.ps1"
    }
    "2" {
        Write-Host ""
        Write-Host "Running test mode..." -ForegroundColor Yellow
        & "$PSScriptRoot\test_backdate_system.ps1"
    }
    "3" {
        Write-Host "Exiting..." -ForegroundColor Yellow
        exit 0
    }
    default {
        Write-Host "Invalid choice. Please run the script again." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
