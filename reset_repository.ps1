# Reset Repository Script
# This script removes all commits from the repository and creates a fresh initial commit

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
    "[$timestamp] $Message" | Out-File -Append -FilePath "$repoPath\reset_repository_log.txt" -Encoding utf8
}

Write-Log "Starting repository reset process..."

# Backup the current branch
$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Log "Current branch: $currentBranch"

# Create a backup branch
$backupBranch = "backup-$((Get-Date).ToString('yyyyMMdd-HHmmss'))"
Write-Log "Creating backup branch: $backupBranch"
git branch $backupBranch

# Confirm the reset operation
Write-Host ""
Write-Host "WARNING: This will remove ALL commits from your repository!" -ForegroundColor Red
Write-Host "A backup branch '$backupBranch' has been created in case you need to restore." -ForegroundColor Yellow
$confirm = Read-Host "Are you sure you want to proceed? (Type 'YES' to confirm)"

if ($confirm -ne "YES") {
    Write-Log "Operation cancelled by user."
    exit 0
}

# Create a new orphan branch
Write-Log "Creating new orphan branch..."
git checkout --orphan temp_branch

# Add a README file
$readmeContent = @"
# Repository Reset

This repository was reset on $(Get-Date -Format "yyyy-MM-dd").

All previous commits have been removed to clear the contribution graph.
"@

$readmeContent | Out-File -FilePath "$repoPath\README.md" -Encoding utf8

# Commit the README file
git add README.md
git commit -m "Initial commit after repository reset"

# Delete the old branch
git branch -D $currentBranch

# Rename the temp branch to the original branch name
git branch -m $currentBranch

# Force push the changes to GitHub
$forcePush = Read-Host "Do you want to force push these changes to GitHub? (Y/N)"

if ($forcePush -eq "Y" -or $forcePush -eq "y") {
    Write-Log "Force pushing changes to GitHub..."
    git push -f origin $currentBranch
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Error pushing changes to GitHub. Please check the error message above."
    } else {
        Write-Log "Successfully pushed changes to GitHub."
        Write-Log "Your contribution graph should be cleared shortly."
    }
} else {
    Write-Log "Changes were not pushed to GitHub. To push them later, run: git push -f origin $currentBranch"
}

Write-Host ""
Write-Host "Repository reset completed. Check the log file for details." -ForegroundColor Yellow
Write-Host "If you need to restore from backup, run: git checkout $backupBranch" -ForegroundColor Yellow
Write-Host ""
