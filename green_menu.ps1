# Green GitHub Workflow Menu
function Show-Menu {
    Clear-Host
    Write-Host "============= GREEN GITHUB WORKFLOW =============" -ForegroundColor Green
    Write-Host "1: Show Dashboard" -ForegroundColor Green
    Write-Host "2: Run Morning Workflow (Simple Commits)" -ForegroundColor Yellow
    Write-Host "3: Run Afternoon Workflow (PRs, Issues, Reviews)" -ForegroundColor Yellow
    Write-Host "4: Optimize for Maximum Green" -ForegroundColor Cyan
    Write-Host "5: View Commit Schedule" -ForegroundColor Green
    Write-Host "6: View Issues and Pull Requests" -ForegroundColor Green
    Write-Host "7: Setup Task Scheduler (Twice Daily)" -ForegroundColor Yellow
    Write-Host "8: Open GitHub Repository" -ForegroundColor Green
    Write-Host "9: Clean Up Repository" -ForegroundColor Red
    Write-Host "Q: Quit" -ForegroundColor Red
    Write-Host "=================================================" -ForegroundColor Green
}

function Open-GitHub {
    $url = "https://github.com/smilytush/green-commits"
    Write-Host "Opening GitHub repository in your browser..." -ForegroundColor Cyan
    Start-Process $url
}

function View-CommitSchedule {
    $scheduleFile = ".\commit_schedule.txt"
    $intensityFile = ".\commit_intensity.txt"
    
    if (-not (Test-Path $scheduleFile)) {
        Write-Host "Commit schedule not found. Run the green optimizer first." -ForegroundColor Yellow
        return
    }
    
    $commitDays = Get-Content $scheduleFile
    $today = Get-Date
    $todayStr = $today.ToString("yyyy-MM-dd")
    
    Write-Host "Commit Schedule Overview:" -ForegroundColor Cyan
    Write-Host "Total scheduled days: $($commitDays.Count)" -ForegroundColor White
    Write-Host "Today ($todayStr) is $(if ($commitDays -contains $todayStr) { 'scheduled for commits' } else { 'not scheduled for commits' })" -ForegroundColor $(if ($commitDays -contains $todayStr) { 'Green' } else { 'Yellow' })
    
    # Get intensity map if available
    $intensityMap = @{}
    if (Test-Path $intensityFile) {
        Get-Content $intensityFile | ForEach-Object {
            $parts = $_ -split ","
            if ($parts.Count -eq 2) {
                $intensityMap[$parts[0]] = [int]$parts[1]
            }
        }
        
        if ($intensityMap.ContainsKey($todayStr)) {
            $todayIntensity = $intensityMap[$todayStr]
            Write-Host "Today's commit intensity: $todayIntensity ($(Get-GreenLevelDescription $todayIntensity))" -ForegroundColor $(Get-ColorForIntensity $todayIntensity)
        }
        
        # Show intensity distribution
        $intensityDistribution = @{
            1 = 0
            2 = 0
            3 = 0
            4 = 0
            5 = 0
        }
        
        foreach ($intensity in $intensityMap.Values) {
            $intensityDistribution[$intensity] += 1
        }
        
        Write-Host "`nCommit intensity distribution:" -ForegroundColor Cyan
        foreach ($level in 1..5) {
            $count = $intensityDistribution[$level]
            $percentage = [Math]::Round(($count / $commitDays.Count) * 100, 1)
            Write-Host "  Level $level ($(Get-GreenLevelDescription $level)): $count days ($percentage%)" -ForegroundColor $(Get-ColorForIntensity $level)
        }
    }
    
    # Show upcoming commit days
    Write-Host "`nUpcoming commit days:" -ForegroundColor Cyan
    $upcomingDays = $commitDays | Where-Object { [DateTime]::Parse($_) -ge $today } | Select-Object -First 10
    
    foreach ($day in $upcomingDays) {
        $daysUntil = ([DateTime]::Parse($day) - $today).Days
        $intensity = if ($intensityMap.ContainsKey($day)) { $intensityMap[$day] } else { 1 }
        
        if ($day -eq $todayStr) {
            Write-Host "  $day (Today!) - $intensity commits ($(Get-GreenLevelDescription $intensity))" -ForegroundColor Green
        } else {
            Write-Host "  $day (in $daysUntil days) - $intensity commits ($(Get-GreenLevelDescription $intensity))" -ForegroundColor White
        }
    }
}

