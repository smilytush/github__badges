# Green Commits Menu
function Show-Menu {
    Clear-Host
    Write-Host "================ GREEN COMMITS MENU ================" -ForegroundColor Cyan
    Write-Host "1: Show Progress and Status" -ForegroundColor Green
    Write-Host "2: Generate Dashboard" -ForegroundColor Green
    Write-Host "3: Update Commit Schedule (include today)" -ForegroundColor Yellow
    Write-Host "4: Force a Commit Now" -ForegroundColor Yellow
    Write-Host "5: Run Normal Commit Script" -ForegroundColor Green
    Write-Host "6: Setup Task Scheduler (Twice Daily)" -ForegroundColor Yellow
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
            # Create a simple progress check
            $today = Get-Date
            $todayStr = $today.ToString("yyyy-MM-dd")
            
            # Check if today is in the schedule
            $scheduleFile = ".\commit_schedule.txt"
            if (Test-Path $scheduleFile) {
                $commitDays = Get-Content $scheduleFile
                $isTodayCommitDay = $commitDays -contains $todayStr
                
                Write-Host "Today: $todayStr" -ForegroundColor White
                if ($isTodayCommitDay) {
                    Write-Host "Today is scheduled for commits." -ForegroundColor Green
                } else {
                    Write-Host "Today is not scheduled for commits." -ForegroundColor Yellow
                }
                
                # Check last run
                $lastRunFile = ".\last_run.txt"
                if (Test-Path $lastRunFile) {
                    $lastRun = Get-Content $lastRunFile
                    Write-Host "Last run: $lastRun" -ForegroundColor White
                } else {
                    Write-Host "No previous runs recorded." -ForegroundColor Yellow
                }
                
                # Check activity log
                $activityLog = ".\activity.log"
                if (Test-Path $activityLog) {
                    $activityContent = Get-Content $activityLog
                    $commitCount = ($activityContent | Where-Object { $_ -match "Update" }).Count
                    Write-Host "Total commits made: $commitCount" -ForegroundColor White
                    
                    # Show last 3 commits
                    $lastCommits = $activityContent | Where-Object { $_ -match "Update" } | Select-Object -Last 3
                    if ($lastCommits.Count -gt 0) {
                        Write-Host "Last commits:" -ForegroundColor White
                        foreach ($commit in $lastCommits) {
                            Write-Host "- $commit" -ForegroundColor Gray
                        }
                    }
                } else {
                    Write-Host "No activity log found." -ForegroundColor Yellow
                }
            } else {
                Write-Host "Commit schedule not found. Please run the script first." -ForegroundColor Red
            }
            
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
            # Create a simple update schedule function
            $scheduleFile = ".\commit_schedule.txt"
            $today = Get-Date
            $todayStr = $today.ToString("yyyy-MM-dd")
            
            if (Test-Path $scheduleFile) {
                # Backup the old schedule
                Copy-Item $scheduleFile "$scheduleFile.bak"
                Write-Host "Backed up existing schedule to $scheduleFile.bak" -ForegroundColor Gray
                
                # Read the schedule
                $commitDays = Get-Content $scheduleFile
                
                # Check if today is already in the schedule
                if ($commitDays -contains $todayStr) {
                    Write-Host "Today ($todayStr) is already in the schedule." -ForegroundColor Green
                } else {
                    # Add today to the schedule
                    $commitDays += $todayStr
                    $commitDays | Sort-Object | Set-Content $scheduleFile
                    Write-Host "Added today ($todayStr) to the schedule." -ForegroundColor Green
                }
                
                # Remove the last_run.txt file to allow the script to run today
                if (Test-Path ".\last_run.txt") {
                    Remove-Item ".\last_run.txt" -Force
                    Write-Host "Removed last_run.txt to allow script to run today" -ForegroundColor Gray
                }
            } else {
                Write-Host "Commit schedule not found. Creating new schedule..." -ForegroundColor Yellow
                
                $daysToPick = 280
                $totalDays = 365
                
                $dates = 1..$totalDays | ForEach-Object { $today.AddDays($_).ToString("yyyy-MM-dd") }
                $selectedDates = $dates | Get-Random -Count $daysToPick
                
                # Make sure today is included
                if (-not ($selectedDates -contains $todayStr)) {
                    $selectedDates += $todayStr
                }
                
                $selectedDates | Sort-Object | Set-Content $scheduleFile
                Write-Host "Created new commit schedule with $($selectedDates.Count) days" -ForegroundColor Green
                Write-Host "Today ($todayStr) is included in the schedule." -ForegroundColor Green
            }
            
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
            Write-Host "Setting up Task Scheduler for twice daily commits..." -ForegroundColor Yellow
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
