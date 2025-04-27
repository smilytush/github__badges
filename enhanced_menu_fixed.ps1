# Enhanced GitHub Workflow Menu
function Show-Menu {
    Clear-Host
    Write-Host "============= GITHUB WORKFLOW MENU =============" -ForegroundColor Cyan
    Write-Host "1: Show Dashboard" -ForegroundColor Green
    Write-Host "2: Run Morning Workflow (Simple Commits)" -ForegroundColor Yellow
    Write-Host "3: Run Afternoon Workflow (PRs, Issues, Reviews)" -ForegroundColor Yellow
    Write-Host "4: Update Commit Schedule (include today)" -ForegroundColor Yellow
    Write-Host "5: View Issues" -ForegroundColor Green
    Write-Host "6: View Pull Requests" -ForegroundColor Green
    Write-Host "7: Setup Task Scheduler (Twice Daily)" -ForegroundColor Yellow
    Write-Host "8: Open GitHub Repository" -ForegroundColor Green
    Write-Host "9: Clean Up Repository" -ForegroundColor Red
    Write-Host "Q: Quit" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Cyan
}

function Open-GitHub {
    $url = "https://github.com/smilytush/green-commits"
    Write-Host "Opening GitHub repository in your browser..." -ForegroundColor Cyan
    Start-Process $url
}

function View-Issues {
    $issuesDir = ".\issues"
    if (-not (Test-Path $issuesDir)) {
        Write-Host "No issues found. Run the afternoon workflow to create issues." -ForegroundColor Yellow
        return
    }
    
    $issueFiles = Get-ChildItem -Path $issuesDir -Filter "issue-*.md"
    if ($issueFiles.Count -eq 0) {
        Write-Host "No issues found. Run the afternoon workflow to create issues." -ForegroundColor Yellow
        return
    }
    
    Write-Host "Found $($issueFiles.Count) issues:" -ForegroundColor Cyan
    
    foreach ($issueFile in $issueFiles) {
        $content = Get-Content -Path $issueFile.FullName -Raw
        
        # Extract issue title
        if ($content -match "Issue: (.+)") {
            $title = $matches[1]
        } else {
            $title = "Unknown"
        }
        
        # Extract issue status
        if ($content -match "Status: (.+)") {
            $status = $matches[1]
        } else {
            $status = "Unknown"
        }
        
        # Extract issue ID
        if ($content -match "ID: (\d+)") {
            $id = $matches[1]
        } else {
            $id = "Unknown"
        }
        
        # Format output
        if ($status -eq "Open") {
            Write-Host "Issue #$id - $title" -ForegroundColor Yellow
            Write-Host "  Status: $status" -ForegroundColor Yellow
        } else {
            Write-Host "Issue #$id - $title" -ForegroundColor Green
            Write-Host "  Status: $status" -ForegroundColor Green
        }
        
        Write-Host "  File: $($issueFile.Name)" -ForegroundColor Gray
        Write-Host ""
    }
}

function View-PullRequests {
    $prDir = ".\pull-requests"
    if (-not (Test-Path $prDir)) {
        Write-Host "No pull requests found. Run the afternoon workflow to create pull requests." -ForegroundColor Yellow
        return
    }
    
    $prFiles = Get-ChildItem -Path $prDir -Filter "pr-*.md"
    if ($prFiles.Count -eq 0) {
        Write-Host "No pull requests found. Run the afternoon workflow to create pull requests." -ForegroundColor Yellow
        return
    }
    
    Write-Host "Found $($prFiles.Count) pull requests:" -ForegroundColor Cyan
    
    foreach ($prFile in $prFiles) {
        $content = Get-Content -Path $prFile.FullName -Raw
        
        # Extract PR title
        if ($content -match "Pull Request: (.+)") {
            $title = $matches[1]
        } else {
            $title = "Unknown"
        }
        
        # Extract PR status
        if ($content -match "Status: (.+)") {
            $status = $matches[1]
        } else {
            $status = "Unknown"
        }
        
        # Extract PR ID
        if ($content -match "PR ID: (\d+)") {
            $id = $matches[1]
        } else {
            $id = "Unknown"
        }
        
        # Extract related issue
        if ($content -match "Related Issue: #(\d+)") {
            $issueId = $matches[1]
        } else {
            $issueId = "None"
        }
        
        # Format output
        if ($status -eq "Open") {
            Write-Host "PR #$id - $title" -ForegroundColor Yellow
            Write-Host "  Status: $status" -ForegroundColor Yellow
        } else {
            Write-Host "PR #$id - $title" -ForegroundColor Green
            Write-Host "  Status: $status" -ForegroundColor Green
        }
        
        Write-Host "  Related Issue: #$issueId" -ForegroundColor Gray
        Write-Host "  File: $($prFile.Name)" -ForegroundColor Gray
        Write-Host ""
    }
}

