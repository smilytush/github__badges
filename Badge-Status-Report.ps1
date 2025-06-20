# Badge Status Report Generator
# Generates comprehensive status report for GitHub badge automation

param(
    [Parameter(Mandatory=$false)]
    [string]$OutputFormat = "Console"
)

# Set error handling
$ErrorActionPreference = "Continue"

# Initialize paths
$LogFile = Join-Path $PSScriptRoot "badge-automation-simple.log"
$StateFile = Join-Path $PSScriptRoot "badge-state.json"
$ReportFile = Join-Path $PSScriptRoot "badge-status-report.txt"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogFile -Value $logEntry -ErrorAction SilentlyContinue
}

function Get-BadgeState {
    if (Test-Path $StateFile) {
        try {
            return Get-Content $StateFile | ConvertFrom-Json
        }
        catch {
            Write-Log "Error reading badge state file: $($_.Exception.Message)"
            return $null
        }
    }
    return $null
}

function Get-GitStatistics {
    try {
        $stats = @{}
        
        # Get commit count
        $commitCount = (git rev-list --count HEAD 2>$null)
        $stats.CommitCount = if ($commitCount) { [int]$commitCount } else { 0 }
        
        # Get branch count
        $branchCount = (git branch -r 2>$null | Measure-Object).Count
        $stats.BranchCount = if ($branchCount) { $branchCount } else { 0 }
        
        # Get file count
        $fileCount = (git ls-files 2>$null | Measure-Object).Count
        $stats.FileCount = if ($fileCount) { $fileCount } else { 0 }
        
        # Get repository size
        $repoSize = (Get-ChildItem -Recurse -File | Measure-Object -Property Length -Sum).Sum
        $stats.RepoSizeMB = [math]::Round($repoSize / 1MB, 2)
        
        return $stats
    }
    catch {
        Write-Log "Error getting Git statistics: $($_.Exception.Message)"
        return @{
            CommitCount = 0
            BranchCount = 0
            FileCount = 0
            RepoSizeMB = 0
        }
    }
}

