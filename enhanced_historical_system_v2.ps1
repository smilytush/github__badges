# Enhanced Historical Backdated GitHub Commit System v2.0
# Completely revised and error-corrected version
# Creates backdated commits from November 1st, 2022 to present with 82% coverage

param(
    [switch]$Force = $false,
    [switch]$ValidateOnly = $false,
    [switch]$TestMode = $false,
    [switch]$DryRun = $false,
    [switch]$SkipConfirmation = $false
)

# GitHub Configuration - Verified and Tested
$global:GitHubConfig = @{
    Username      = "smilytush"
    Email         = "tushar161@hotmail.com"
    Token         = "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"
    Repository    = "github-commits"
    RemoteURL     = "https://github.com/smilytush/github-commits.git"
    DefaultBranch = "main"
    BaseAPIURL    = "https://api.github.com"
}

# Global tracking variables
$global:CreatedCommits = @()
$global:ErrorLog = @()
$global:StartTime = Get-Date
$global:HistoricalPeriod = @{}
$global:ValidationResults = @{}

# Repository path
$repoPath = "J:\green-commits"

# Enhanced logging function with proper error handling
function Write-EnhancedLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $colorMap = @{
        "INFO"     = "Cyan"
        "SUCCESS"  = "Green"
        "WARNING"  = "Yellow"
        "ERROR"    = "Red"
        "PROGRESS" = "Magenta"
        "DEBUG"    = "Gray"
    }
    
    $color = $colorMap[$Level]
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
    
    # Safe file logging with error handling
    try {
        $logPath = Join-Path $repoPath "enhanced_historical_system_v2.log"
        "[$timestamp] [$Level] $Message" | Out-File -Append -FilePath $logPath -Encoding utf8 -ErrorAction SilentlyContinue
    }
    catch {
        # Silent fail for logging to prevent cascading errors
    }
    
    if ($Level -eq "ERROR") {
        $global:ErrorLog += @{
            Timestamp = $timestamp
            Message   = $Message
        }
    }
}

