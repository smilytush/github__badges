# ===============================================
# GREEN COMMITS SIMPLE CONTROL SYSTEM
# ===============================================
# Simple, reliable GitHub contribution system
# No complex features, just working functionality
# ===============================================

param(
    [ValidateSet("Full", "Test", "Daily")]
    [string]$Mode = "Test",
    [switch]$AutoConfirm = $false,
    [switch]$Help = $false
)

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $colors = @{
        "INFO"    = "White"
        "SUCCESS" = "Green"
        "WARNING" = "Yellow"
        "ERROR"   = "Red"
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $colors[$Level]
}

function Show-Help {
    Write-Host ""
    Write-Host "GREEN COMMITS SIMPLE CONTROL SYSTEM" -ForegroundColor Magenta
    Write-Host "====================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\GreenCommits-Simple.ps1 -Mode MODE" -ForegroundColor White
    Write-Host ""
    Write-Host "MODES:" -ForegroundColor Yellow
    Write-Host "  Test     - Create 5 test commits (default)" -ForegroundColor White
    Write-Host "  Full     - Run complete historical backfill" -ForegroundColor White
    Write-Host "  Daily    - Create daily commits" -ForegroundColor White
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -AutoConfirm    Skip confirmation prompts" -ForegroundColor White
    Write-Host "  -Help           Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\GreenCommits-Simple.ps1 -Mode Test" -ForegroundColor White
    Write-Host "  .\GreenCommits-Simple.ps1 -Mode Full -AutoConfirm" -ForegroundColor White
    Write-Host ""
}

function Test-Requirements {
    Write-Log "Checking system requirements..." "INFO"
    
    # Check if enhanced system exists
    $enhancedPath = Join-Path $PSScriptRoot "enhanced_historical_system_v2.ps1"
    if (-not (Test-Path $enhancedPath)) {
        Write-Log "Enhanced historical system file not found!" "ERROR"
        return $false
    }
    
    # Check Git
    try {
        $gitVersion = git --version 2>$null
        Write-Log "Git found: $gitVersion" "SUCCESS"
    }
    catch {
        Write-Log "Git not found in PATH" "ERROR"
        return $false
    }
    
    Write-Log "All requirements satisfied" "SUCCESS"
    return $true
}

function Start-TestMode {
    Write-Log "Starting Test Mode..." "INFO"
    
    $enhancedPath = Join-Path $PSScriptRoot "enhanced_historical_system_v2.ps1"
    
    try {
        Write-Log "Executing enhanced historical system in test mode..." "INFO"
        & powershell -ExecutionPolicy Bypass -File $enhancedPath -TestMode
        Write-Log "Test mode completed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error in test mode: $($_.Exception.Message)" "ERROR"
    }
}

function Start-FullMode {
    Write-Log "Starting Full Historical Backfill..." "INFO"
    
    if (-not $AutoConfirm) {
        Write-Host ""
        Write-Host "WARNING: This will create 779 days of historical commits!" -ForegroundColor Yellow
        Write-Host "This process may take 30-60 minutes to complete." -ForegroundColor Yellow
        Write-Host ""
        $confirm = Read-Host "Do you want to continue? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Log "Operation cancelled by user" "INFO"
            return
        }
    }
    
    $enhancedPath = Join-Path $PSScriptRoot "enhanced_historical_system_v2.ps1"
    
    try {
        Write-Log "Setting environment for full mode..." "INFO"
        $env:FORCE_FULL_MODE = "true"
        
        Write-Log "Executing enhanced historical system in full mode..." "INFO"
        if ($AutoConfirm) {
            & powershell -ExecutionPolicy Bypass -File $enhancedPath -SkipConfirmation
        }
        else {
            & powershell -ExecutionPolicy Bypass -File $enhancedPath
        }
        Write-Log "Full mode completed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error in full mode: $($_.Exception.Message)" "ERROR"
    }
}

function Start-DailyMode {
    Write-Log "Starting Daily Commit Mode..." "INFO"
    
    # Create 1-3 commits for today
    $commitCount = Get-Random -Minimum 1 -Maximum 4
    Write-Log "Creating $commitCount daily commits..." "INFO"
    
    for ($i = 1; $i -le $commitCount; $i++) {
        $languages = @("python", "solidity", "typescript")
        $lang = $languages | Get-Random
        
        $messages = @(
            "Update documentation",
            "Fix minor bug",
            "Improve performance",
            "Add new feature",
            "Refactor code",
            "Update dependencies",
            "Fix security issue",
            "Optimize algorithm"
        )
        $message = $messages | Get-Random
        
        $today = Get-Date -Format "yyyy-MM-dd"
        $filename = "src\$today-$i-$lang.md"
        
        # Create file
        $content = "# Daily Commit $i`n`nLanguage: $lang`nMessage: $message`nDate: $today`nTime: $(Get-Date -Format 'HH:mm:ss')"
        
        # Ensure src directory exists
        $srcDir = Join-Path $PSScriptRoot "src"
        if (-not (Test-Path $srcDir)) {
            New-Item -ItemType Directory -Path $srcDir -Force | Out-Null
        }
        
        $filePath = Join-Path $PSScriptRoot $filename
        $content | Out-File -FilePath $filePath -Encoding utf8
        
        # Git operations
        try {
            git add $filename
            git commit -m "$message - $lang implementation"
            Write-Log "Created daily commit $i/$commitCount" "SUCCESS"
        }
        catch {
            Write-Log "Error creating commit ${i}: $($_.Exception.Message)" "ERROR"
        }
    }
    
    # Push to GitHub
    try {
        Write-Log "Pushing daily commits to GitHub..." "INFO"
        git push origin main
        Write-Log "Daily commits pushed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error pushing commits: $($_.Exception.Message)" "ERROR"
    }
}

function Start-SimpleControl {
    Write-Host ""
    Write-Host "GREEN COMMITS SIMPLE CONTROL SYSTEM" -ForegroundColor Magenta
    Write-Host "====================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Check requirements
    if (-not (Test-Requirements)) {
        Write-Log "System requirements not met. Exiting." "ERROR"
        return
    }
    
    # Execute based on mode
    switch ($Mode) {
        "Test" { 
            Start-TestMode 
        }
        "Full" { 
            Start-FullMode 
        }
        "Daily" { 
            Start-DailyMode 
        }
        default { 
            Write-Log "Unknown mode: $Mode" "ERROR"
            Show-Help
        }
    }
    
    Write-Host ""
    Write-Log "Script execution completed" "INFO"
}

# Show help if requested
if ($Help) {
    Show-Help
    exit 0
}

# Start the simple control system
Start-SimpleControl
