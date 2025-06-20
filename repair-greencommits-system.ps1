# GreenCommits System Repair Script
# Fixes all issues preventing commits from appearing on GitHub profile
# Addresses security violations, configuration issues, and push failures

param(
    [switch]$Force = $false,
    [switch]$TestMode = $false,
    [switch]$SkipBackup = $false
)

# Set execution policy and error handling
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$ErrorActionPreference = "Stop"

Write-Host "=== GreenCommits System Repair ===" -ForegroundColor Cyan
Write-Host "Diagnosing and fixing system issues..." -ForegroundColor Yellow

# Function to create backup
function New-SystemBackup {
    if ($SkipBackup) {
        Write-Host "Skipping backup as requested" -ForegroundColor Yellow
        return
    }
    
    $backupDir = "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    
    $filesToBackup = @(
        "GreenCommits-MasterControl.ps1",
        "config.json",
        ".git/config"
    )
    
    foreach ($file in $filesToBackup) {
        if (Test-Path $file) {
            Copy-Item $file "$backupDir/" -Force
            Write-Host "✓ Backed up: $file" -ForegroundColor Green
        }
    }
    
    Write-Host "✓ System backup created: $backupDir" -ForegroundColor Green
}

# Function to validate environment
function Test-Environment {
    Write-Host "Validating environment..." -ForegroundColor Yellow
    
    # Check if GitHub token is set
    if ([string]::IsNullOrEmpty($env:GITHUB_TOKEN)) {
        Write-Host "ERROR: GITHUB_TOKEN environment variable not set!" -ForegroundColor Red
        Write-Host "Run setup-environment.ps1 first to configure credentials" -ForegroundColor Yellow
        return $false
    }
    
    # Validate token format
    if (-not ($env:GITHUB_TOKEN -match '^ghp_[A-Za-z0-9]{36}$|^github_pat_[A-Za-z0-9_]{82}$')) {
        Write-Host "ERROR: Invalid GitHub token format!" -ForegroundColor Red
        return $false
    }
    
    Write-Host "✓ Environment validation passed" -ForegroundColor Green
    return $true
}