function Generate-BadgeProgressReport {
    $report = @()
    $report += "================================================================"
    $report += "           GITHUB BADGE AUTOMATION STATUS REPORT"
    $report += "================================================================"
    $report += ""
    $report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $report += "Repository: $(Split-Path $PSScriptRoot -Leaf)"
    $report += ""
    
    # Get badge state
    $state = Get-BadgeState
    if ($state) {
        $report += "AUTOMATION STATUS:"
        $report += "Start Time: $($state.StartTime)"
        $report += "Last Updated: $($state.LastUpdated)"
        $report += ""
        
        $report += "TARGETED BADGES:"
        foreach ($badge in $state.BadgesTargeted) {
            $status = if ($state.BadgesEarned -contains $badge) { "[EARNED]" } else { "[PENDING]" }
            $report += "  $status $badge"
        }
        $report += ""
        
        $report += "ACTIONS COMPLETED:"
        if ($state.ActionsCompleted -and $state.ActionsCompleted.Count -gt 0) {
            foreach ($action in $state.ActionsCompleted) {
                $report += "  - $($action.Action): $($action.Details) ($($action.Timestamp))"
            }
        } else {
            $report += "  No actions completed yet"
        }
        $report += ""
    }
    
    # Get Git statistics
    $gitStats = Get-GitStatistics
    $report += "REPOSITORY STATISTICS:"
    $report += "  Total Commits: $($gitStats.CommitCount)"
    $report += "  Total Branches: $($gitStats.BranchCount)"
    $report += "  Total Files: $($gitStats.FileCount)"
    $report += "  Repository Size: $($gitStats.RepoSizeMB) MB"
    $report += ""
    
    # Badge earning progress
    $report += "BADGE EARNING PROGRESS:"
    $report += ""
    
    $report += "1. PULL SHARK BADGE:"
    $report += "   Target: Create and merge pull requests"
    $report += "   Requirements: 2 merged PRs (Default), 16 (Bronze), 128 (Silver), 1024 (Gold)"
    $report += "   Progress: Automated PR creation and merging implemented"
    $report += "   Status: IN PROGRESS"
    $report += ""
    
    $report += "2. STARSTRUCK BADGE:"
    $report += "   Target: Create repositories that receive stars"
    $report += "   Requirements: 16 stars (Default), 128 (Bronze), 512 (Silver), 4096 (Gold)"
    $report += "   Progress: Showcase repositories created"
    $report += "   Status: REQUIRES COMMUNITY ENGAGEMENT"
    $report += ""
    
    $report += "3. QUICKDRAW BADGE:"
    $report += "   Target: Close issue/PR within 5 minutes of opening"
    $report += "   Requirements: 1 quick resolution"
    $report += "   Progress: Quick issue resolution automated"
    $report += "   Status: IN PROGRESS"
    $report += ""
    
    $report += "4. PAIR EXTRAORDINAIRE BADGE:"
    $report += "   Target: Co-authored commits on merged PRs"
    $report += "   Requirements: 1 (Default), 10 (Bronze), 24 (Silver), 48 (Gold)"
    $report += "   Progress: Co-authored commits created"
    $report += "   Status: IN PROGRESS"
    $report += ""
    
    $report += "5. YOLO BADGE:"
    $report += "   Target: Merge PR without review"
    $report += "   Requirements: 1 direct merge"
    $report += "   Progress: Direct merge to main branch completed"
    $report += "   Status: COMPLETED"
    $report += ""
    
    $report += "6. GALAXY BRAIN BADGE:"
    $report += "   Target: Answer discussions with accepted answers"
    $report += "   Requirements: 2 (Default), 8 (Bronze), 16 (Silver), 32 (Gold)"
    $report += "   Progress: Discussion content prepared"
    $report += "   Status: REQUIRES MANUAL PARTICIPATION"
    $report += ""
    
    $report += "7. PUBLIC SPONSOR BADGE:"
    $report += "   Target: Sponsor open source contributors"
    $report += "   Requirements: 1 sponsorship"
    $report += "   Progress: Sponsor information prepared"
    $report += "   Status: REQUIRES MANUAL ACTION"
    $report += ""
    
    $report += "HIGHLIGHT BADGES:"
    $report += ""
    
    $report += "8. GITHUB PRO BADGE:"
    $report += "   Target: Use GitHub Pro subscription"
    $report += "   Requirements: Active Pro subscription"
    $report += "   Progress: Documentation prepared"
    $report += "   Status: REQUIRES SUBSCRIPTION"
    $report += ""
    
    $report += "9. DEVELOPER PROGRAM MEMBER:"
    $report += "   Target: Join GitHub Developer Program"
    $report += "   Requirements: Program membership"
    $report += "   Progress: Application materials prepared"
    $report += "   Status: REQUIRES APPLICATION"
    $report += ""
    
    $report += "10. SECURITY BUG BOUNTY HUNTER:"
    $report += "    Target: Report security vulnerabilities"
    $report += "    Requirements: Accepted security report"
    $report += "    Progress: Security research documentation created"
    $report += "    Status: REQUIRES SECURITY RESEARCH"
    $report += ""
    
    # Next steps
    $report += "NEXT STEPS:"
    $report += ""
    $report += "AUTOMATED ACTIONS:"
    $report += "  - Continue running the automation script daily"
    $report += "  - Monitor repository activity and engagement"
    $report += "  - Track badge earning progress"
    $report += ""
    
    $report += "MANUAL ACTIONS REQUIRED:"
    $report += "  1. Promote repositories to gain stars (Starstruck badge)"
    $report += "  2. Participate in GitHub Discussions (Galaxy Brain badge)"
    $report += "  3. Set up GitHub Sponsors (Public Sponsor badge)"
    $report += "  4. Subscribe to GitHub Pro (GitHub Pro badge)"
    $report += "  5. Apply to Developer Program (Developer Program badge)"
    $report += "  6. Participate in security research (Security badge)"
    $report += ""
    
    $report += "ESTIMATED TIMELINE:"
    $report += "  - Automated badges: 1-3 days"
    $report += "  - Community-dependent badges: 1-4 weeks"
    $report += "  - Manual action badges: Immediate upon completion"
    $report += ""
    
    $report += "================================================================"
    $report += "                    END OF REPORT"
    $report += "================================================================"
    
    return $report
}

function Export-Report {
    param([array]$ReportContent)
    
    # Output to console
    foreach ($line in $ReportContent) {
        Write-Host $line
    }
    
    # Save to file
    try {
        $ReportContent | Out-File -FilePath $ReportFile -Encoding UTF8 -Force
        Write-Log "Status report saved to: $ReportFile"
    }
    catch {
        Write-Log "Error saving report file: $($_.Exception.Message)"
    }
}

# Main execution
Write-Log "Generating badge status report..."

try {
    $report = Generate-BadgeProgressReport
    Export-Report -ReportContent $report
    Write-Log "Badge status report generation completed"
}
catch {
    Write-Log "Error generating status report: $($_.Exception.Message)"
    Write-Host "Error generating status report. Check log file for details."
}

# Return success
exit 0
