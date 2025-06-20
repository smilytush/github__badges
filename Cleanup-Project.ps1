# ===============================================
# GREEN COMMITS PROJECT CLEANUP SCRIPT v5.0
# ===============================================
# STREAMLINED cleanup and maintenance script
# Focused on 17 core features only
# Removes bloat, optimizes repository, maintains system health
# Windows Terminal Compatible (ASCII-only output)
# ===============================================

param(
    [switch]$DryRun = $false,
    [switch]$Force = $false,
    [switch]$Deep = $false
)

# Set execution policy and error handling
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$ErrorActionPreference = "Continue"

# Color scheme for output (Windows Terminal compatible)
$Colors = @{
    "Header"   = "Magenta"
    "Success"  = "Green"
    "Warning"  = "Yellow"
    "Error"    = "Red"
    "Info"     = "Cyan"
    "Progress" = "Blue"
}

function Write-CleanupLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "SUCCESS" { $Colors.Success }
        "WARNING" { $Colors.Warning }
        "ERROR" { $Colors.Error }
        "PROGRESS" { $Colors.Progress }
        default { $Colors.Info }
    }

    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Get-DirectorySize {
    param([string]$Path)

    if (Test-Path $Path) {
        try {
            $size = (Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            return [math]::Round($size / 1MB, 2)
        }
        catch {
            return 0
        }
    }
    return 0
}

function Remove-BloatFiles {
    Write-CleanupLog "Removing bloat files not part of 17 core features..." "PROGRESS"

    # Define bloat file patterns to remove
    $bloatPatterns = @(
        "badge-*.md",
        "collab-*.md",
        "coauth-*.md",
        "yolo-*.md",
        "*.bundle",
        "commit_*_*.txt",
        "test_*.ps1",
        "*-automation-simple.log",
        "*-status-report.txt",
        "*-state.json",
        # Legacy redundant files
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
        "enhanced-github-pattern.bat",
        "test_historical_backdate.bat",
        "validate_github_access.bat",
        "clear_contributions.bat",
        "COMPREHENSIVE_BACKDATE_README.md",
        "COMPREHENSIVE_SYSTEM_V2_README.md",
        "ENHANCED_HISTORICAL_SYSTEM_README.md",
        "IMPLEMENTATION_SUMMARY.md",
        "SECURE_SYSTEM_README.md",
        "GreenCommits-Master.ps1",
        "GreenCommits-Master-Simple.ps1",
        "validate-system.ps1",
        "create_repo.ps1",
        "test.txt",
        "clear_contributions_log.txt",
        "desktop.ini"
    )

    $removedCount = 0
    $totalSize = 0

    foreach ($pattern in $bloatPatterns) {
        $files = Get-ChildItem -Path $PSScriptRoot -Filter $pattern -ErrorAction SilentlyContinue
        if ($files) {
            $size = ($files | Measure-Object -Property Length -Sum).Sum / 1MB
            $totalSize += $size

            Write-CleanupLog "Found $($files.Count) bloat files matching '$pattern' ($('{0:N2}' -f $size) MB)" "INFO"

            if (-not $DryRun) {
                $files | Remove-Item -Force -ErrorAction SilentlyContinue
                $removedCount += $files.Count
            }
        }
    }

    # Remove bloat directories
    $bloatDirs = @("commits", "debug-tests")
    foreach ($dir in $bloatDirs) {
        $dirPath = Join-Path $PSScriptRoot $dir
        if (Test-Path $dirPath) {
            $dirSize = Get-DirectorySize $dirPath
            $totalSize += $dirSize

            Write-CleanupLog "Found bloat directory '$dir' ($('{0:N2}' -f $dirSize) MB)" "INFO"

            if (-not $DryRun) {
                Remove-Item $dirPath -Recurse -Force -ErrorAction SilentlyContinue
                $removedCount++
            }
        }
    }

    if ($removedCount -gt 0 -and -not $DryRun) {
        Write-CleanupLog "Removed $removedCount bloat files/directories ($('{0:N2}' -f $totalSize) MB)" "SUCCESS"
    } elseif ($DryRun) {
        Write-CleanupLog "DRY RUN: Would remove $removedCount bloat files/directories ($('{0:N2}' -f $totalSize) MB)" "INFO"
    } else {
        Write-CleanupLog "No bloat files found to remove" "INFO"
    }
}

function Remove-OldFiles {
    param(
        [string]$Directory,
        [int]$DaysOld = 30,
        [string]$Pattern = "*"
    )

    if (-not (Test-Path $Directory)) {
        Write-CleanupLog "Directory not found: $Directory" "WARNING"
        return
    }

    $cutoffDate = (Get-Date).AddDays(-$DaysOld)
    $oldFiles = Get-ChildItem -Path $Directory -Filter $Pattern -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cutoffDate }

    if ($oldFiles) {
        $totalSize = ($oldFiles | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-CleanupLog "Found $($oldFiles.Count) old files in $Directory ($('{0:N2}' -f $totalSize) MB)" "INFO"

        if (-not $DryRun) {
            $oldFiles | Remove-Item -Force -ErrorAction SilentlyContinue
            Write-CleanupLog "Removed $($oldFiles.Count) old files from $Directory" "SUCCESS"
        } else {
            Write-CleanupLog "DRY RUN: Would remove $($oldFiles.Count) old files from $Directory" "INFO"
        }
    } else {
        Write-CleanupLog "No old files found in $Directory" "INFO"
    }
}

function Optimize-GitRepository {
    Write-CleanupLog "Optimizing Git repository..." "PROGRESS"

    try {
        if (-not $DryRun) {
            # Git garbage collection
            $gcResult = git gc --aggressive --prune=now 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-CleanupLog "Git garbage collection completed" "SUCCESS"
            } else {
                Write-CleanupLog "Git garbage collection failed: $gcResult" "WARNING"
            }

            # Optimize repository
            $repackResult = git repack -ad 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-CleanupLog "Git repository repacked" "SUCCESS"
            } else {
                Write-CleanupLog "Git repack failed: $repackResult" "WARNING"
            }
        } else {
            Write-CleanupLog "DRY RUN: Would optimize Git repository" "INFO"
        }
    }
    catch {
        Write-CleanupLog "Error optimizing Git repository: $($_.Exception.Message)" "ERROR"
    }
}