# Function to calculate historical date range with proper validation
function Get-HistoricalDateRange {
    try {
        # Fixed start date: November 1st, 2022
        $startDate = Get-Date -Year 2022 -Month 11 -Day 1
        $endDate = Get-Date
        
        # Calculate total days in the period
        $totalDays = ($endDate - $startDate).Days + 1
        
        # Calculate 82% coverage
        $targetDays = [Math]::Floor($totalDays * 0.82)
        
        Write-EnhancedLog "=== HISTORICAL PERIOD ANALYSIS ===" "INFO"
        Write-EnhancedLog "Start Date: $($startDate.ToString('yyyy-MM-dd'))" "INFO"
        Write-EnhancedLog "End Date: $($endDate.ToString('yyyy-MM-dd'))" "INFO"
        Write-EnhancedLog "Total Days: $totalDays" "INFO"
        Write-EnhancedLog "Target Coverage: 82% = $targetDays days" "INFO"
        Write-EnhancedLog "Days without commits: $($totalDays - $targetDays)" "INFO"
        Write-EnhancedLog "Period Duration: $([Math]::Round(($endDate - $startDate).TotalDays / 365.25, 1)) years" "INFO"
        
        # Store global variables for later use
        $global:HistoricalPeriod = @{
            StartDate  = $startDate
            EndDate    = $endDate
            TotalDays  = $totalDays
            TargetDays = $targetDays
        }
        
        return @{
            StartDate  = $startDate
            EndDate    = $endDate
            TotalDays  = $totalDays
            TargetDays = $targetDays
        }
    }
    catch {
        Write-EnhancedLog "Error calculating historical date range: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to validate GitHub credentials and repository access
function Test-GitHubAccess {
    Write-EnhancedLog "Validating GitHub credentials and repository access..." "INFO"
    
    try {
        # Test basic API access
        $headers = @{
            "Authorization" = "token $($global:GitHubConfig.Token)"
            "Accept"        = "application/vnd.github.v3+json"
            "User-Agent"    = "Enhanced-Historical-Backdate-System/2.0"
        }
        
        $userResponse = Invoke-RestMethod -Uri "$($global:GitHubConfig.BaseAPIURL)/user" -Headers $headers -Method Get -ErrorAction Stop
        Write-EnhancedLog "Successfully authenticated as user: $($userResponse.login)" "SUCCESS"
        
        # Test repository access
        try {
            $repoResponse = Invoke-RestMethod -Uri "$($global:GitHubConfig.BaseAPIURL)/repos/$($global:GitHubConfig.Username)/$($global:GitHubConfig.Repository)" -Headers $headers -Method Get -ErrorAction Stop
            Write-EnhancedLog "Successfully accessed repository: $($repoResponse.full_name)" "SUCCESS"
            $global:ValidationResults.RepositoryExists = $true
        }
        catch {
            if ($_.Exception.Response.StatusCode -eq 404) {
                Write-EnhancedLog "Repository 'github-commits' not found. It will be created automatically." "WARNING"
                $global:ValidationResults.RepositoryExists = $false
            }
            else {
                throw
            }
        }
        
        # Test GraphQL API access
        $graphqlHeaders = @{
            "Authorization" = "Bearer $($global:GitHubConfig.Token)"
            "Content-Type"  = "application/json"
            "User-Agent"    = "Enhanced-Historical-Backdate-System/2.0"
        }
        
        $simpleQuery = @{
            query = "query { viewer { login } }"
        } | ConvertTo-Json -Depth 10
        
        $graphqlResponse = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $graphqlHeaders -Body $simpleQuery -ErrorAction Stop
        
        if ($graphqlResponse.data.viewer) {
            Write-EnhancedLog "GraphQL API access confirmed for user: $($graphqlResponse.data.viewer.login)" "SUCCESS"
            $global:ValidationResults.GraphQLAccess = $true
        }
        else {
            Write-EnhancedLog "GraphQL API access failed - no viewer data returned" "ERROR"
            $global:ValidationResults.GraphQLAccess = $false
        }
        
        # Test rate limits
        $rateLimitResponse = Invoke-RestMethod -Uri "$($global:GitHubConfig.BaseAPIURL)/rate_limit" -Headers $headers -Method Get -ErrorAction Stop
        Write-EnhancedLog "Rate limits - Core: $($rateLimitResponse.resources.core.remaining)/$($rateLimitResponse.resources.core.limit), GraphQL: $($rateLimitResponse.resources.graphql.remaining)/$($rateLimitResponse.resources.graphql.limit)" "INFO"
        
        $global:ValidationResults.GitHubAccess = $true
        return $true
    }
    catch {
        Write-EnhancedLog "GitHub access validation failed: $($_.Exception.Message)" "ERROR"
        $global:ValidationResults.GitHubAccess = $false
        return $false
    }
}

# Function to configure Git with proper credentials and error handling
function Set-GitConfiguration {
    Write-EnhancedLog "Configuring Git with GitHub credentials..." "INFO"
    
    try {
        # Ensure we're in the correct directory
        if (-not (Test-Path $repoPath)) {
            New-Item -ItemType Directory -Path $repoPath -Force | Out-Null
            Write-EnhancedLog "Created repository directory: $repoPath" "INFO"
        }
        
        Set-Location $repoPath
        
        # Initialize git repository if needed
        if (-not (Test-Path ".git")) {
            git init
            Write-EnhancedLog "Initialized Git repository" "INFO"
        }
        
        # Configure user identity
        git config user.name $global:GitHubConfig.Username
        git config user.email $global:GitHubConfig.Email
        
        # Configure remote URL with token
        $remoteUrlWithToken = $global:GitHubConfig.RemoteURL -replace "https://", "https://$($global:GitHubConfig.Token)@"
        
        # Check if remote exists
        $existingRemote = git remote get-url origin 2>$null
        if ($existingRemote) {
            git remote set-url origin $remoteUrlWithToken
            Write-EnhancedLog "Updated existing remote URL" "INFO"
        }
        else {
            git remote add origin $remoteUrlWithToken
            Write-EnhancedLog "Added new remote URL" "INFO"
        }
        
        # Test remote connectivity
        git ls-remote origin 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-EnhancedLog "Git remote connectivity confirmed" "SUCCESS"
        }
        else {
            Write-EnhancedLog "Git remote connectivity test failed" "WARNING"
        }
        
        Write-EnhancedLog "Git configuration completed successfully" "SUCCESS"
        $global:ValidationResults.GitConfiguration = $true
        return $true
    }
    catch {
        Write-EnhancedLog "Git configuration failed: $($_.Exception.Message)" "ERROR"
        $global:ValidationResults.GitConfiguration = $false
        return $false
    }
}

# Function to generate realistic commit timestamps
function Get-RealisticCommitTime {
    param(
        [string]$Date
    )
    
    # Define time distribution: 60% business hours, 30% evening, 10% other
    $timeCategory = Get-Random -Minimum 1 -Maximum 101
    
    if ($timeCategory -le 60) {
        # Business hours: 9 AM - 6 PM
        $hour = Get-Random -Minimum 9 -Maximum 18
        $minute = Get-Random -Minimum 0 -Maximum 60
    }
    elseif ($timeCategory -le 90) {
        # Evening hours: 6 PM - 11 PM
        $hour = Get-Random -Minimum 18 -Maximum 23
        $minute = Get-Random -Minimum 0 -Maximum 60
    }
    else {
        # Other times: 11 PM - 9 AM
        $hourOptions = @(23, 0, 1, 2, 3, 4, 5, 6, 7, 8)
        $hour = $hourOptions | Get-Random
        $minute = Get-Random -Minimum 0 -Maximum 60
    }
    
    $second = Get-Random -Minimum 0 -Maximum 60
    
    return "$Date $($hour.ToString('00')):$($minute.ToString('00')):$($second.ToString('00'))"
}

# Enhanced commit message generator with professional messages
function Get-ProfessionalCommitMessage {
    param(
        [string]$FileType,
        [int]$CommitNumber
    )

    $messages = @{
        "python"     = @(
            "Add data processing functionality",
            "Implement error handling for API calls",
            "Optimize database query performance",
            "Add unit tests for core functions",
            "Fix memory leak in data parser",
            "Update dependencies and requirements",
            "Refactor code for better maintainability",
            "Add logging and monitoring features",
            "Implement async data processing",
            "Add input validation and sanitization",
            "Optimize algorithm performance",
            "Fix edge case in data transformation",
            "Add comprehensive error reporting",
            "Implement caching mechanism",
            "Update API endpoint handlers",
            "Add data export functionality",
            "Implement batch processing",
            "Fix timezone handling issues",
            "Add configuration management",
            "Implement retry logic for failed operations"
        )
        "solidity"   = @(
            "Add smart contract security checks",
            "Implement gas optimization",
            "Add event logging for transactions",
            "Fix reentrancy vulnerability",
            "Update contract interface",
            "Add access control modifiers",
            "Implement emergency pause functionality",
            "Add comprehensive test coverage",
            "Optimize storage layout",
            "Implement upgradeable proxy pattern",
            "Add multi-signature wallet support",
            "Fix integer overflow protection",
            "Implement time-locked functions",
            "Add oracle integration",
            "Optimize function visibility",
            "Implement batch operations",
            "Add contract verification",
            "Fix front-running protection",
            "Implement governance mechanisms",
            "Add automated testing suite"
        )
        "typescript" = @(
            "Add type definitions for API responses",
            "Implement async/await pattern",
            "Add error boundary components",
            "Optimize bundle size and performance",
            "Add comprehensive unit tests",
            "Update TypeScript to latest version",
            "Implement state management",
            "Add responsive design features",
            "Optimize component rendering",
            "Implement lazy loading",
            "Add form validation logic",
            "Fix type inference issues",
            "Implement custom hooks",
            "Add internationalization support",
            "Optimize webpack configuration",
            "Implement service workers",
            "Add accessibility features",
            "Fix memory leak in components",
            "Implement virtual scrolling",
            "Add theme switching functionality"
        )
    }

    $messageArray = $messages[$FileType]
    if (-not $messageArray) {
        $messageArray = $messages["python"]  # Default fallback
    }

    return $messageArray | Get-Random
}

# Function to generate realistic file content with proper syntax
function New-RealisticFileContent {
    param(
        [string]$FileType,
        [string]$CommitDate,
        [int]$IntensityLevel,
        [int]$CommitNumber
    )

    $randomValue = Get-Random -Maximum 100
    $randomSeed = Get-Random -Maximum 1000000
    $randomId = Get-Random -Maximum 2147483647

    $content = @"
# $FileType Development - $CommitDate
# Commit #$CommitNumber - Intensity Level: $IntensityLevel
# Generated on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

"@

    switch ($FileType) {
        "python" {
            $content += @"
``````python
def process_data_$CommitNumber(data, intensity=$IntensityLevel):
    '''Process data with specified intensity level'''
    result = []
    for item in data:
        if item > 0:
            processed = item * intensity + $randomValue
            result.append(processed)
    return result
``````
"@
        }
        "solidity" {
            $content += @"
``````solidity
pragma solidity ^0.8.0;

contract DataProcessor$CommitNumber {
    uint256 public intensity = $IntensityLevel;
    uint256 private randomSeed = $randomSeed;

    function processValue(uint256 input) public view returns (uint256) {
        return input * intensity + randomSeed % 100;
    }
}
``````
"@
        }
        "typescript" {
            $content += @"
``````typescript
interface DataProcessor$CommitNumber {
    intensity: number;
    process(data: number[]): Promise<number[]>;
}

class Processor$CommitNumber implements DataProcessor$CommitNumber {
    public intensity: number = $IntensityLevel;
    private randomFactor: number = $randomValue;

    async process(data: number[]): Promise<number[]> {
        return data.map(item => item * this.intensity + this.randomFactor);
    }
}
``````
"@
        }
    }

    $content += @"

## Metadata
- Date: $CommitDate
- Intensity: $IntensityLevel
- Commit Number: $CommitNumber
- Random ID: $randomId
"@

    return $content
}

# Function to create a backdated commit with comprehensive error handling
function New-BackdatedCommit {
    param(
        [string]$CommitDate,
        [int]$IntensityLevel = 5,
        [int]$CommitNumber = 1,
        [string]$CommitTime = ""
    )

    try {
        # Generate realistic commit time if not provided
        if ([string]::IsNullOrEmpty($CommitTime)) {
            $CommitTime = Get-RealisticCommitTime -Date $CommitDate
        }

        # Determine file type based on commit number
        $fileTypes = @("python", "solidity", "typescript")
        $fileType = $fileTypes[($CommitNumber - 1) % $fileTypes.Length]

        # Generate realistic commit message
        $commitMessage = Get-ProfessionalCommitMessage -FileType $fileType -CommitNumber $CommitNumber

        # Create realistic file content
        $fileContent = New-RealisticFileContent -FileType $fileType -CommitDate $CommitDate -IntensityLevel $IntensityLevel -CommitNumber $CommitNumber

        # Create file path
        $fileName = "$CommitDate-$CommitNumber-$fileType.md"
        $filePath = Join-Path (Join-Path $repoPath "src") $fileName

        # Ensure directory exists
        $directory = Split-Path $filePath -Parent
        if (-not (Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }

        # Write content to file
        $fileContent | Out-File -FilePath $filePath -Encoding utf8 -Force

        # Add file to git
        git add $filePath
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to add file to git: $filePath"
        }

        # Set environment variables for backdating
        $env:GIT_COMMITTER_DATE = $CommitTime
        $env:GIT_AUTHOR_DATE = $CommitTime

        # Make the commit with proper backdating
        git commit -m $commitMessage --date=$CommitTime

        if ($LASTEXITCODE -eq 0) {
            # Track successful commit
            $global:CreatedCommits += @{
                Date      = $CommitDate
                Time      = $CommitTime
                Intensity = $IntensityLevel
                Number    = $CommitNumber
                Message   = $commitMessage
                FilePath  = $filePath
                FileType  = $fileType
            }

            Write-EnhancedLog "Created backdated commit: $commitMessage ($CommitDate #$CommitNumber)" "SUCCESS"
            return $true
        }
        else {
            throw "Git commit failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Write-EnhancedLog "Failed to create backdated commit for $CommitDate #$CommitNumber : $($_.Exception.Message)" "ERROR"
        return $false
    }
    finally {
        # Always reset environment variables
        $env:GIT_COMMITTER_DATE = ""
        $env:GIT_AUTHOR_DATE = ""
    }
}

# Function to generate random days from historical period
function Get-RandomHistoricalDays {
    param(
        [hashtable]$DateRange
    )

    try {
        Write-EnhancedLog "Generating random days from historical period..." "INFO"

        # Generate all possible days
        $allDays = @()
        $currentDate = $DateRange.StartDate
        while ($currentDate -le $DateRange.EndDate) {
            $allDays += $currentDate
            $currentDate = $currentDate.AddDays(1)
        }

        # Randomly select the target number of days
        $selectedDays = $allDays | Get-Random -Count $DateRange.TargetDays

        Write-EnhancedLog "Selected $($DateRange.TargetDays) days out of $($allDays.Count) possible days" "SUCCESS"

        return $selectedDays | Sort-Object
    }
    catch {
        Write-EnhancedLog "Error generating random historical days: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to assign intensity levels using 10-day cycle pattern
function Set-IntensityLevels {
    param(
        [array]$SelectedDays
    )

    Write-EnhancedLog "Assigning intensity levels using 10-day cycle pattern..." "INFO"

    $dayIntensities = @{}

    # Group days by 10-day periods
    $tenDayGroups = @{}
    foreach ($day in $SelectedDays) {
        $dayOfYear = $day.DayOfYear
        $tenDayPeriod = [Math]::Ceiling($dayOfYear / 10.0)

        if (-not $tenDayGroups.ContainsKey($tenDayPeriod)) {
            $tenDayGroups[$tenDayPeriod] = @()
        }
        $tenDayGroups[$tenDayPeriod] += $day
    }

    # Assign intensities within each 10-day period
    foreach ($period in $tenDayGroups.Keys) {
        $daysInPeriod = $tenDayGroups[$period]
        $totalDays = $daysInPeriod.Count

        if ($totalDays -eq 0) { continue }

        # Calculate distribution: 20% dark green, 40% medium green, 40% light green
        $level5Count = [Math]::Max(1, [Math]::Ceiling($totalDays * 0.2))  # 20% dark green
        $level4Count = [Math]::Max(1, [Math]::Ceiling($totalDays * 0.4))  # 40% medium green
        $level3Count = $totalDays - $level5Count - $level4Count           # Remaining light green

        # Ensure we don't exceed available days
        if (($level5Count + $level4Count) -gt $totalDays) {
            $level4Count = $totalDays - $level5Count
            $level3Count = 0
        }

        # Randomly assign days to each intensity level
        $shuffledDays = $daysInPeriod | Sort-Object { Get-Random }

        for ($i = 0; $i -lt $level5Count; $i++) {
            $dayIntensities[$shuffledDays[$i]] = 5
        }

        for ($i = $level5Count; $i -lt ($level5Count + $level4Count); $i++) {
            $dayIntensities[$shuffledDays[$i]] = 4
        }

        for ($i = ($level5Count + $level4Count); $i -lt $totalDays; $i++) {
            $dayIntensities[$shuffledDays[$i]] = 3
        }
    }

    # Count assignments
    $level3Count = ($dayIntensities.Values | Where-Object { $_ -eq 3 }).Count
    $level4Count = ($dayIntensities.Values | Where-Object { $_ -eq 4 }).Count
    $level5Count = ($dayIntensities.Values | Where-Object { $_ -eq 5 }).Count

    Write-EnhancedLog "Intensity distribution: Level 3 (Light): $level3Count days, Level 4 (Medium): $level4Count days, Level 5 (Dark): $level5Count days" "SUCCESS"

    return $dayIntensities
}

# Function to determine number of commits per day based on intensity
function Get-CommitsPerDay {
    param(
        [int]$IntensityLevel
    )

    switch ($IntensityLevel) {
        3 { return Get-Random -Minimum 5 -Maximum 11 }   # Level 3: 5-10 commits
        4 { return Get-Random -Minimum 15 -Maximum 21 }  # Level 4: 15-20 commits
        5 { return Get-Random -Minimum 20 -Maximum 51 }  # Level 5: 20-50 commits
        default { return Get-Random -Minimum 5 -Maximum 11 }
    }
}

# Function to verify contribution graph using GitHub GraphQL API
function Test-ContributionGraphAPI {
    param(
        [string]$Username,
        [string]$FromDate,
        [string]$ToDate
    )

    try {
        $headers = @{
            "Authorization" = "Bearer $($global:GitHubConfig.Token)"
            "Content-Type"  = "application/json"
            "User-Agent"    = "Enhanced-Historical-Backdate-System/2.0"
        }

        $graphqlQuery = @"
query {
  user(login: "$Username") {
    contributionsCollection(from: "${FromDate}T00:00:00Z", to: "${ToDate}T23:59:59Z") {
      contributionCalendar {
        totalContributions
        weeks {
          contributionDays {
            date
            contributionCount
            color
          }
        }
      }
    }
  }
}
"@

        $queryBody = @{
            query = $graphqlQuery
        } | ConvertTo-Json -Depth 10

        $response = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headers -Body $queryBody -ErrorAction Stop

        if ($response.data.user) {
            return $response.data.user.contributionsCollection.contributionCalendar
        }
        else {
            Write-EnhancedLog "GitHub GraphQL API returned no user data" "ERROR"
            return $null
        }
    }
    catch {
        Write-EnhancedLog "GitHub GraphQL API test failed: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

# Function to verify specific date has contributions
function Test-DateContributions {
    param(
        [string]$Date,
        [int]$ExpectedMinCount = 1
    )

    try {
        $nextDay = ([datetime]::ParseExact($Date, "yyyy-MM-dd", $null)).AddDays(1).ToString("yyyy-MM-dd")
        $contributionData = Test-ContributionGraphAPI -Username $global:GitHubConfig.Username -FromDate $Date -ToDate $nextDay

        if ($contributionData) {
            $dayData = $contributionData.weeks.contributionDays | Where-Object { $_.date -eq $Date }
            if ($dayData -and $dayData.contributionCount -ge $ExpectedMinCount) {
                Write-EnhancedLog "Date $Date has $($dayData.contributionCount) contributions (expected: $ExpectedMinCount+)" "SUCCESS"
                return $true
            }
            else {
                $actualCount = if ($dayData) { $dayData.contributionCount } else { 0 }
                Write-EnhancedLog "Date $Date has insufficient contributions (found: $actualCount, expected: $ExpectedMinCount+)" "WARNING"
                return $false
            }
        }

        return $false
    }
    catch {
        Write-EnhancedLog "Failed to verify contributions for $Date : $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Function to push changes to GitHub with error handling
function Push-ToGitHub {
    param(
        [switch]$Force = $false
    )

    Write-EnhancedLog "Pushing changes to GitHub repository..." "INFO"

    try {
        if ($Force) {
            git push -f origin $global:GitHubConfig.DefaultBranch
        }
        else {
            git push origin $global:GitHubConfig.DefaultBranch
        }

        if ($LASTEXITCODE -eq 0) {
            Write-EnhancedLog "Successfully pushed changes to GitHub" "SUCCESS"
            return $true
        }
        else {
            throw "Git push failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Write-EnhancedLog "Failed to push to GitHub: $($_.Exception.Message)" "ERROR"

        if (-not $Force) {
            Write-EnhancedLog "Attempting force push..." "WARNING"
            return Push-ToGitHub -Force
        }

        return $false
    }
}

# Function to run test mode with 5 sample commits
function Start-TestMode {
    Write-EnhancedLog "=== RUNNING TEST MODE ===" "INFO"
    Write-EnhancedLog "Creating 5 sample backdated commits across different historical dates" "INFO"

    $testDates = @(
        "2022-11-15", # Early in the historical period
        "2023-03-10", # Q1 2023
        "2023-08-20", # Q3 2023
        "2024-01-05", # Q1 2024
        (Get-Date).AddDays(-30).ToString("yyyy-MM-dd")  # Recent date
    )

    $successCount = 0

    foreach ($testDate in $testDates) {
        Write-EnhancedLog "Creating test commit for $testDate..." "PROGRESS"

        $success = New-BackdatedCommit -CommitDate $testDate -IntensityLevel 5 -CommitNumber 1

        if ($success) {
            $successCount++
            # Small delay to ensure commit is processed
            Start-Sleep -Seconds 1
        }
    }

    # Push test commits
    Write-EnhancedLog "Pushing test commits to GitHub..." "INFO"
    $pushSuccess = Push-ToGitHub

    if ($pushSuccess) {
        Write-EnhancedLog "Test commits pushed successfully" "SUCCESS"
        Write-EnhancedLog "Waiting 10 seconds for GitHub to process commits..." "INFO"
        Start-Sleep -Seconds 10

        # Verify each test commit
        Write-EnhancedLog "Verifying test commits appear on contribution graph..." "INFO"
        $verifiedCount = 0

        foreach ($testDate in $testDates) {
            Write-EnhancedLog "Verifying $testDate..." "PROGRESS"
            $verified = Test-DateContributions -Date $testDate -ExpectedMinCount 1

            if ($verified) {
                $verifiedCount++
            }
        }

        Write-EnhancedLog "Test Results: $successCount/$($testDates.Count) commits created, $verifiedCount/$($testDates.Count) verified on contribution graph" "SUCCESS"

        if ($verifiedCount -eq $testDates.Count) {
            Write-EnhancedLog "All test commits verified successfully! Backdating is working correctly." "SUCCESS"
        }
        else {
            Write-EnhancedLog "Some test commits failed verification. Check your GitHub profile manually." "WARNING"
        }
    }
    else {
        Write-EnhancedLog "Failed to push test commits" "ERROR"
    }

    Write-EnhancedLog "Check your GitHub profile: https://github.com/$($global:GitHubConfig.Username)" "INFO"
}

# Function to generate summary report
function New-SummaryReport {
    $endTime = Get-Date
    $duration = $endTime - $global:StartTime

    Write-EnhancedLog "=== ENHANCED HISTORICAL BACKDATE SYSTEM SUMMARY REPORT ===" "SUCCESS"
    Write-EnhancedLog "Execution started: $($global:StartTime.ToString('yyyy-MM-dd HH:mm:ss'))" "INFO"
    Write-EnhancedLog "Execution completed: $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))" "INFO"
    Write-EnhancedLog "Total duration: $($duration.ToString('hh\:mm\:ss'))" "INFO"
    Write-EnhancedLog "Total commits created: $($global:CreatedCommits.Count)" "SUCCESS"

    if ($global:CreatedCommits.Count -gt 0) {
        # Group by intensity level
        $level3Commits = ($global:CreatedCommits | Where-Object { $_.Intensity -eq 3 }).Count
        $level4Commits = ($global:CreatedCommits | Where-Object { $_.Intensity -eq 4 }).Count
        $level5Commits = ($global:CreatedCommits | Where-Object { $_.Intensity -eq 5 }).Count

        Write-EnhancedLog "Commits by intensity: Level 3: $level3Commits, Level 4: $level4Commits, Level 5: $level5Commits" "INFO"

        # Group by date
        $uniqueDates = ($global:CreatedCommits | Group-Object Date).Count
        Write-EnhancedLog "Unique dates with commits: $uniqueDates" "INFO"

        # Show date range
        $sortedCommits = $global:CreatedCommits | Sort-Object Date
        $firstDate = $sortedCommits[0].Date
        $lastDate = $sortedCommits[-1].Date
        Write-EnhancedLog "Date range: $firstDate to $lastDate" "INFO"
    }

    if ($global:ErrorLog.Count -gt 0) {
        Write-EnhancedLog "Errors encountered: $($global:ErrorLog.Count)" "WARNING"
        $global:ErrorLog | Select-Object -First 5 | ForEach-Object {
            Write-EnhancedLog "  - $($_.Timestamp): $($_.Message)" "ERROR"
        }
        if ($global:ErrorLog.Count -gt 5) {
            Write-EnhancedLog "  ... and $($global:ErrorLog.Count - 5) more errors" "ERROR"
        }
    }
    else {
        Write-EnhancedLog "No errors encountered during execution" "SUCCESS"
    }

    Write-EnhancedLog "GitHub Profile: https://github.com/$($global:GitHubConfig.Username)" "INFO"
    Write-EnhancedLog "Repository: $($global:GitHubConfig.RemoteURL)" "INFO"
    Write-EnhancedLog "=== END SUMMARY REPORT ===" "SUCCESS"
}

# Function to get user confirmation
function Get-UserConfirmation {
    param(
        [hashtable]$DateInfo
    )

    if ($SkipConfirmation) {
        Write-EnhancedLog "Skipping confirmation as requested" "WARNING"
        return $true
    }

    Write-Host ""
    Write-Host "⚠️  IMPORTANT CONFIRMATION REQUIRED ⚠️" -ForegroundColor Red
    Write-Host ""
    Write-Host "This system will:" -ForegroundColor Yellow
    Write-Host "  • Create backdated commits from $($DateInfo.StartDate.ToString('yyyy-MM-dd')) to $($DateInfo.EndDate.ToString('yyyy-MM-dd'))" -ForegroundColor White
    Write-Host "  • Cover $($DateInfo.TargetDays) days out of $($DateInfo.TotalDays) total days (82% coverage)" -ForegroundColor White
    Write-Host "  • Create approximately $($DateInfo.TargetDays * 20) commits (estimated)" -ForegroundColor White
    Write-Host "  • Push all changes to: $($global:GitHubConfig.RemoteURL)" -ForegroundColor White
    Write-Host "  • Modify your GitHub contribution graph for the entire historical period" -ForegroundColor White
    Write-Host ""

    do {
        $response = Read-Host "Do you want to proceed? (yes/no/test)"
        $response = $response.ToLower().Trim()

        switch ($response) {
            "yes" {
                Write-EnhancedLog "User confirmed execution" "SUCCESS"
                return $true
            }
            "y" {
                Write-EnhancedLog "User confirmed execution" "SUCCESS"
                return $true
            }
            "no" {
                Write-EnhancedLog "User cancelled execution" "WARNING"
                return $false
            }
            "n" {
                Write-EnhancedLog "User cancelled execution" "WARNING"
                return $false
            }
            "test" {
                Write-EnhancedLog "User selected test mode" "INFO"
                return "test"
            }
            default {
                Write-Host "Please enter 'yes', 'no', or 'test'" -ForegroundColor Red
            }
        }
    } while ($true)
}

# Main execution function
function Start-EnhancedHistoricalSystem {
    try {
        Write-EnhancedLog "Starting Enhanced Historical Backdated GitHub Commit System v2.0..." "INFO"
        Write-EnhancedLog "Target: November 1st, 2022 to present with 82% coverage" "INFO"

        # Validate GitHub access first
        if (-not (Test-GitHubAccess)) {
            throw "GitHub access validation failed. Please check your credentials."
        }

        # Configure Git
        if (-not (Set-GitConfiguration)) {
            throw "Git configuration failed."
        }

        # Calculate historical date range
        $dateRange = Get-HistoricalDateRange

        # If validation only, exit here
        if ($ValidateOnly) {
            Write-EnhancedLog "Validation completed successfully. Exiting as requested." "SUCCESS"
            return
        }

        # If test mode, run test and exit
        if ($TestMode -and -not $env:FORCE_FULL_MODE) {
            Start-TestMode
            return
        }

        # If dry run, show what would be done
        if ($DryRun) {
            Write-EnhancedLog "=== DRY RUN MODE ===" "INFO"
            Write-EnhancedLog "This would create commits for $($dateRange.TargetDays) days out of $($dateRange.TotalDays) total days" "INFO"
            Write-EnhancedLog "Estimated total commits: $($dateRange.TargetDays * 20)" "INFO"
            Write-EnhancedLog "No actual commits will be created" "SUCCESS"
            return
        }

        # Get user confirmation
        $confirmation = Get-UserConfirmation -DateInfo $dateRange

        if ($confirmation -eq $false) {
            Write-EnhancedLog "Execution cancelled by user" "WARNING"
            return
        }
        elseif ($confirmation -eq "test" -and -not $env:FORCE_FULL_MODE) {
            Start-TestMode
            return
        }

        # Generate random days from historical period
        $selectedDays = Get-RandomHistoricalDays -DateRange $dateRange

        # Assign intensity levels
        $dayIntensities = Set-IntensityLevels -SelectedDays $selectedDays

        # Create commits for each selected day
        $totalDays = $selectedDays.Count
        $currentDay = 0
        $totalCommitsCreated = 0

        Write-EnhancedLog "Starting commit creation for $totalDays days..." "INFO"

        foreach ($day in $selectedDays) {
            $currentDay++
            $dateStr = $day.ToString("yyyy-MM-dd")
            $intensity = $dayIntensities[$day]
            $commitsPerDay = Get-CommitsPerDay -IntensityLevel $intensity

            Write-EnhancedLog "Processing day $currentDay/$totalDays : $dateStr (Intensity: $intensity, Commits: $commitsPerDay)" "PROGRESS"

            # Create commits for this day
            $daySuccessCount = 0
            for ($i = 1; $i -le $commitsPerDay; $i++) {
                $success = New-BackdatedCommit -CommitDate $dateStr -IntensityLevel $intensity -CommitNumber $i

                if ($success) {
                    $daySuccessCount++
                    $totalCommitsCreated++
                }

                # Small delay to avoid overwhelming the system
                Start-Sleep -Milliseconds 100

                # Longer delay every 10 commits
                if ($i % 10 -eq 0) {
                    Start-Sleep -Seconds 2
                }
            }

            Write-EnhancedLog "Day $dateStr completed: $daySuccessCount/$commitsPerDay commits created" "SUCCESS"

            # Push changes every 20 days to avoid losing work
            if ($currentDay % 20 -eq 0) {
                Write-EnhancedLog "Pushing intermediate changes (day $currentDay/$totalDays)..." "INFO"
                Push-ToGitHub | Out-Null
            }
        }

        # Final push
        Write-EnhancedLog "Pushing final changes to GitHub..." "INFO"
        if (-not (Push-ToGitHub -Force:$Force)) {
            throw "Failed to push final changes to GitHub"
        }

        # Generate summary report
        New-SummaryReport

        Write-EnhancedLog "Enhanced historical backdated commit system completed successfully!" "SUCCESS"
        Write-EnhancedLog "Total commits created: $totalCommitsCreated" "SUCCESS"
        Write-EnhancedLog "Please check your GitHub profile to verify the contribution graph: https://github.com/$($global:GitHubConfig.Username)" "INFO"

    }
    catch {
        Write-EnhancedLog "Critical error in main execution: $($_.Exception.Message)" "ERROR"
        Write-EnhancedLog $_.ScriptStackTrace "ERROR"

        # Generate error report
        New-SummaryReport

        throw
    }
}

# Main script execution
try {
    # Ensure we're in the correct directory
    if (-not (Test-Path $repoPath)) {
        New-Item -ItemType Directory -Path $repoPath -Force | Out-Null
    }
    Set-Location $repoPath

    Write-EnhancedLog "Enhanced Historical Backdated GitHub Commit System v2.0" "INFO"
    Write-EnhancedLog "Repository: $repoPath" "INFO"
    Write-EnhancedLog "GitHub User: $($global:GitHubConfig.Username)" "INFO"
    Write-EnhancedLog "Target Repository: $($global:GitHubConfig.RemoteURL)" "INFO"

    # Execute the main system
    Start-EnhancedHistoricalSystem

    Write-EnhancedLog "Script execution completed successfully!" "SUCCESS"
}
catch {
    Write-EnhancedLog "Script execution failed: $($_.Exception.Message)" "ERROR"
    Write-EnhancedLog $_.ScriptStackTrace "ERROR"
    exit 1
}
finally {
    # Reset environment variables
    $env:GIT_COMMITTER_DATE = ""
    $env:GIT_AUTHOR_DATE = ""

    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
