# This script forces a commit regardless of the schedule
# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# Path to log file
$logFile = "$repoPath\script_log.txt"

# Function to log messages
function Write-Log {
    param(
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] $Message" | Out-File -Append -Encoding utf8 $logFile
    Write-Host $Message
}

# Get today's date
$todayStr = (Get-Date).ToString("yyyy-MM-dd")

Write-Log "Forcing a commit for today ($todayStr)..."

try {
    # Create or update the activity log
    "Update (Forced): $(Get-Date)" | Out-File -Append -Encoding utf8 "$repoPath\activity.log"

    # Configure git user
    git config user.name "smilytush"
    git config user.email "tushar161@hotmail.com"

    # Get current branch name
    $currentBranch = (git rev-parse --abbrev-ref HEAD) 2>&1
    if ($LASTEXITCODE -ne 0) {
        $currentBranch = "main" # Default to main if command fails
    }
    Write-Log "Current branch: $currentBranch"

    # Commit and push
    git add activity.log
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to stage files"
    }
    
    git commit -m "Forced commit on $todayStr"
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
    }
}
catch {
    Write-Log "Error: $_"
}

# Record that the script has run today
$todayStr | Out-File -FilePath "$repoPath\last_run.txt" -Encoding utf8 -Force

Write-Log "Force commit complete."
