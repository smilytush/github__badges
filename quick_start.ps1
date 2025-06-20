# Quick Start Script for Enhanced Historical Backdate System
# Provides easy access to all functionality from PowerShell

Write-Host "=== ENHANCED HISTORICAL BACKDATED GITHUB COMMIT SYSTEM ===" -ForegroundColor Magenta
Write-Host "Quick Start Menu" -ForegroundColor Cyan
Write-Host ""

Write-Host "Available Options:" -ForegroundColor Yellow
Write-Host "1. Test GitHub API Access" -ForegroundColor White
Write-Host "2. Run Test Mode (5 sample commits)" -ForegroundColor White
Write-Host "3. Run Full Historical System (Nov 2022 - Present)" -ForegroundColor White
Write-Host "4. Verify Contribution Graph" -ForegroundColor White
Write-Host "5. Show Execution Plan" -ForegroundColor White
Write-Host "6. Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-6)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Testing GitHub API access..." -ForegroundColor Yellow
        & "$PSScriptRoot\test_github_api.ps1"
    }
    "2" {
        Write-Host ""
        Write-Host "Running test mode..." -ForegroundColor Yellow
        & "$PSScriptRoot\test_backdate_system.ps1"
    }
    "3" {
        Write-Host ""
        Write-Host "WARNING: This will create thousands of backdated commits!" -ForegroundColor Red
        $confirm = Read-Host "Are you sure you want to proceed? (yes/no)"
        if ($confirm.ToLower() -eq "yes" -or $confirm.ToLower() -eq "y") {
            & "$PSScriptRoot\run_enhanced_historical_system.ps1"
        } else {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
        }
    }
    "4" {
        Write-Host ""
        Write-Host "Verifying contribution graph..." -ForegroundColor Yellow
        & "$PSScriptRoot\verify_contribution_graph.ps1" -DetailedReport
    }
    "5" {
        Write-Host ""
        Write-Host "Showing execution plan..." -ForegroundColor Yellow
        & "$PSScriptRoot\show_execution_plan.ps1"
    }
    "6" {
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
