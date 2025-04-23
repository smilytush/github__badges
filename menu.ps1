# Green Commits Menu
function Show-Menu {
    Clear-Host
    Write-Host "================ GREEN COMMITS MENU ================" -ForegroundColor Cyan
    Write-Host "1: Show Progress and Status" -ForegroundColor Green
    Write-Host "2: Generate Dashboard" -ForegroundColor Green
    Write-Host "3: Update Commit Schedule (include today)" -ForegroundColor Yellow
    Write-Host "4: Force a Commit Now" -ForegroundColor Yellow
    Write-Host "5: Run Normal Commit Script" -ForegroundColor Green
    Write-Host "6: Setup Task Scheduler" -ForegroundColor Yellow
    Write-Host "7: Open GitHub Repository" -ForegroundColor Green
    Write-Host "Q: Quit" -ForegroundColor Red
    Write-Host "=================================================" -ForegroundColor Cyan
}

function Open-GitHub {
    $url = "https://github.com/smilytush/green-commits"
    Write-Host "Opening GitHub repository in your browser..." -ForegroundColor Cyan
    Start-Process $url
}

# Main loop
do {
    Show-Menu
    $choice = Read-Host "Enter your choice"
    
    switch ($choice) {
        '1' {
            Write-Host "Running progress check..." -ForegroundColor Cyan
            & .\show_progress.ps1
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '2' {
            Write-Host "Generating dashboard..." -ForegroundColor Cyan
            & .\dashboard.ps1
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '3' {
            Write-Host "Updating commit schedule..." -ForegroundColor Yellow
            & .\update_schedule.ps1
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '4' {
            Write-Host "Forcing a commit now..." -ForegroundColor Yellow
            & .\force_commit.ps1
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '5' {
            Write-Host "Running normal commit script..." -ForegroundColor Green
            & .\green_commit.ps1
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '6' {
            Write-Host "Setting up Task Scheduler..." -ForegroundColor Yellow
            Write-Host "This requires administrator privileges." -ForegroundColor Red
            $runAsAdmin = Read-Host "Run as administrator? (Y/N)"
            if ($runAsAdmin -eq 'Y' -or $runAsAdmin -eq 'y') {
                Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PWD\setup_task.ps1`"" -Verb RunAs
            }
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '7' {
            Open-GitHub
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        'q' {
            return
        }
    }
} until ($choice -eq 'q')