function Clean-LogFiles {
    Write-CleanupLog "Cleaning log files..." "PROGRESS"

    $logPatterns = @(
        "*.log",
        "*.tmp",
        "*.temp"
    )

    foreach ($pattern in $logPatterns) {
        Remove-OldFiles -Directory $PSScriptRoot -DaysOld 30 -Pattern $pattern
    }
}

function Clean-BackupFiles {
    Write-CleanupLog "Cleaning backup files..." "PROGRESS"

    $backupDir = Join-Path $PSScriptRoot "backup"
    if (Test-Path $backupDir) {
        Remove-OldFiles -Directory $backupDir -DaysOld 30 -Pattern "*"
    }
}

function Clean-TempFiles {
    Write-CleanupLog "Cleaning temporary files..." "PROGRESS"

    $tempDir = Join-Path $PSScriptRoot "temp"
    if (Test-Path $tempDir) {
        Remove-OldFiles -Directory $tempDir -DaysOld 7 -Pattern "*"
    }
}

function Show-CleanupSummary {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor $Colors.Header
    Write-Host "                    CLEANUP SUMMARY                            " -ForegroundColor $Colors.Header
    Write-Host "================================================================" -ForegroundColor $Colors.Header
    Write-Host ""

    # Calculate directory sizes
    $srcSize = Get-DirectorySize (Join-Path $PSScriptRoot "src")
    $backupSize = Get-DirectorySize (Join-Path $PSScriptRoot "backup")
    $tempSize = Get-DirectorySize (Join-Path $PSScriptRoot "temp")

    Write-Host "Directory Sizes:" -ForegroundColor $Colors.Info
    Write-Host "  Source files: $srcSize MB" -ForegroundColor $Colors.Info
    Write-Host "  Backup files: $backupSize MB" -ForegroundColor $Colors.Info
    Write-Host "  Temp files: $tempSize MB" -ForegroundColor $Colors.Info
    Write-Host ""

    # Essential files check
    Write-Host "Essential Files Status:" -ForegroundColor $Colors.Info
    $essentialFiles = @(
        "GreenCommits-MasterControl.ps1",
        "enhanced_historical_system_v2.ps1",
        "GreenCommits-Simple.ps1",
        "config.json"
    )

    foreach ($file in $essentialFiles) {
        $filePath = Join-Path $PSScriptRoot $file
        $status = if (Test-Path $filePath) { "OK" } else { "MISSING" }
        $color = if (Test-Path $filePath) { $Colors.Success } else { $Colors.Error }
        Write-Host "  $file : $status" -ForegroundColor $color
    }
    Write-Host ""

    # Git repository status
    try {
        $gitStatus = git status --porcelain 2>$null
        if ($gitStatus) {
            Write-Host "Git Status: $($gitStatus.Count) uncommitted changes" -ForegroundColor $Colors.Warning
        } else {
            Write-Host "Git Status: Clean working directory" -ForegroundColor $Colors.Success
        }
    }
    catch {
        Write-Host "Git Status: Unable to check" -ForegroundColor $Colors.Error
    }

    Write-Host ""
}

function Start-ProjectCleanup {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor $Colors.Header
    Write-Host "         GREEN COMMITS PROJECT CLEANUP v5.0 STREAMLINED       " -ForegroundColor $Colors.Header
    Write-Host "================================================================" -ForegroundColor $Colors.Header
    Write-Host ""

    if ($DryRun) {
        Write-CleanupLog "Running in DRY RUN mode - no files will be deleted" "WARNING"
        Write-Host ""
    }

    # Show initial summary
    Show-CleanupSummary

    # Confirm operation unless forced
    if (-not $Force -and -not $DryRun) {
        Write-Host "This will clean up bloat files and optimize the repository." -ForegroundColor $Colors.Warning
        Write-Host "Focus: Remove files not part of 17 core features" -ForegroundColor $Colors.Info
        $confirm = Read-Host "Do you want to continue? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-CleanupLog "Cleanup cancelled by user" "INFO"
            return
        }
        Write-Host ""
    }

    # Perform cleanup operations
    Remove-BloatFiles
    Clean-LogFiles
    Clean-BackupFiles
    Clean-TempFiles

    if ($Deep) {
        Optimize-GitRepository
    }

    Write-Host ""
    Write-CleanupLog "Streamlined project cleanup completed" "SUCCESS"
    Write-Host ""

    # Show final summary
    Show-CleanupSummary
}

# Start cleanup
Start-ProjectCleanup
