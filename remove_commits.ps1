# Remove Commits Script
# This script helps remove specific commits from your Git history

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
    "[$timestamp] $Message" | Out-File -Append -FilePath "$repoPath\remove_commits_log.txt" -Encoding utf8
}

Write-Log "Starting commit removal process..."

# Backup the current branch
$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Log "Current branch: $currentBranch"

# Create a backup branch
$backupBranch = "backup-$((Get-Date).ToString('yyyyMMdd-HHmmss'))"
Write-Log "Creating backup branch: $backupBranch"
git branch $backupBranch

# Function to remove commits by date range
function Remove-CommitsByDateRange {
    param(
        [string]$StartDate,
        [string]$EndDate
    )
    
    Write-Log "Removing commits from $StartDate to $EndDate..."
    
    # Use git filter-branch to remove commits in the date range
    $env:GIT_FILTER_BRANCH_FORCE = "1"
    git filter-branch --force --env-filter "
        if [ `"`$GIT_COMMIT_DATE`" -ge `"$StartDate`" ] && [ `"`$GIT_COMMIT_DATE`" -le `"$EndDate`" ]; then
            skip_commit `"`$GIT_COMMIT`";
        fi
    " --tag-name-filter cat -- --all
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Error removing commits. Please check the error message above."
        return $false
    }
    
    Write-Log "Successfully removed commits from $StartDate to $EndDate"
    return $true
}

# Function to remove specific commits by their hash
function Remove-CommitsByHash {
    param(
        [string[]]$CommitHashes
    )
    
    Write-Log "Removing specific commits by hash..."
    
    foreach ($hash in $CommitHashes) {
        Write-Log "Removing commit: $hash"
        
        # Use git filter-branch to remove the specific commit
        $env:GIT_FILTER_BRANCH_FORCE = "1"
        git filter-branch --force --env-filter "
            if [ `"`$GIT_COMMIT`" = `"$hash`" ]; then
                skip_commit `"`$GIT_COMMIT`";
            fi
        " --tag-name-filter cat -- --all
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Error removing commit $hash. Please check the error message above."
            return $false
        }
    }
    
    Write-Log "Successfully removed specified commits"
    return $true
}

# Function to remove all commits for a specific day
function Remove-CommitsByDay {
    param(
        [string]$Date
    )
    
    Write-Log "Removing all commits for $Date..."
    
    # Convert date to timestamp format
    $dateObj = [datetime]::ParseExact($Date, "yyyy-MM-dd", $null)
    $startDate = $dateObj.ToString("yyyy-MM-dd") + "T00:00:00"
    $endDate = $dateObj.ToString("yyyy-MM-dd") + "T23:59:59"
    
    # Use git filter-branch to remove commits for the specific day
    $env:GIT_FILTER_BRANCH_FORCE = "1"
    git filter-branch --force --env-filter "
        if [ `"`$GIT_COMMIT_DATE`" -ge `"$startDate`" ] && [ `"`$GIT_COMMIT_DATE`" -le `"$endDate`" ]; then
            skip_commit `"`$GIT_COMMIT`";
        fi
    " --tag-name-filter cat -- --all
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Error removing commits for $Date. Please check the error message above."
        return $false
    }
    
    Write-Log "Successfully removed commits for $Date"
    return $true
}

# Menu for selecting what to remove
Write-Host ""
Write-Host "Select an option to remove commits:" -ForegroundColor Yellow
Write-Host "1. Remove commits by date range" -ForegroundColor Yellow
Write-Host "2. Remove specific commits by hash" -ForegroundColor Yellow
Write-Host "3. Remove all commits for a specific day" -ForegroundColor Yellow
Write-Host "4. Exit" -ForegroundColor Yellow
Write-Host ""

$option = Read-Host "Enter your choice (1-4)"

switch ($option) {
    "1" {
        $startDate = Read-Host "Enter start date (YYYY-MM-DD)"
        $endDate = Read-Host "Enter end date (YYYY-MM-DD)"
        $success = Remove-CommitsByDateRange -StartDate $startDate -EndDate $endDate
    }
    "2" {
        $hashesInput = Read-Host "Enter commit hashes separated by commas"
        $hashes = $hashesInput -split ","
        $success = Remove-CommitsByHash -CommitHashes $hashes
    }
    "3" {
        $date = Read-Host "Enter date (YYYY-MM-DD)"
        $success = Remove-CommitsByDay -Date $date
    }
    "4" {
        Write-Log "Exiting without making changes."
        exit 0
    }
    default {
        Write-Log "Invalid option. Exiting without making changes."
        exit 1
    }
}

if ($success) {
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
} else {
    Write-Log "Operation failed. No changes were made to the repository."
}

Write-Host ""
Write-Host "Process completed. Check the log file for details." -ForegroundColor Yellow
Write-Host "If you need to restore from backup, run: git checkout $backupBranch" -ForegroundColor Yellow
Write-Host ""
