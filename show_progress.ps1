# This script shows the progress of the green-commits automation
# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# Path to schedule file
$scheduleFile = "$repoPath\commit_schedule.txt"
$activityLog = "$repoPath\activity.log"

# Check if files exist
if (-not (Test-Path $scheduleFile)) {
    Write-Host "Commit schedule not found. Please run green_commit.ps1 first." -ForegroundColor Red
    exit
}

# Get today's date
$today = Get-Date
$todayStr = $today.ToString("yyyy-MM-dd")

# Read the schedule
$commitDays = Get-Content $scheduleFile

# Count total scheduled days
$totalScheduledDays = $commitDays.Count
Write-Host "Total scheduled commit days: $totalScheduledDays" -ForegroundColor Cyan

# Count past scheduled days
$pastScheduledDays = ($commitDays | Where-Object { [DateTime]::Parse($_) -le $today }).Count
Write-Host "Scheduled commit days up to today: $pastScheduledDays" -ForegroundColor Cyan

# Count future scheduled days
$futureScheduledDays = ($commitDays | Where-Object { [DateTime]::Parse($_) -gt $today }).Count
Write-Host "Scheduled commit days in the future: $futureScheduledDays" -ForegroundColor Cyan

# Check if today is a commit day
$isTodayCommitDay = $commitDays -contains $todayStr
if ($isTodayCommitDay) {
    Write-Host "Today ($todayStr) is scheduled for a commit." -ForegroundColor Green
} else {
    Write-Host "Today ($todayStr) is not scheduled for a commit." -ForegroundColor Yellow
}

# Get the next 5 scheduled commit days
$nextCommitDays = $commitDays | Where-Object { [DateTime]::Parse($_) -ge $today } | Select-Object -First 5
Write-Host "`nNext scheduled commit days:" -ForegroundColor Cyan
foreach ($day in $nextCommitDays) {
    $daysUntil = ([DateTime]::Parse($day) - $today).Days
    if ($day -eq $todayStr) {
        Write-Host "- $day (Today!)" -ForegroundColor Green
    } else {
        Write-Host "- $day (in $daysUntil days)" -ForegroundColor White
    }
}

# Check activity log
Write-Host "`nActivity Log:" -ForegroundColor Cyan
if (Test-Path $activityLog) {
    $activityContent = Get-Content $activityLog
    $commitCount = ($activityContent | Where-Object { $_ -match "Update:" }).Count
    Write-Host "Total commits made: $commitCount" -ForegroundColor White
    
    # Show last 5 commits
    $lastCommits = $activityContent | Where-Object { $_ -match "Update:" } | Select-Object -Last 5
    if ($lastCommits.Count -gt 0) {
        Write-Host "Last commits:" -ForegroundColor White
        foreach ($commit in $lastCommits) {
            Write-Host "- $commit" -ForegroundColor Gray
        }
    } else {
        Write-Host "No commits found in the activity log." -ForegroundColor Yellow
    }
} else {
    Write-Host "Activity log not found." -ForegroundColor Yellow
}

# Check Task Scheduler status
Write-Host "`nTask Scheduler Status:" -ForegroundColor Cyan
$task = Get-ScheduledTask -TaskName "GitHub Green Commit" -ErrorAction SilentlyContinue
if ($task) {
    Write-Host "Task exists: Yes" -ForegroundColor Green
    Write-Host "Task state: $($task.State)" -ForegroundColor White
    Write-Host "Last run time: $($task.LastRunTime)" -ForegroundColor White
    Write-Host "Next run time: $($task.NextRunTime)" -ForegroundColor White
} else {
    Write-Host "Task exists: No" -ForegroundColor Red
    Write-Host "Please run setup_task_admin.bat to set up the task." -ForegroundColor Yellow
}

# Check if script has run today
$lastRunFile = "$repoPath\last_run.txt"
if (Test-Path $lastRunFile) {
    $lastRun = Get-Content $lastRunFile
    Write-Host "`nLast script run: $lastRun" -ForegroundColor White
    if ($lastRun -eq $todayStr) {
        Write-Host "Script has already run today." -ForegroundColor Green
    } else {
        Write-Host "Script has not run today yet." -ForegroundColor Yellow
    }
} else {
    Write-Host "`nScript has not run yet or last_run.txt is missing." -ForegroundColor Yellow
}

Write-Host "`nTo manually run the script, execute: .\green_commit.ps1" -ForegroundColor Cyan
