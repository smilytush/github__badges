# Clear Contributions Script
# This script removes all commits within a specified date range to clear your GitHub contribution graph

# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# Function to log messages
function Write-Log {
    param(
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor Cyan
    "[$timestamp] $Message" | Out-File -Append -FilePath "$repoPath\clear_contributions_log.txt" -Encoding utf8
}

Write-Log "Starting contribution clearing process..."

# Backup the current branch
$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Log "Current branch: $currentBranch"

# Create a backup branch
$backupBranch = "backup-$((Get-Date).ToString('yyyyMMdd-HHmmss'))"
Write-Log "Creating backup branch: $backupBranch"
git branch $backupBranch

# Get the start and end dates for clearing contributions
$startYear = Read-Host "Enter start year (e.g., 2022)"
$startMonth = Read-Host "Enter start month (1-12)"
$startDay = Read-Host "Enter start day (1-31)"

$endYear = Read-Host "Enter end year (e.g., 2025)"
$endMonth = Read-Host "Enter end month (1-12)"
$endDay = Read-Host "Enter end day (1-31)"

$startDate = "$startYear-$startMonth-$startDay"
$endDate = "$endYear-$endMonth-$endDay"

Write-Log "Removing all commits from $startDate to $endDate..."

# Use git filter-branch to remove commits in the date range
$env:GIT_FILTER_BRANCH_FORCE = "1"

# Create a temporary script file for the filter-branch command
$tempScriptPath = "$repoPath\temp_filter_script.sh"
@"
#!/bin/sh
if [ "\$GIT_AUTHOR_DATE" \> "$startDate" ] && [ "\$GIT_AUTHOR_DATE" \< "$endDate" ]; then
    skip_commit "\$GIT_COMMIT";
else
    git commit-tree "\$@";
fi
"@ | Out-File -FilePath $tempScriptPath -Encoding ascii

# Make the script executable (not needed in Windows but good practice)
git filter-branch -f --tree-filter "echo 'Processing commit...'" HEAD

# Use a simpler approach with --env-filter
git filter-branch --force --env-filter @"
if [[ \$GIT_AUTHOR_DATE > $startDate && \$GIT_AUTHOR_DATE < $endDate ]]; then
    export GIT_AUTHOR_NAME="Deleted Author"
    export GIT_AUTHOR_EMAIL="deleted@example.com"
    export GIT_AUTHOR_DATE="1970-01-01T00:00:00"
    export GIT_COMMITTER_NAME="Deleted Committer"
    export GIT_COMMITTER_EMAIL="deleted@example.com"
    export GIT_COMMITTER_DATE="1970-01-01T00:00:00"
fi
"@ HEAD

if ($LASTEXITCODE -ne 0) {
    Write-Log "Error removing commits. Trying alternative method..."
    
    # Alternative method: create a new orphan branch and cherry-pick commits outside the date range
    git checkout --orphan temp_branch
    git commit --allow-empty -m "Initial commit"
    
    # Get all commit hashes outside the date range
    $commits = git log --pretty=format:"%H" --before="$startDate" --reverse
    $commits += git log --pretty=format:"%H" --after="$endDate" --reverse
    
    foreach ($commit in $commits) {
        git cherry-pick $commit
        if ($LASTEXITCODE -ne 0) {
            git cherry-pick --skip
        }
    }
    
    # Rename branches
    git branch -D $currentBranch
    git branch -m $currentBranch
}

# Force push the changes to GitHub
$forcePush = Read-Host "Do you want to force push these changes to GitHub? (Y/N)"

if ($forcePush -eq "Y" -or $forcePush -eq "y") {
    Write-Log "Force pushing changes to GitHub..."
    git push -f origin $currentBranch
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Error pushing changes to GitHub. Please check the error message above."
    } else {
        Write-Log "Successfully pushed changes to GitHub."
        Write-Log "Your contribution graph should be updated shortly."
    }
} else {
    Write-Log "Changes were not pushed to GitHub. To push them later, run: git push -f origin $currentBranch"
}

Write-Host ""
Write-Host "Process completed. Check the log file for details." -ForegroundColor Yellow
Write-Host "If you need to restore from backup, run: git checkout $backupBranch" -ForegroundColor Yellow
Write-Host ""
