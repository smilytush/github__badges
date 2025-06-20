# ===============================================
# GREEN COMMITS PROJECT CLEANUP SCRIPT
# ===============================================
# Removes redundant files and organizes the project
# Fixes file access issues and permissions
# ===============================================

param(
    [switch]$DryRun = $false,
    [switch]$Force = $false,
    [switch]$KeepLogs = $false
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
        "CLEANUP" = "Cyan"
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $colors[$Level]
}

function Get-FilesToCleanup {
    $redundantFiles = @(
        # Duplicate/redundant PowerShell scripts
        "comprehensive_backdate_system.ps1",
        "complete_github_backdate_fixed.ps1", 
        "complete_github_backdate_system.ps1",
        "comprehensive_test_system.ps1",
        "enhanced_github_pattern.ps1",
        "enhanced_historical_backdate_system.ps1",
        "unified_github_backdate_final.ps1",
        "unified_github_backdate_system.ps1",
        "unified_github_backdate_system_simple.ps1",
        "test_backdate_system.ps1",
        "test_complete_system.ps1",
        "test_github_api.ps1",
        "verify_configuration.ps1",
        "verify_contribution_graph.ps1",
        
        # Redundant batch files
        "enhanced-github-pattern.bat",
        "test_historical_backdate.bat",
        "validate_github_access.bat",
        "clear_contributions.bat",
        
        # Old documentation files
        "COMPREHENSIVE_BACKDATE_README.md",
        "COMPREHENSIVE_SYSTEM_V2_README.md", 
        "ENHANCED_HISTORICAL_SYSTEM_README.md",
        "IMPLEMENTATION_SUMMARY.md",
        "SECURE_SYSTEM_README.md",
        
        # Broken/non-functional scripts
        "GreenCommits-Master.ps1", # Has syntax errors
        "GreenCommits-Master-Simple.ps1", # Replaced by working version
        
        # Old validation scripts
        "validate-system.ps1",
        "create_repo.ps1",
        
        # Temporary/test files
        "test.txt",
        "clear_contributions_log.txt",
        "desktop.ini"
    )
    
    return $redundantFiles
}

function Get-DirectoriesToCleanup {
    $redundantDirs = @(
        "commits", # Old commit storage
        "debug-tests"  # Debug files
    )
    
    return $redundantDirs
}

function Remove-RedundantFiles {
    Write-Log "Starting file cleanup..." "CLEANUP"
    
    $filesToRemove = Get-FilesToCleanup
    $removedCount = 0
    $errorCount = 0
    
    foreach ($file in $filesToRemove) {
        $filePath = Join-Path $PSScriptRoot $file
        
        if (Test-Path $filePath) {
            if ($DryRun) {
                Write-Log "Would remove: $file" "CLEANUP"
            }
            else {
                try {
                    Remove-Item $filePath -Force
                    Write-Log "Removed: $file" "SUCCESS"
                    $removedCount++
                }
                catch {
                    Write-Log "Failed to remove: $file - $($_.Exception.Message)" "ERROR"
                    $errorCount++
                }
            }
        }
    }
    
    Write-Log "Files processed: $($filesToRemove.Count), Removed: $removedCount, Errors: $errorCount" "INFO"
}

function Remove-RedundantDirectories {
    Write-Log "Starting directory cleanup..." "CLEANUP"
    
    $dirsToRemove = Get-DirectoriesToCleanup
    $removedCount = 0
    $errorCount = 0
    
    foreach ($dir in $dirsToRemove) {
        $dirPath = Join-Path $PSScriptRoot $dir
        
        if (Test-Path $dirPath) {
            if ($DryRun) {
                Write-Log "Would remove directory: $dir" "CLEANUP"
            }
            else {
                try {
                    Remove-Item $dirPath -Recurse -Force
                    Write-Log "Removed directory: $dir" "SUCCESS"
                    $removedCount++
                }
                catch {
                    Write-Log "Failed to remove directory: $dir - $($_.Exception.Message)" "ERROR"
                    $errorCount++
                }
            }
        }
    }
    
    Write-Log "Directories processed: $($dirsToRemove.Count), Removed: $removedCount, Errors: $errorCount" "INFO"
}

function Cleanup-LogFiles {
    if ($KeepLogs) {
        Write-Log "Skipping log cleanup (KeepLogs specified)" "INFO"
        return
    }
    
    Write-Log "Cleaning up old log files..." "CLEANUP"
    
    $logFiles = Get-ChildItem -Path $PSScriptRoot -Filter "*.log" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) }
    
    foreach ($logFile in $logFiles) {
        if ($DryRun) {
            Write-Log "Would remove old log: $($logFile.Name)" "CLEANUP"
        }
        else {
            try {
                Remove-Item $logFile.FullName -Force
                Write-Log "Removed old log: $($logFile.Name)" "SUCCESS"
            }
            catch {
                Write-Log "Failed to remove log: $($logFile.Name) - $($_.Exception.Message)" "ERROR"
            }
        }
    }
}

