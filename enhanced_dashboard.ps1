# This script generates an HTML dashboard to visualize GitHub workflow activities
# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# Path to schedule file
$scheduleFile = "$repoPath\commit_schedule.txt"
$activityLog = "$repoPath\activity.log"
$dashboardFile = "$repoPath\dashboard.html"

# Check if files exist
if (-not (Test-Path $scheduleFile)) {
    Write-Host "Commit schedule not found. Please run enhanced_workflow.ps1 first." -ForegroundColor Red
    exit
}

# Get today's date
$today = Get-Date
$todayStr = $today.ToString("yyyy-MM-dd")

# Read the schedule
$commitDays = Get-Content $scheduleFile

# Count total scheduled days
$totalScheduledDays = $commitDays.Count

# Count past scheduled days
$pastScheduledDays = ($commitDays | Where-Object { [DateTime]::Parse($_) -le $today }).Count

# Count future scheduled days
$futureScheduledDays = ($commitDays | Where-Object { [DateTime]::Parse($_) -gt $today }).Count

# Check if today is a commit day
$isTodayCommitDay = $commitDays -contains $todayStr

# Get the next 5 scheduled commit days
$nextCommitDays = $commitDays | Where-Object { [DateTime]::Parse($_) -ge $today } | Select-Object -First 5

# Check activity log
$commitCount = 0
$morningCommits = 0
$afternoonCommits = 0
$workflowCount = 0
$lastCommits = @()
if (Test-Path $activityLog) {
    $activityContent = Get-Content $activityLog
    $commitEntries = $activityContent | Where-Object { $_ -match "Update|Commit|Workflow" }
    $commitCount = $commitEntries.Count
    $morningCommits = ($commitEntries | Where-Object { $_ -match "morning" }).Count
    $afternoonCommits = ($commitEntries | Where-Object { $_ -match "afternoon" }).Count
    $workflowCount = ($commitEntries | Where-Object { $_ -match "Workflow" }).Count
    $lastCommits = $commitEntries | Select-Object -Last 5
}

# Check Task Scheduler status
$morningTaskExists = $false
$morningTaskState = "Unknown"
$morningLastRunTime = "Never"
$morningNextRunTime = "Unknown"

$afternoonTaskExists = $false
$afternoonTaskState = "Unknown"
$afternoonLastRunTime = "Never"
$afternoonNextRunTime = "Unknown"

$morningTask = Get-ScheduledTask -TaskName "GitHub Green Commit - Morning" -ErrorAction SilentlyContinue
if ($morningTask) {
    $morningTaskExists = $true
    $morningTaskState = $morningTask.State
    $morningLastRunTime = $morningTask.LastRunTime
    $morningNextRunTime = $morningTask.NextRunTime
}

$afternoonTask = Get-ScheduledTask -TaskName "GitHub Green Commit - Afternoon" -ErrorAction SilentlyContinue
if ($afternoonTask) {
    $afternoonTaskExists = $true
    $afternoonTaskState = $afternoonTask.State
    $afternoonLastRunTime = $afternoonTask.LastRunTime
    $afternoonNextRunTime = $afternoonTask.NextRunTime
}

# Check if script has run today
$hasRunMorning = $false
$hasRunAfternoon = $false
$lastRunFile = "$repoPath\last_run.txt"
$lastRunInfo = "Never"
if (Test-Path $lastRunFile) {
    $lastRunContent = Get-Content $lastRunFile
    $lastRunInfo = $lastRunContent
    
    $lastRunParts = $lastRunContent -split "::"
    if ($lastRunParts.Count -eq 2) {
        $lastRunDate = $lastRunParts[0]
        $lastRunSession = $lastRunParts[1]
        
        if ($lastRunDate -eq $todayStr) {
            if ($lastRunSession -eq "morning") {
                $hasRunMorning = $true
            } elseif ($lastRunSession -eq "afternoon") {
                $hasRunAfternoon = $true
            }
        }
    }
}

# Check for code snippets
$hasCodeSnippets = Test-Path "$repoPath\snippets"
$snippetFiles = @()
if ($hasCodeSnippets) {
    $snippetFiles = Get-ChildItem -Path "$repoPath\snippets" -File | Select-Object -ExpandProperty Name
}

# Check for issues and pull requests
$issueCount = 0
$openIssueCount = 0
$closedIssueCount = 0
$prCount = 0
$openPrCount = 0
$mergedPrCount = 0
$lastIssue = "None"
$lastPr = "None"

$issuesDir = "$repoPath\issues"
if (Test-Path $issuesDir) {
    $issueFiles = Get-ChildItem -Path $issuesDir -Filter "issue-*.md"
    $issueCount = $issueFiles.Count
    
    foreach ($issueFile in $issueFiles) {
        $content = Get-Content -Path $issueFile.FullName -Raw
        if ($content -match "Status: Open") {
            $openIssueCount++
        } else {
            $closedIssueCount++
        }
    }
    
    if ($issueFiles.Count -gt 0) {
        $lastIssueFile = $issueFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $lastIssueContent = Get-Content -Path $lastIssueFile.FullName -Raw
        if ($lastIssueContent -match "Issue: (.+)") {
            $lastIssue = $matches[1]
        }
    }
}

