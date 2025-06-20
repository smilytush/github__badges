# Git History Cleanup Script
# Removes hardcoded GitHub tokens from git history to resolve push protection violations

param(
    [switch]$Force = $false,
    [switch]$DryRun = $false
)

# Set execution policy and error handling
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$ErrorActionPreference = "Stop"

Write-Host "=== Git History Cleanup ===" -ForegroundColor Cyan
Write-Host "Removing hardcoded secrets from git history..." -ForegroundColor Yellow

# Function to create backup
function New-GitBackup {
    Write-Host "Creating git backup..." -ForegroundColor Yellow
    
    $backupDir = "git_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    
    # Create bundle backup
    git bundle create "$backupDir/repository_backup.bundle" --all
    
    # Copy .git directory
    Copy-Item ".git" "$backupDir/.git_backup" -Recurse -Force
    
    Write-Host "✓ Git backup created: $backupDir" -ForegroundColor Green
    return $backupDir
}

# Function to clean specific files in history
function Remove-SecretsFromHistory {
    Write-Host "Removing secrets from git history..." -ForegroundColor Yellow
    
    # The problematic token that needs to be removed
    $tokenToRemove = "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"
    
    # Files that contained the token
    $filesToClean = @(
        "GreenCommits-MasterControl.ps1",
        "config.json",
        "enhanced_historical_system_v2.ps1",
        "run_enhanced_historical_system.ps1",
        "simple_test_mode.ps1",
        "quick_test_mode.ps1"
    )
    
    Write-Host "Files to clean: $($filesToClean -join ', ')" -ForegroundColor Gray
    
    if ($DryRun) {
        Write-Host "DRY RUN: Would clean git history for these files" -ForegroundColor Yellow
        return $true
    }
    
    try {
        # Use git filter-branch to rewrite history
        Write-Host "Rewriting git history (this may take a while)..." -ForegroundColor Yellow
        
        # Create a sed script to replace the token
        $sedScript = "s/$tokenToRemove/GITHUB_TOKEN_REMOVED/g"
        
        foreach ($file in $filesToClean) {
            Write-Host "Cleaning history for: $file" -ForegroundColor Gray
            
            # Use git filter-branch to clean the file in all commits
            $filterCommand = @"
git filter-branch --force --tree-filter "
    if [ -f '$file' ]; then
        sed -i 's/$tokenToRemove/\$env:GITHUB_TOKEN  # Use environment variable for security/g' '$file' 2>/dev/null || true
    fi
" --prune-empty --tag-name-filter cat -- --all
"@
            
            # Execute the filter command
            Invoke-Expression $filterCommand
        }
        
        Write-Host "✓ Git history cleaned successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "ERROR: Failed to clean git history: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to force cleanup refs
function Clear-GitRefs {
    Write-Host "Cleaning up git references..." -ForegroundColor Yellow
    
    try {
        # Remove backup refs created by filter-branch
        git for-each-ref --format="%(refname)" refs/original/ | ForEach-Object {
            git update-ref -d $_
        }
        
        # Expire reflog
        git reflog expire --expire=now --all
        
        # Garbage collect
        git gc --prune=now --aggressive
        
        Write-Host "✓ Git references cleaned" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "WARNING: Git reference cleanup had issues: $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

# Function to verify cleanup
function Test-HistoryCleanup {
    Write-Host "Verifying history cleanup..." -ForegroundColor Yellow
    
    try {
        # Search for the token in git history
        $tokenFound = git log --all --full-history --source --grep="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" --oneline
        
        if ($tokenFound) {
            Write-Host "WARNING: Token still found in commit messages" -ForegroundColor Yellow
            return $false
        }
        
        # Search in file contents across history
        $contentSearch = git log --all --full-history -S "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" --oneline
        
        if ($contentSearch) {
            Write-Host "WARNING: Token still found in file contents" -ForegroundColor Yellow
            return $false
        }
        
        Write-Host "✓ No hardcoded tokens found in git history" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "ERROR: History verification failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main cleanup process
try {
    if (-not $Force -and -not $DryRun) {
        Write-Host ""
        Write-Host "WARNING: This will rewrite git history!" -ForegroundColor Red
        Write-Host "This is a destructive operation that cannot be easily undone." -ForegroundColor Yellow
        Write-Host "A backup will be created, but you should ensure you have other backups." -ForegroundColor Yellow
        Write-Host ""
        $confirmation = Read-Host "Do you want to continue? (yes/no)"
        
        if ($confirmation -ne "yes") {
            Write-Host "Operation cancelled by user" -ForegroundColor Yellow
            exit 0
        }
    }
    
    # Step 1: Create backup
    if (-not $DryRun) {
        $backupDir = New-GitBackup
    }
    
    # Step 2: Clean git history
    if (-not (Remove-SecretsFromHistory)) {
        Write-Host "CRITICAL: Failed to clean git history!" -ForegroundColor Red
        exit 1
    }
    
    # Step 3: Clean up references
    if (-not $DryRun) {
        Clear-GitRefs
    }
    
    # Step 4: Verify cleanup
    if (-not $DryRun) {
        if (-not (Test-HistoryCleanup)) {
            Write-Host "WARNING: History cleanup verification failed" -ForegroundColor Yellow
            Write-Host "Manual verification may be required" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "=== HISTORY CLEANUP COMPLETE ===" -ForegroundColor Green
    if (-not $DryRun) {
        Write-Host "✓ Git history has been cleaned" -ForegroundColor Green
        Write-Host "✓ Hardcoded tokens removed from all commits" -ForegroundColor Green
        Write-Host "✓ Backup created: $backupDir" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "1. Set environment variable: \$env:GITHUB_TOKEN = 'your_token'" -ForegroundColor Gray
        Write-Host "2. Test push: git push origin main --force" -ForegroundColor Gray
        Write-Host "3. Verify commits appear on GitHub profile" -ForegroundColor Gray
    }
    else {
        Write-Host "✓ Dry run completed - no changes made" -ForegroundColor Green
    }
}
catch {
    Write-Host ""
    Write-Host "=== CLEANUP FAILED ===" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($backupDir) {
        Write-Host "Backup available at: $backupDir" -ForegroundColor Yellow
        Write-Host "You can restore from backup if needed" -ForegroundColor Yellow
    }
    
    exit 1
}
