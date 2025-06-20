# Enhanced Historical Backdated GitHub Commit System - Main Execution Script
# Creates commits from November 1st, 2022 to present with comprehensive validation

param(
    [switch]$Force = $false,
    [switch]$TestMode = $false,
    [switch]$DryRun = $false,
    [switch]$SkipConfirmation = $false
)

# GitHub Configuration
$GitHubConfig = @{
    Username = "smilytush"
    Email = "tushar161@hotmail.com"
    Token = "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"
    Repository = "github-commits"
    RemoteURL = "https://github.com/smilytush/github-commits.git"
    DefaultBranch = "main"
    BaseAPIURL = "https://api.github.com"
}

$repoPath = "J:\green-commits"

# Function to log messages
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $colorMap = @{
        "INFO" = "Cyan"
        "SUCCESS" = "Green"
        "WARNING" = "Yellow"
        "ERROR" = "Red"
        "PROGRESS" = "Magenta"
    }
    
    $color = $colorMap[$Level]
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# Function to calculate and display historical date range
function Show-HistoricalDateRange {
    # Fixed start date: November 1st, 2022
    $startDate = Get-Date -Year 2022 -Month 11 -Day 1
    $endDate = Get-Date
    
    # Calculate total days in the period
    $totalDays = ($endDate - $startDate).Days + 1
    
    # Calculate 82% coverage
    $targetDays = [Math]::Floor($totalDays * 0.82)
    
    # Estimate total commits
    $avgCommitsPerDay = 20  # Conservative estimate
    $estimatedTotalCommits = $targetDays * $avgCommitsPerDay
    
    Write-Host ""
    Write-Host "=== ENHANCED HISTORICAL BACKDATED GITHUB COMMIT SYSTEM ===" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "📅 HISTORICAL DATE RANGE:" -ForegroundColor Cyan
    Write-Host "  Start Date: $($startDate.ToString('yyyy-MM-dd')) (November 1st, 2022)" -ForegroundColor White
    Write-Host "  End Date: $($endDate.ToString('yyyy-MM-dd')) (Today)" -ForegroundColor White
    Write-Host "  Total Days: $totalDays days" -ForegroundColor White
    Write-Host "  Period Duration: $([Math]::Round(($endDate - $startDate).TotalDays / 365.25, 1)) years" -ForegroundColor White
    Write-Host ""
    Write-Host "📊 COVERAGE STATISTICS:" -ForegroundColor Cyan
    Write-Host "  Target Coverage: 82%" -ForegroundColor White
    Write-Host "  Days with commits: $targetDays" -ForegroundColor Green
    Write-Host "  Days without commits: $($totalDays - $targetDays)" -ForegroundColor Yellow
    Write-Host "  Coverage percentage: $([Math]::Round(($targetDays / $totalDays) * 100, 1))%" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 INTENSITY DISTRIBUTION:" -ForegroundColor Cyan
    Write-Host "  Level 3 (Light Green): 5-10 commits per day (40% of days)" -ForegroundColor White
    Write-Host "  Level 4 (Medium Green): 15-20 commits per day (40% of days)" -ForegroundColor White
    Write-Host "  Level 5 (Dark Green): 20-50 commits per day (20% of days)" -ForegroundColor White
    Write-Host ""
    Write-Host "📈 ESTIMATED TOTALS:" -ForegroundColor Cyan
    Write-Host "  Estimated total commits: ~$estimatedTotalCommits" -ForegroundColor Green
    Write-Host "  Estimated execution time: $([Math]::Ceiling($estimatedTotalCommits / 200)) minutes" -ForegroundColor White
    Write-Host ""
    Write-Host "🔧 GITHUB CONFIGURATION:" -ForegroundColor Cyan
    Write-Host "  Username: $($GitHubConfig.Username)" -ForegroundColor White
    Write-Host "  Repository: $($GitHubConfig.Repository)" -ForegroundColor White
    Write-Host "  Remote URL: $($GitHubConfig.RemoteURL)" -ForegroundColor White
    Write-Host ""
    
    return @{
        StartDate = $startDate
        EndDate = $endDate
        TotalDays = $totalDays
        TargetDays = $targetDays
        EstimatedCommits = $estimatedTotalCommits
    }
}