$prDir = "$repoPath\pull-requests"
if (Test-Path $prDir) {
    $prFiles = Get-ChildItem -Path $prDir -Filter "pr-*.md"
    $prCount = $prFiles.Count
    
    foreach ($prFile in $prFiles) {
        $content = Get-Content -Path $prFile.FullName -Raw
        if ($content -match "Status: Open") {
            $openPrCount++
        } else {
            $mergedPrCount++
        }
    }
    
    if ($prFiles.Count -gt 0) {
        $lastPrFile = $prFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $lastPrContent = Get-Content -Path $lastPrFile.FullName -Raw
        if ($lastPrContent -match "Pull Request: (.+)") {
            $lastPr = $matches[1]
        }
    }
}

# Generate HTML
$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GitHub Workflow Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
            color: #333;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        .card {
            background-color: white;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .card h2 {
            margin-top: 0;
            color: #2c3e50;
        }
        .stats {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
        }
        .stat-box {
            background-color: #f8f9fa;
            border-left: 4px solid #3498db;
            padding: 10px;
            margin-bottom: 10px;
            flex-basis: 48%;
        }
        .stat-box.highlight {
            border-left-color: #e74c3c;
        }
        .stat-box h3 {
            margin-top: 0;
            font-size: 14px;
            color: #7f8c8d;
        }
        .stat-box p {
            margin-bottom: 0;
            font-size: 24px;
            font-weight: bold;
            color: #2c3e50;
        }
        .progress-bar {
            height: 20px;
            background-color: #ecf0f1;
            border-radius: 10px;
            margin-bottom: 20px;
            overflow: hidden;
        }
        .progress {
            height: 100%;
            background-color: #3498db;
            width: 0%;
        }
        .schedule-list {
            list-style-type: none;
            padding: 0;
        }
        .schedule-list li {
            padding: 8px 0;
            border-bottom: 1px solid #ecf0f1;
        }
        .schedule-list li:last-child {
            border-bottom: none;
        }
        .today {
            background-color: #e8f4f8;
            padding: 5px;
            border-radius: 3px;
        }
        .status {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
        }
        .status.green {
            background-color: #2ecc71;
            color: white;
        }
        .status.yellow {
            background-color: #f1c40f;
            color: white;
        }
        .status.red {
            background-color: #e74c3c;
            color: white;
        }
        .footer {
            text-align: center;
            margin-top: 20px;
            color: #7f8c8d;
            font-size: 12px;
        }
        .commit-list {
            list-style-type: none;
            padding: 0;
        }
        .commit-list li {
            padding: 8px 0;
            border-bottom: 1px solid #ecf0f1;
        }
        .file-list {
            list-style-type: none;
            padding: 0;
        }
        .file-list li {
            padding: 5px 10px;
            margin-bottom: 5px;
            background-color: #f8f9fa;
            border-radius: 3px;
            font-family: monospace;
        }
        .session-box {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
        }
        .session {
            flex-basis: 48%;
            padding: 10px;
            border-radius: 5px;
            background-color: #f8f9fa;
        }
        .workflow-stats {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            margin-bottom: 15px;
        }
        .workflow-box {
            flex-basis: 31%;
            padding: 10px;
            border-radius: 5px;
            background-color: #f8f9fa;
            margin-bottom: 10px;
            text-align: center;
        }
        .workflow-box h3 {
            margin-top: 0;
            font-size: 14px;
            color: #7f8c8d;
        }
        .workflow-box p {
            margin-bottom: 0;
            font-size: 24px;
            font-weight: bold;
            color: #2c3e50;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>GitHub Workflow Dashboard</h1>
        
        <div class="card">
            <h2>Overview</h2>
            <div class="stats">
                <div class="stat-box">
                    <h3>Total Scheduled Days</h3>
                    <p>$totalScheduledDays</p>
                </div>
                <div class="stat-box highlight">
                    <h3>Total Activities</h3>
                    <p>$commitCount</p>
                </div>
                <div class="stat-box">
                    <h3>Morning Commits</h3>
                    <p>$morningCommits</p>
                </div>
                <div class="stat-box">
                    <h3>Afternoon Workflows</h3>
                    <p>$workflowCount</p>
                </div>
            </div>
            
            <h3>Progress</h3>
            <div class="progress-bar">
                <div class="progress" style="width: $(($commitCount / ($totalScheduledDays * 2)) * 100)%;"></div>
            </div>
            <p>$commitCount out of $($totalScheduledDays * 2) potential activities completed ($(($commitCount / ($totalScheduledDays * 2)) * 100)%)</p>
        </div>
        
        <div class="card">
            <h2>GitHub Workflow Statistics</h2>
            <div class="workflow-stats">
                <div class="workflow-box">
                    <h3>Issues</h3>
                    <p>$issueCount</p>
                    <div>Open: $openIssueCount | Closed: $closedIssueCount</div>
                </div>
                <div class="workflow-box">
                    <h3>Pull Requests</h3>
                    <p>$prCount</p>
                    <div>Open: $openPrCount | Merged: $mergedPrCount</div>
                </div>
                <div class="workflow-box">
                    <h3>Code Reviews</h3>
                    <p>$mergedPrCount</p>
                </div>
            </div>
            
            <div class="session-box">
                <div class="session">
                    <h3>Latest Issue</h3>
                    <p>$lastIssue</p>
                </div>
                <div class="session">
                    <h3>Latest Pull Request</h3>
                    <p>$lastPr</p>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h2>Today's Status</h2>
            <p>Date: <strong>$todayStr</strong></p>
            <p>
                Scheduled for activity today: 
                $(if ($isTodayCommitDay) {
                    '<span class="status green">Yes</span>'
                } else {
                    '<span class="status yellow">No</span>'
                })
            </p>
            
            <div class="session-box">
                <div class="session">
                    <h3>Morning Session (Commits)</h3>
                    <p>
                        Script has run: 
                        $(if ($hasRunMorning) {
                            '<span class="status green">Yes</span>'
                        } else {
                            '<span class="status yellow">No</span>'
                        })
                    </p>
                </div>
                <div class="session">
                    <h3>Afternoon Session (Workflow)</h3>
                    <p>
                        Script has run: 
                        $(if ($hasRunAfternoon) {
                            '<span class="status green">Yes</span>'
                        } else {
                            '<span class="status yellow">No</span>'
                        })
                    </p>
                </div>
            </div>
            
            <p>Last run info: <strong>$lastRunInfo</strong></p>
        </div>
        
        <div class="card">
            <h2>Upcoming Schedule</h2>
            <ul class="schedule-list">
                $(foreach ($day in $nextCommitDays) {
                    $daysUntil = ([DateTime]::Parse($day) - $today).Days
                    if ($day -eq $todayStr) {
                        "<li class='today'><strong>$day</strong> (Today!) - AM: Commits, PM: Workflow</li>"
                    } else {
                        "<li><strong>$day</strong> (in $daysUntil days) - AM: Commits, PM: Workflow</li>"
                    }
                })
            </ul>
        </div>
        
        <div class="card">
            <h2>Recent Activity</h2>
            $(if ($lastCommits.Count -gt 0) {
                "<ul class='commit-list'>"
                foreach ($commit in $lastCommits) {
                    "<li>$commit</li>"
                }
                "</ul>"
            } else {
                "<p>No activity found in the log.</p>"
            })
        </div>
        
        <div class="card">
            <h2>Code Snippets</h2>
            $(if ($hasCodeSnippets -and $snippetFiles.Count -gt 0) {
                "<p>The following code snippet files are being updated with each activity:</p>"
                "<ul class='file-list'>"
                foreach ($file in $snippetFiles) {
                    "<li>$file</li>"
                }
                "</ul>"
            } else {
                "<p>No code snippets found. They will be created on the next activity.</p>"
            })
        </div>
        
        <div class="card">
            <h2>Task Scheduler Status</h2>
            
            <div class="session-box">
                <div class="session">
                    <h3>Morning Task (9:00 AM)</h3>
                    <p>
                        Task exists: 
                        $(if ($morningTaskExists) {
                            '<span class="status green">Yes</span>'
                        } else {
                            '<span class="status red">No</span>'
                        })
                    </p>
                    <p>State: <strong>$morningTaskState</strong></p>
                    <p>Last run: <strong>$morningLastRunTime</strong></p>
                    <p>Next run: <strong>$morningNextRunTime</strong></p>
                </div>
                <div class="session">
                    <h3>Afternoon Task (3:00 PM)</h3>
                    <p>
                        Task exists: 
                        $(if ($afternoonTaskExists) {
                            '<span class="status green">Yes</span>'
                        } else {
                            '<span class="status red">No</span>'
                        })
                    </p>
                    <p>State: <strong>$afternoonTaskState</strong></p>
                    <p>Last run: <strong>$afternoonLastRunTime</strong></p>
                    <p>Next run: <strong>$afternoonNextRunTime</strong></p>
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>Generated on $(Get-Date) | GitHub Workflow Automation</p>
        </div>
    </div>
</body>
</html>
"@

# Save the HTML file
$html | Out-File -FilePath $dashboardFile -Encoding utf8

Write-Host "Dashboard generated at: $dashboardFile" -ForegroundColor Green
Write-Host "Open this file in a web browser to view your progress." -ForegroundColor Cyan

# Try to open the dashboard in the default browser
Start-Process $dashboardFile