function View-GitHubActivity {
    # View Issues
    $issuesDir = ".\issues"
    if (Test-Path $issuesDir) {
        $issueFiles = Get-ChildItem -Path $issuesDir -Filter "issue-*.md"
        $issueCount = $issueFiles.Count
        
        Write-Host "Issues: $issueCount total" -ForegroundColor Cyan
        
        $openIssues = 0
        $closedIssues = 0
        
        foreach ($issueFile in $issueFiles) {
            $content = Get-Content -Path $issueFile.FullName -Raw
            if ($content -match "Status: Open") {
                $openIssues++
            } else {
                $closedIssues++
            }
        }
        
        Write-Host "  Open issues: $openIssues" -ForegroundColor Yellow
        Write-Host "  Closed issues: $closedIssues" -ForegroundColor Green
        
        # Show latest issue
        if ($issueFiles.Count -gt 0) {
            $latestIssue = $issueFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            $content = Get-Content -Path $latestIssue.FullName -Raw
            
            if ($content -match "Issue: (.+)") {
                $title = $matches[1]
                Write-Host "`nLatest issue: $title" -ForegroundColor White
            }
        }
    } else {
        Write-Host "No issues found." -ForegroundColor Yellow
    }
    
    # View Pull Requests
    $prDir = ".\pull-requests"
    if (Test-Path $prDir) {
        $prFiles = Get-ChildItem -Path $prDir -Filter "pr-*.md"
        $prCount = $prFiles.Count
        
        Write-Host "`nPull Requests: $prCount total" -ForegroundColor Cyan
        
        $openPRs = 0
        $mergedPRs = 0
        
        foreach ($prFile in $prFiles) {
            $content = Get-Content -Path $prFile.FullName -Raw
            if ($content -match "Status: Open") {
                $openPRs++
            } else {
                $mergedPRs++
            }
        }
        
        Write-Host "  Open PRs: $openPRs" -ForegroundColor Yellow
        Write-Host "  Merged PRs: $mergedPRs" -ForegroundColor Green
        
        # Show latest PR
        if ($prFiles.Count -gt 0) {
            $latestPR = $prFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            $content = Get-Content -Path $latestPR.FullName -Raw
            
            if ($content -match "Pull Request: (.+)") {
                $title = $matches[1]
                Write-Host "`nLatest PR: $title" -ForegroundColor White
            }
        }
    } else {
        Write-Host "`nNo pull requests found." -ForegroundColor Yellow
    }
    
    # View Activity Log
    $activityLog = ".\activity.log"
    if (Test-Path $activityLog) {
        $activities = Get-Content $activityLog
        $activityCount = $activities.Count
        
        Write-Host "`nActivity Log: $activityCount total activities" -ForegroundColor Cyan
        
        # Show latest activities
        if ($activityCount -gt 0) {
            Write-Host "`nLatest activities:" -ForegroundColor White
            $activities | Select-Object -Last 5 | ForEach-Object {
                Write-Host "  $_" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "`nNo activity log found." -ForegroundColor Yellow
    }
}

function Clean-Repository {
    Write-Host "This will remove unused files and clean up the repository." -ForegroundColor Yellow
    Write-Host "The following files and directories will be kept:" -ForegroundColor Cyan
    Write-Host "- README.md" -ForegroundColor White
    Write-Host "- green_workflow.ps1" -ForegroundColor White
    Write-Host "- green_optimizer.ps1" -ForegroundColor White
    Write-Host "- enhanced_dashboard.ps1" -ForegroundColor White
    Write-Host "- green_menu.ps1" -ForegroundColor White
    Write-Host "- activity.log" -ForegroundColor White
    Write-Host "- commit_schedule.txt" -ForegroundColor White
    Write-Host "- commit_intensity.txt" -ForegroundColor White
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
        "green_workflow.ps1",
        "green_optimizer.ps1",
        "enhanced_dashboard.ps1",
        "green_menu.ps1",
        "activity.log",
        "commit_schedule.txt",
        "commit_intensity.txt",
        "script_log.txt",
        "dashboard.html",
        ".gitignore",
        "green_github.bat"
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
}

# Helper function to describe green levels
function Get-GreenLevelDescription {
    param(
        [int]$Level
    )
    
    switch ($Level) {
        1 { "Light green" }
        2 { "Medium-light green" }
        3 { "Medium green" }
        4 { "Medium-dark green" }
        5 { "Dark green" }
        default { "Unknown" }
    }
}

# Helper function to get color for intensity
function Get-ColorForIntensity {
    param(
        [int]$Level
    )
    
    switch ($Level) {
        1 { "Gray" }
        2 { "White" }
        3 { "Cyan" }
        4 { "Yellow" }
        5 { "Green" }
        default { "White" }
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
            & .\green_workflow.ps1
            
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '3' {
            Write-Host "Running afternoon workflow (PRs, issues, reviews)..." -ForegroundColor Yellow
            
            # Set session to afternoon
            $env:WORKFLOW_SESSION = "afternoon"
            
            # Run the workflow script
            & .\green_workflow.ps1
            
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '4' {
            Write-Host "Optimizing for maximum green..." -ForegroundColor Cyan
            & .\green_optimizer.ps1
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '5' {
            Write-Host "Viewing commit schedule..." -ForegroundColor Cyan
            View-CommitSchedule
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        '6' {
            Write-Host "Viewing GitHub activity..." -ForegroundColor Cyan
            View-GitHubActivity
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
