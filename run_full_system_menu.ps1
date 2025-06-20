# Interactive Menu for Full Historical Backdate System
# More reliable than batch file for input handling

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

function Write-MenuLog {
    param([string]$Message, [string]$Level = "INFO")
    $colors = @{"INFO"="Cyan"; "SUCCESS"="Green"; "ERROR"="Red"; "WARNING"="Yellow"; "HEADER"="Magenta"}
    Write-Host $Message -ForegroundColor $colors[$Level]
}

Write-MenuLog "===============================================" "HEADER"
Write-MenuLog "Enhanced Historical Backdate System Menu" "HEADER"
Write-MenuLog "===============================================" "HEADER"
Write-Host ""

Write-MenuLog "This system creates backdated GitHub commits to fill your contribution graph." "INFO"
Write-Host ""

Write-MenuLog "GitHub Target: smilytush/github-commits" "INFO"
Write-MenuLog "Period: November 1st, 2022 to Present" "INFO"
Write-MenuLog "Coverage: 82% of all days" "INFO"
Write-Host ""

Write-MenuLog "Choose your option:" "INFO"
Write-Host "1. Quick Test Mode (5 sample commits - fastest)" -ForegroundColor White
Write-Host "2. Validation Only (Check everything works)" -ForegroundColor White
Write-Host "3. Full System (Create all historical commits)" -ForegroundColor White
Write-Host "4. Exit" -ForegroundColor White
Write-Host ""

do {
    $choice = Read-Host "Enter your choice (1-4)"
    
    switch ($choice) {
        "1" {
            Write-Host ""
            Write-MenuLog "Running quick test mode..." "SUCCESS"
            & ".\quick_test_mode.ps1"
            break
        }
        "2" {
            Write-Host ""
            Write-MenuLog "Running validation only..." "SUCCESS"
            & ".\run_foolproof_system.ps1" -ValidateOnly
            break
        }
        "3" {
            Write-Host ""
            Write-MenuLog "*** WARNING ***" "ERROR"
            Write-MenuLog "This will create thousands of backdated commits!" "WARNING"
            Write-MenuLog "This process may take 30-60 minutes to complete." "WARNING"
            Write-Host ""
            
            do {
                $confirm = Read-Host "Are you sure? Type YES to continue, NO to cancel"
                $confirm = $confirm.ToUpper().Trim()
                
                if ($confirm -eq "YES") {
                    Write-Host ""
                    Write-MenuLog "Starting full system execution..." "SUCCESS"
                    & ".\run_foolproof_system.ps1" -Force
                    break
                }
                elseif ($confirm -eq "NO") {
                    Write-MenuLog "Operation cancelled by user." "WARNING"
                    break
                }
                else {
                    Write-MenuLog "Please type YES or NO" "ERROR"
                }
            } while ($true)
            break
        }
        "4" {
            Write-MenuLog "Exiting..." "INFO"
            exit 0
        }
        default {
            Write-MenuLog "Invalid choice. Please enter 1, 2, 3, or 4." "ERROR"
        }
    }
    
    if ($choice -in @("1", "2", "3", "4")) {
        break
    }
} while ($true)

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