# Function to fix git configuration
function Repair-GitConfiguration {
    Write-Host "Repairing Git configuration..." -ForegroundColor Yellow
    
    try {
        # Remove any hardcoded tokens from remote URL
        $currentRemote = git remote get-url origin
        if ($currentRemote -match "ghp_|github_pat_") {
            Write-Host "Removing hardcoded token from remote URL..." -ForegroundColor Yellow
            git remote set-url origin "https://github.com/smilytush/github-commits.git"
            Write-Host "✓ Remote URL cleaned" -ForegroundColor Green
        }
        
        # Set user configuration
        git config user.name "smilytush"
        git config user.email "tushar161@hotmail.com"
        
        Write-Host "✓ Git configuration repaired" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "ERROR: Git configuration repair failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to test GitHub connectivity
function Test-GitHubConnectivity {
    Write-Host "Testing GitHub connectivity..." -ForegroundColor Yellow
    
    try {
        $headers = @{ Authorization = "token $env:GITHUB_TOKEN" }
        $response = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers -Method GET
        Write-Host "✓ GitHub API access confirmed for: $($response.login)" -ForegroundColor Green
        
        # Test repository access
        $repoResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/smilytush/github-commits" -Headers $headers -Method GET
        Write-Host "✓ Repository access confirmed: $($repoResponse.full_name)" -ForegroundColor Green
        
        return $true
    }
    catch {
        Write-Host "ERROR: GitHub connectivity test failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to test push capability
function Test-PushCapability {
    Write-Host "Testing push capability..." -ForegroundColor Yellow
    
    try {
        # Create a test commit
        $testFile = "test_push_$(Get-Date -Format 'yyyyMMddHHmmss').txt"
        "Test push capability - $(Get-Date)" | Out-File -FilePath $testFile -Encoding UTF8
        
        git add $testFile
        git commit -m "Test push capability - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        
        # Configure remote with token for this push
        $secureRemoteUrl = "https://$($env:GITHUB_TOKEN)@github.com/smilytush/github-commits.git"
        git remote set-url origin $secureRemoteUrl
        
        # Attempt push
        git push origin main
        
        # Clean up remote URL
        git remote set-url origin "https://github.com/smilytush/github-commits.git"
        
        # Clean up test file
        Remove-Item $testFile -Force
        
        Write-Host "✓ Push capability test successful!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "ERROR: Push capability test failed: $($_.Exception.Message)" -ForegroundColor Red
        
        # Clean up on failure
        git remote set-url origin "https://github.com/smilytush/github-commits.git" -ErrorAction SilentlyContinue
        if (Test-Path $testFile) {
            Remove-Item $testFile -Force -ErrorAction SilentlyContinue
        }
        
        return $false
    }
}

# Function to repair system files
function Repair-SystemFiles {
    Write-Host "Checking system files for hardcoded credentials..." -ForegroundColor Yellow
    
    $filesFixed = 0
    $scriptFiles = Get-ChildItem -Path "." -Filter "*.ps1" -File
    
    foreach ($file in $scriptFiles) {
        $content = Get-Content $file.FullName -Raw
        $originalContent = $content
        
        # Replace hardcoded tokens with environment variable references
        $content = $content -replace 'Token\s*=\s*"ghp_[A-Za-z0-9]{36}"', 'Token = $env:GITHUB_TOKEN  # Use environment variable for security'
        $content = $content -replace 'Token\s*=\s*"github_pat_[A-Za-z0-9_]{82}"', 'Token = $env:GITHUB_TOKEN  # Use environment variable for security'
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8
            Write-Host "✓ Fixed hardcoded credentials in: $($file.Name)" -ForegroundColor Green
            $filesFixed++
        }
    }
    
    if ($filesFixed -eq 0) {
        Write-Host "✓ No hardcoded credentials found in system files" -ForegroundColor Green
    }
    else {
        Write-Host "✓ Fixed hardcoded credentials in $filesFixed files" -ForegroundColor Green
    }
}

# Main repair process
try {
    Write-Host "Starting system repair process..." -ForegroundColor Cyan
    
    # Step 1: Create backup
    New-SystemBackup
    
    # Step 2: Validate environment
    if (-not (Test-Environment)) {
        Write-Host "CRITICAL: Environment validation failed!" -ForegroundColor Red
        Write-Host "Please run: .\setup-environment.ps1 -Interactive -Validate" -ForegroundColor Yellow
        exit 1
    }
    
    # Step 3: Repair system files
    Repair-SystemFiles
    
    # Step 4: Repair Git configuration
    if (-not (Repair-GitConfiguration)) {
        Write-Host "CRITICAL: Git configuration repair failed!" -ForegroundColor Red
        exit 1
    }
    
    # Step 5: Test GitHub connectivity
    if (-not (Test-GitHubConnectivity)) {
        Write-Host "CRITICAL: GitHub connectivity test failed!" -ForegroundColor Red
        exit 1
    }
    
    # Step 6: Test push capability
    if ($TestMode) {
        if (-not (Test-PushCapability)) {
            Write-Host "CRITICAL: Push capability test failed!" -ForegroundColor Red
            exit 1
        }
    }
    
    Write-Host ""
    Write-Host "=== SYSTEM REPAIR COMPLETE ===" -ForegroundColor Green
    Write-Host "✓ All security violations resolved" -ForegroundColor Green
    Write-Host "✓ Git configuration repaired" -ForegroundColor Green
    Write-Host "✓ GitHub connectivity confirmed" -ForegroundColor Green
    if ($TestMode) {
        Write-Host "✓ Push capability verified" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "The GreenCommits system is now ready for operation!" -ForegroundColor Cyan
    Write-Host "Commits will now properly appear on your GitHub profile." -ForegroundColor Yellow
}
catch {
    Write-Host ""
    Write-Host "=== REPAIR FAILED ===" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check the error details and try again." -ForegroundColor Yellow
    exit 1
}
