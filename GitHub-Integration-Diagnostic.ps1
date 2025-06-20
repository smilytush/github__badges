# ===============================================
# GITHUB INTEGRATION DIAGNOSTIC & FIX SCRIPT
# ===============================================
# Comprehensive GitHub integration testing and repair
# Ensures all commits appear on GitHub contribution graph
# Windows Terminal Compatible (ASCII-only output)
# ===============================================

param(
    [switch]$Fix = $false,
    [switch]$Test = $false,
    [switch]$Verbose = $false
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

function Write-DiagnosticLog {
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

function Test-GitConfiguration {
    Write-DiagnosticLog "Testing Git configuration..." "PROGRESS"

    $issues = @()

    # Check user.name
    $userName = git config user.name 2>$null
    if (-not $userName -or $userName -ne "smilytush") {
        $issues += "Git user.name not set correctly (expected: smilytush, actual: $userName)"
    } else {
        Write-DiagnosticLog "Git user.name: $userName ✓" "SUCCESS"
    }

    # Check user.email
    $userEmail = git config user.email 2>$null
    if (-not $userEmail -or $userEmail -ne "tushar161@hotmail.com") {
        $issues += "Git user.email not set correctly (expected: tushar161@hotmail.com, actual: $userEmail)"
    } else {
        Write-DiagnosticLog "Git user.email: $userEmail ✓" "SUCCESS"
    }

    return $issues
}

function Test-GitHubAuthentication {
    Write-DiagnosticLog "Testing GitHub authentication..." "PROGRESS"

    $issues = @()

    # Check remote URL
    $remoteUrl = git remote get-url origin 2>$null
    if (-not $remoteUrl) {
        $issues += "No remote origin configured"
    } elseif ($remoteUrl -notlike "*github.com/smilytush/github-commits*") {
        $issues += "Remote URL incorrect: $remoteUrl"
    } else {
        Write-DiagnosticLog "Remote URL: $remoteUrl ✓" "SUCCESS"
    }

    # Test GitHub API access
    try {
        $headers = @{
            "Authorization" = "token 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"
            "User-Agent" = "Green-Commits-v5.0"
        }

        $response = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers -ErrorAction Stop
        if ($response.login -eq "smilytush") {
            Write-DiagnosticLog "GitHub API authentication: SUCCESS ✓" "SUCCESS"
        } else {
            $issues += "GitHub API returned wrong user: $($response.login)"
        }
    }
    catch {
        $issues += "GitHub API authentication failed: $($_.Exception.Message)"
    }

    return $issues
}

function Test-RepositoryStatus {
    Write-DiagnosticLog "Testing repository status..." "PROGRESS"

    $issues = @()

    # Check if we're in a git repository
    if (-not (Test-Path ".git")) {
        $issues += "Not in a Git repository"
        return $issues
    }

    # Check current branch
    $currentBranch = git branch --show-current 2>$null
    if ($currentBranch -ne "main") {
        $issues += "Not on main branch (current: $currentBranch)"
    } else {
        Write-DiagnosticLog "Current branch: $currentBranch ✓" "SUCCESS"
    }

    # Check for uncommitted changes
    $status = git status --porcelain 2>$null
    if ($status) {
        $changeCount = ($status | Measure-Object).Count
        Write-DiagnosticLog "Uncommitted changes: $changeCount files" "WARNING"
    } else {
        Write-DiagnosticLog "Working directory clean ✓" "SUCCESS"
    }

    # Check last commit
    $lastCommit = git log -1 --oneline 2>$null
    if ($lastCommit) {
        Write-DiagnosticLog "Last commit: $lastCommit ✓" "SUCCESS"
    } else {
        $issues += "No commits found in repository"
    }

    return $issues
}

function Test-GitHubVisibility {
    Write-DiagnosticLog "Testing GitHub repository visibility..." "PROGRESS"

    $issues = @()

    try {
        # Test repository access
        $repoUrl = "https://api.github.com/repos/smilytush/github-commits"
        $headers = @{
            "Authorization" = "token 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"
            "User-Agent" = "Green-Commits-v5.0"
        }

        $repo = Invoke-RestMethod -Uri $repoUrl -Headers $headers -ErrorAction Stop

        Write-DiagnosticLog "Repository name: $($repo.name) ✓" "SUCCESS"
        Write-DiagnosticLog "Repository visibility: $($repo.visibility) ✓" "SUCCESS"
        Write-DiagnosticLog "Default branch: $($repo.default_branch) ✓" "SUCCESS"
        Write-DiagnosticLog "Last push: $($repo.pushed_at) ✓" "SUCCESS"

        # Check recent commits
        $commitsUrl = "https://api.github.com/repos/smilytush/github-commits/commits"
        $commits = Invoke-RestMethod -Uri $commitsUrl -Headers $headers -ErrorAction Stop

        if ($commits -and $commits.Count -gt 0) {
            $latestCommit = $commits[0]
            Write-DiagnosticLog "Latest commit on GitHub: $($latestCommit.sha.Substring(0,7)) ✓" "SUCCESS"
            Write-DiagnosticLog "Commit message: $($latestCommit.commit.message.Split("`n")[0]) ✓" "SUCCESS"
            Write-DiagnosticLog "Commit date: $($latestCommit.commit.author.date) ✓" "SUCCESS"
        } else {
            $issues += "No commits found on GitHub repository"
        }
    }
    catch {
        $issues += "Failed to access GitHub repository: $($_.Exception.Message)"
    }

    return $issues
}

function Fix-GitHubIntegration {
    Write-DiagnosticLog "Fixing GitHub integration issues..." "PROGRESS"

    # Fix Git configuration
    Write-DiagnosticLog "Setting Git configuration..." "PROGRESS"
    git config --global user.name "smilytush"
    git config --global user.email "tushar161@hotmail.com"

    # Fix remote URL with authentication
    Write-DiagnosticLog "Setting remote URL with authentication..." "PROGRESS"
    git remote set-url origin "https://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@github.com/smilytush/github-commits.git"

    # Ensure we're on main branch
    Write-DiagnosticLog "Checking out main branch..." "PROGRESS"
    git checkout main 2>$null

    Write-DiagnosticLog "GitHub integration fixes applied ✓" "SUCCESS"
}

function Test-CommitVisibility {
    Write-DiagnosticLog "Testing commit visibility with Test Mode..." "PROGRESS"

    # Create a test commit
    $testFile = "github-integration-test-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
    $testContent = @"
# GitHub Integration Test

This is a test commit to verify GitHub integration is working properly.

**Test Details:**
- Date: $(Get-Date)
- Purpose: Verify commits appear on GitHub contribution graph
- System: Green Commits Master Control v5.0
- Integration: GitHub API and Git operations

**Expected Result:**
This commit should appear on the GitHub contribution graph at https://github.com/smilytush

**Test Status:** INTEGRATION TEST COMMIT
"@

    try {
        # Create test file
        Set-Content -Path $testFile -Value $testContent -Encoding UTF8

        # Add and commit
        git add $testFile
        git commit -m "GitHub Integration Test - Verify contribution graph visibility

✅ INTEGRATION TEST: Verifying GitHub contribution graph display
✅ SYSTEM: Green Commits Master Control v5.0
✅ PURPOSE: Ensure all commits appear on public GitHub profile
✅ DATE: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

This test commit should appear on the GitHub contribution graph at:
https://github.com/smilytush

If this commit is visible on the contribution graph, the GitHub
integration is working correctly for all 17 core features."

        # Push to GitHub
        Write-DiagnosticLog "Pushing test commit to GitHub..." "PROGRESS"
        git push origin main

        if ($LASTEXITCODE -eq 0) {
            Write-DiagnosticLog "Test commit pushed successfully ✓" "SUCCESS"
            Write-DiagnosticLog "Check your GitHub profile: https://github.com/smilytush" "INFO"
            return $true
        } else {
            Write-DiagnosticLog "Failed to push test commit" "ERROR"
            return $false
        }
    }
    catch {
        Write-DiagnosticLog "Error creating test commit: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Show-DiagnosticSummary {
    param([array]$AllIssues)

    Write-Host ""
    Write-Host "================================================================" -ForegroundColor $Colors.Header
    Write-Host "           GITHUB INTEGRATION DIAGNOSTIC SUMMARY               " -ForegroundColor $Colors.Header
    Write-Host "================================================================" -ForegroundColor $Colors.Header
    Write-Host ""

    if ($AllIssues.Count -eq 0) {
        Write-Host "✅ ALL TESTS PASSED - GitHub integration is working correctly!" -ForegroundColor $Colors.Success
        Write-Host ""
        Write-Host "Your GitHub profile should show commit activity at:" -ForegroundColor $Colors.Info
        Write-Host "https://github.com/smilytush" -ForegroundColor $Colors.Info
        Write-Host ""
        Write-Host "All 17 core features should now properly reflect on your" -ForegroundColor $Colors.Info
        Write-Host "GitHub contribution graph when executed." -ForegroundColor $Colors.Info
    } else {
        Write-Host "❌ ISSUES FOUND ($($AllIssues.Count) total):" -ForegroundColor $Colors.Error
        Write-Host ""
        foreach ($issue in $AllIssues) {
            Write-Host "  • $issue" -ForegroundColor $Colors.Error
        }
        Write-Host ""
        Write-Host "Run with -Fix parameter to automatically resolve issues:" -ForegroundColor $Colors.Warning
        Write-Host "  .\GitHub-Integration-Diagnostic.ps1 -Fix" -ForegroundColor $Colors.Warning
    }

    Write-Host ""
}

function Start-GitHubDiagnostic {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor $Colors.Header
    Write-Host "         GITHUB INTEGRATION DIAGNOSTIC & FIX TOOL             " -ForegroundColor $Colors.Header
    Write-Host "================================================================" -ForegroundColor $Colors.Header
    Write-Host ""

    $allIssues = @()

    # Run all diagnostic tests
    $allIssues += Test-GitConfiguration
    $allIssues += Test-GitHubAuthentication
    $allIssues += Test-RepositoryStatus
    $allIssues += Test-GitHubVisibility

    # Apply fixes if requested
    if ($Fix -and $allIssues.Count -gt 0) {
        Write-Host ""
        Fix-GitHubIntegration
        Write-Host ""

        # Re-run tests after fixes
        Write-DiagnosticLog "Re-running tests after fixes..." "PROGRESS"
        $allIssues = @()
        $allIssues += Test-GitConfiguration
        $allIssues += Test-GitHubAuthentication
        $allIssues += Test-RepositoryStatus
    }

    # Run commit visibility test if requested
    if ($Test) {
        Write-Host ""
        $testResult = Test-CommitVisibility
        if (-not $testResult) {
            $allIssues += "Test commit failed to push to GitHub"
        }
    }

    # Show summary
    Show-DiagnosticSummary -AllIssues $allIssues

    return ($allIssues.Count -eq 0)
}

# Start diagnostic
$success = Start-GitHubDiagnostic

# Exit with appropriate code
if ($success) {
    exit 0
} else {
    exit 1
}
