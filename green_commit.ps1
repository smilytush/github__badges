# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# Path to schedule file
$scheduleFile = "$repoPath\commit_schedule.txt"

# Path to log file
$logFile = "$repoPath\script_log.txt"

# Path to last run file
$lastRunFile = "$repoPath\last_run.txt"

# Function to log messages
function Write-Log {
    param(
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] $Message" | Out-File -Append -Encoding utf8 $logFile
    Write-Host $Message
}

# Generate 280 random commit days if not already created
if (-not (Test-Path $scheduleFile)) {
    $today = Get-Date
    $daysToPick = 280
    $totalDays = 365

    $dates = 1..$totalDays | ForEach-Object { $today.AddDays($_).ToString("yyyy-MM-dd") }
    $selectedDates = $dates | Get-Random -Count $daysToPick
    $selectedDates | Sort-Object | Set-Content $scheduleFile
    Write-Log "Created commit schedule with $daysToPick days"
}

# Get today's date
$todayStr = (Get-Date).ToString("yyyy-MM-dd")

# Check if script has already run today
$hasRunToday = $false
if (Test-Path $lastRunFile) {
    $lastRun = Get-Content $lastRunFile
    if ($lastRun -eq $todayStr) {
        $hasRunToday = $true
        Write-Log "Script has already run today. Skipping execution."
    }
}

# If script hasn't run today, proceed with checks
if (-not $hasRunToday) {
    # Check if today is in the selected commit dates
    $commitDays = Get-Content $scheduleFile
    if ($commitDays -contains $todayStr) {
        Write-Log "Today ($todayStr) is a commit day. Making a commit..."

        try {
            # Create or update the activity log
            "Update: $(Get-Date)" | Out-File -Append -Encoding utf8 "$repoPath\activity.log"

            # Configure git user (already done globally, but included for completeness)
            git config user.name "smilytush"
            git config user.email "tushar161@hotmail.com"

            # Get current branch name
            $currentBranch = (git rev-parse --abbrev-ref HEAD) 2>&1
            if ($LASTEXITCODE -ne 0) {
                $currentBranch = "master" # Default to master if command fails
            }
            Write-Log "Current branch: $currentBranch"

            # Commit and push
            git add .
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to stage files"
            }

            git commit -m "Auto commit on $todayStr"
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to commit changes"
            }

            # Check if remote exists
            $remoteExists = git remote | Where-Object { $_ -eq "origin" }
            if (-not $remoteExists) {
                Write-Log "Remote 'origin' not found. Skipping push."
            }
            else {
                git push origin $currentBranch
                if ($LASTEXITCODE -ne 0) {
                    throw "Failed to push to remote"
                }
                Write-Log "Commit successfully made and pushed to $currentBranch!"

                # Record that the script has run today
                $todayStr | Out-File -FilePath $lastRunFile -Encoding utf8 -Force
            }
        }
        catch {
            Write-Log "Error: $_"
        }
    }
    else {
        Write-Log "Today ($todayStr) is not scheduled for a commit."

        # Record that the script has run today even if no commit was made
        $todayStr | Out-File -FilePath $lastRunFile -Encoding utf8 -Force
    }
}