function Clean-Repository {
    Write-Host "This will remove unused files and clean up the repository." -ForegroundColor Yellow
    Write-Host "The following files and directories will be kept:" -ForegroundColor Cyan
    Write-Host "- README.md" -ForegroundColor White
    Write-Host "- enhanced_workflow_final.ps1" -ForegroundColor White
    Write-Host "- enhanced_dashboard.ps1" -ForegroundColor White
    Write-Host "- enhanced_menu_fixed.ps1" -ForegroundColor White
    Write-Host "- activity.log" -ForegroundColor White
    Write-Host "- commit_schedule.txt" -ForegroundColor White
    Write-Host "- script_log.txt" -ForegroundColor White
    Write-Host "- dashboard.html" -ForegroundColor White
    Write-Host "- .gitignore" -ForegroundColor White
    Write-Host "- snippets/ directory" -ForegroundColor White
    Write-Host "- issues/ directory" -ForegroundColor White
    Write-Host "- pull-requests/ directory" -ForegroundColor White
    
    $confirmation = Read-Host "Do you want to proceed? (Y/N)"
    if ($confirmation -ne "Y" -and $confirmation -ne "y") {
        Write-Host "Cleanup cancelled." -ForegroundColor Yellow
        return
    }
    
    # List of essential files to keep
    $essentialFiles = @(
        "README.md",
        "enhanced_workflow_final.ps1",
        "enhanced_dashboard.ps1",
        "enhanced_menu_fixed.ps1",
        "activity.log",
        "commit_schedule.txt",
        "script_log.txt",
        "dashboard.html",
        ".gitignore",
        "github_workflow.bat"
    )
    
    # List of essential directories to keep
    $essentialDirs = @(
        "snippets",
        "issues",
        "pull-requests"
    )
    
    # Get all files in the repository
    $allFiles = Get-ChildItem -Path "." -File | Where-Object { 
        # Exclude files in .git directory
        $_.FullName -notmatch "\\\.git\\" 
    }
    
    # Files to remove
    $filesToRemove = @()
    
    # Check each file
    foreach ($file in $allFiles) {
        $fileName = $file.Name
        
        # Check if file is in the essential list
        if ($essentialFiles -notcontains $fileName) {
            $filesToRemove += $fileName
        }
    }
    
    # Display files to be removed
    if ($filesToRemove.Count -gt 0) {
        Write-Host "The following files will be removed:" -ForegroundColor Red
        foreach ($file in $filesToRemove) {
            Write-Host "- $file" -ForegroundColor Red
        }
        
        $confirmation = Read-Host "Confirm removal of these files? (Y/N)"
        if ($confirmation -eq "Y" -or $confirmation -eq "y") {
            foreach ($file in $filesToRemove) {
                Remove-Item -Path $file -Force
                Write-Host "Removed: $file" -ForegroundColor Gray
            }
            
            # Commit the changes
            git add -A
            git commit -m "Clean up repository and remove unused files"
            git push origin main
            
            Write-Host "Cleanup completed and changes pushed to GitHub." -ForegroundColor Green
        } else {
            Write-Host "File removal cancelled." -ForegroundColor Yellow
        }
    } else {
        Write-Host "No files to remove." -ForegroundColor Green
    }
    
    # Rename main script
    if (Test-Path "enhanced_workflow_final.ps1" -and -not (Test-Path "green_commit.ps1")) {
        Copy-Item "enhanced_workflow_final.ps1" "green_commit.ps1"
        Write-Host "Created green_commit.ps1 from enhanced_workflow_final.ps1" -ForegroundColor Green
        
        git add green_commit.ps1
        git commit -m "Add green_commit.ps1 for backward compatibility"
        git push origin main
    }
}

# Main loop
do {
    Show-Menu
    $choice = Read-Host "Enter your choice"
    
    switch ($choice) {
        '1' {
            Write-Host "Generating dashboard..." -ForegroundColor Cyan
            & .\enhanced_dashboard.ps1
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '2' {
            Write-Host "Running morning workflow (simple commits)..." -ForegroundColor Yellow
            
            # Set session to morning
            $env:WORKFLOW_SESSION = "morning"
            
            # Run the workflow script
            & .\enhanced_workflow_final.ps1
            
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '3' {
            Write-Host "Running afternoon workflow (PRs, issues, reviews)..." -ForegroundColor Yellow
            
            # Set session to afternoon
            $env:WORKFLOW_SESSION = "afternoon"
            
            # Run the workflow script
            & .\enhanced_workflow_final.ps1
            
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '4' {
            Write-Host "Updating commit schedule..." -ForegroundColor Yellow
            
            # Simple update schedule function
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
        '5' {
            Write-Host "Viewing issues..." -ForegroundColor Cyan
            View-Issues
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '6' {
            Write-Host "Viewing pull requests..." -ForegroundColor Cyan
            View-PullRequests
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '7' {
            Write-Host "Setting up Task Scheduler for twice daily workflow..." -ForegroundColor Yellow
            Write-Host "This requires administrator privileges." -ForegroundColor Red
            $runAsAdmin = Read-Host "Run as administrator? (Y/N)"
            if ($runAsAdmin -eq 'Y' -or $runAsAdmin -eq 'y') {
                Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PWD\setup_task_enhanced.ps1`"" -Verb RunAs
            }
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '8' {
            Open-GitHub
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '9' {
            Write-Host "Cleaning up repository..." -ForegroundColor Red
            Clean-Repository
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        'q' {
            return
        }
    }
} until ($choice -eq 'q')