# Function to validate GitHub access
function Test-GitHubAccess {
    Write-Log "Validating GitHub credentials and repository access..." "INFO"
    
    try {
        # Test API access
        $headers = @{
            "Authorization" = "token $($GitHubConfig.Token)"
            "Accept" = "application/vnd.github.v3+json"
        }
        
        $userResponse = Invoke-RestMethod -Uri "$($GitHubConfig.BaseAPIURL)/user" -Headers $headers -Method Get
        Write-Log "Successfully authenticated as user: $($userResponse.login)" "SUCCESS"
        
        # Test repository access
        $repoResponse = Invoke-RestMethod -Uri "$($GitHubConfig.BaseAPIURL)/repos/$($GitHubConfig.Username)/$($GitHubConfig.Repository)" -Headers $headers -Method Get
        Write-Log "Successfully accessed repository: $($repoResponse.full_name)" "SUCCESS"
        
        return $true
    }
    catch {
        Write-Log "GitHub access validation failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Function to get user confirmation
function Get-UserConfirmation {
    param(
        [hashtable]$DateInfo
    )
    
    if ($SkipConfirmation) {
        Write-Log "Skipping confirmation as requested" "WARNING"
        return $true
    }
    
    Write-Host ""
    Write-Host "⚠️  IMPORTANT CONFIRMATION REQUIRED ⚠️" -ForegroundColor Red
    Write-Host ""
    Write-Host "This system will:" -ForegroundColor Yellow
    Write-Host "  • Create approximately $($DateInfo.EstimatedCommits) backdated commits" -ForegroundColor White
    Write-Host "  • Span the period from $($DateInfo.StartDate.ToString('yyyy-MM-dd')) to $($DateInfo.EndDate.ToString('yyyy-MM-dd'))" -ForegroundColor White
    Write-Host "  • Cover $($DateInfo.TargetDays) days out of $($DateInfo.TotalDays) total days (82% coverage)" -ForegroundColor White
    Write-Host "  • Push all changes to your GitHub repository: $($GitHubConfig.RemoteURL)" -ForegroundColor White
    Write-Host "  • Modify your GitHub contribution graph for the entire historical period" -ForegroundColor White
    Write-Host ""
    Write-Host "Execution will take approximately $([Math]::Ceiling($DateInfo.EstimatedCommits / 200)) minutes." -ForegroundColor Yellow
    Write-Host ""
    
    do {
        $response = Read-Host "Do you want to proceed? (yes/no/test)"
        $response = $response.ToLower().Trim()
        
        switch ($response) {
            "yes" { 
                Write-Log "User confirmed execution" "SUCCESS"
                return $true 
            }
            "y" { 
                Write-Log "User confirmed execution" "SUCCESS"
                return $true 
            }
            "no" { 
                Write-Log "User cancelled execution" "WARNING"
                return $false 
            }
            "n" { 
                Write-Log "User cancelled execution" "WARNING"
                return $false 
            }
            "test" {
                Write-Log "User selected test mode" "INFO"
                return "test"
            }
            default {
                Write-Host "Please enter 'yes', 'no', or 'test'" -ForegroundColor Red
            }
        }
    } while ($true)
}

# Main execution
try {
    Set-Location $repoPath
    
    Write-Host "Enhanced Historical Backdated GitHub Commit System v2.0" -ForegroundColor Magenta
    Write-Host "Repository: $repoPath" -ForegroundColor White
    Write-Host ""
    
    # Show date range and get confirmation
    $dateInfo = Show-HistoricalDateRange
    
    if ($TestMode) {
        Write-Log "Running in TEST MODE" "INFO"
        & "$repoPath\test_backdate_system.ps1"
        exit 0
    }
    
    if ($DryRun) {
        Write-Log "Running in DRY-RUN MODE" "INFO"
        Write-Log "This would create $($dateInfo.EstimatedCommits) commits across $($dateInfo.TargetDays) days" "INFO"
        Write-Log "No actual commits will be created" "SUCCESS"
        exit 0
    }
    
    # Validate GitHub access
    if (-not (Test-GitHubAccess)) {
        throw "GitHub access validation failed. Please check your credentials."
    }
    
    # Get user confirmation
    $confirmation = Get-UserConfirmation -DateInfo $dateInfo
    
    if ($confirmation -eq $false) {
        Write-Log "Execution cancelled by user" "WARNING"
        exit 0
    }
    elseif ($confirmation -eq "test") {
        Write-Log "Switching to test mode" "INFO"
        & "$repoPath\test_backdate_system.ps1"
        exit 0
    }
    
    # Execute the main system
    Write-Log "Starting enhanced historical backdated commit system..." "SUCCESS"
    Write-Log "This will create commits from November 1st, 2022 to present" "INFO"
    
    # Run the comprehensive system
    & "$repoPath\comprehensive_backdate_system.ps1" -Force:$Force
    
    Write-Log "Enhanced historical backdated commit system completed!" "SUCCESS"
    Write-Log "Check your GitHub profile: https://github.com/$($GitHubConfig.Username)" "INFO"
    
}
catch {
    Write-Log "Execution failed: $($_.Exception.Message)" "ERROR"
    Write-Log $_.ScriptStackTrace "ERROR"
    exit 1
}
finally {
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