function Organize-WorkingFiles {
    Write-Log "Organizing working files..." "CLEANUP"
    
    # Create organized structure
    $directories = @(
        "scripts",
        "docs", 
        "logs",
        "backup"
    )
    
    foreach ($dir in $directories) {
        $dirPath = Join-Path $PSScriptRoot $dir
        if (-not (Test-Path $dirPath)) {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
                Write-Log "Created directory: $dir" "SUCCESS"
            }
            else {
                Write-Log "Would create directory: $dir" "CLEANUP"
            }
        }
    }
    
    # Move working files to appropriate locations
    $fileMovements = @{
        "enhanced_historical_system_v2.ps1" = "scripts"
        "GreenCommits-Simple.ps1"           = "scripts"
        "GreenCommits-Master-Fixed.ps1"     = "scripts"
        "Setup-DailyAutomation.ps1"         = "scripts"
        "Cleanup-Project.ps1"               = "scripts"
        "README-Enhanced.md"                = "docs"
        "AUTOMATION-SETUP-GUIDE.md"         = "docs"
        "TaskScheduler-Template.xml"        = "docs"
        "*.log"                             = "logs"
    }
    
    # Note: File movement would be complex and risky, so we'll skip this for now
    Write-Log "File organization structure created (manual file movement recommended)" "INFO"
}

function Fix-FilePermissions {
    Write-Log "Checking and fixing file permissions..." "CLEANUP"
    
    $scriptFiles = Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1"
    
    foreach ($script in $scriptFiles) {
        try {
            # Check if file is readable
            $content = Get-Content $script.FullName -TotalCount 1 -ErrorAction Stop
            Write-Log "Permissions OK: $($script.Name)" "SUCCESS"
        }
        catch {
            Write-Log "Permission issue: $($script.Name) - $($_.Exception.Message)" "ERROR"
            
            if (-not $DryRun) {
                try {
                    # Try to fix permissions
                    $acl = Get-Acl $script.FullName
                    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, "FullControl", "Allow")
                    $acl.SetAccessRule($accessRule)
                    Set-Acl $script.FullName $acl
                    Write-Log "Fixed permissions: $($script.Name)" "SUCCESS"
                }
                catch {
                    Write-Log "Failed to fix permissions: $($script.Name)" "ERROR"
                }
            }
        }
    }
}

function Show-ProjectStatus {
    Write-Log "Current project status:" "INFO"
    
    # Count files by type
    $psFiles = (Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1").Count
    $batFiles = (Get-ChildItem -Path $PSScriptRoot -Filter "*.bat").Count
    $mdFiles = (Get-ChildItem -Path $PSScriptRoot -Filter "*.md").Count
    $logFiles = (Get-ChildItem -Path $PSScriptRoot -Filter "*.log").Count
    
    Write-Log "PowerShell files: $psFiles" "INFO"
    Write-Log "Batch files: $batFiles" "INFO"
    Write-Log "Documentation files: $mdFiles" "INFO"
    Write-Log "Log files: $logFiles" "INFO"
    
    # Check working files
    $workingFiles = @(
        "enhanced_historical_system_v2.ps1",
        "GreenCommits-Simple.ps1", 
        "run-daily-commits.bat",
        "config.json"
    )
    
    Write-Log "Essential working files:" "INFO"
    foreach ($file in $workingFiles) {
        $exists = Test-Path (Join-Path $PSScriptRoot $file)
        $status = if ($exists) { "OK" } else { "MISSING" }
        Write-Log "  $status $file" "INFO"
    }
}

function Main {
    Write-Host ""
    Write-Host "GREEN COMMITS PROJECT CLEANUP" -ForegroundColor Magenta
    Write-Host "==============================" -ForegroundColor Magenta
    Write-Host ""
    
    if ($DryRun) {
        Write-Log "DRY RUN MODE - No files will be modified" "WARNING"
        Write-Host ""
    }
    
    # Show current status
    Show-ProjectStatus
    Write-Host ""
    
    # Confirm cleanup
    if (-not $Force -and -not $DryRun) {
        Write-Host "This will remove redundant files and clean up the project." -ForegroundColor Yellow
        Write-Host "Working files will be preserved." -ForegroundColor Green
        Write-Host ""
        $confirm = Read-Host "Continue with cleanup? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Log "Cleanup cancelled by user" "INFO"
            return
        }
        Write-Host ""
    }
    
    # Perform cleanup
    Remove-RedundantFiles
    Write-Host ""
    
    Remove-RedundantDirectories  
    Write-Host ""
    
    Cleanup-LogFiles
    Write-Host ""
    
    Fix-FilePermissions
    Write-Host ""
    
    Organize-WorkingFiles
    Write-Host ""
    
    # Show final status
    Write-Log "Cleanup completed!" "SUCCESS"
    Write-Host ""
    Show-ProjectStatus
}

# Run main function
Main
