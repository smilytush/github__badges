# Simple Test Mode - Creates 5 sample backdated commits
# This is a simplified version for quick testing

# GitHub Configuration
$GitHubConfig = @{
    Username = "smilytush"
    Email = "tushar161@hotmail.com"
    Token = $env:GITHUB_TOKEN  # Use environment variable for security
    Repository = "github-commits"
    RemoteURL = "https://github.com/smilytush/github-commits.git"
}

$repoPath = "J:\green-commits"

# Enhanced logging function
function Write-SimpleLog {
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

# Function to create a simple backdated commit
function New-SimpleBackdatedCommit {
    param(
        [string]$CommitDate,
        [int]$CommitNumber = 1
    )

    try {
        # Generate commit time
        $hour = Get-Random -Minimum 9 -Maximum 18
        $minute = Get-Random -Minimum 0 -Maximum 60
        $second = Get-Random -Minimum 0 -Maximum 60
        $commitTime = "$CommitDate $($hour.ToString('00')):$($minute.ToString('00')):$($second.ToString('00'))"

        # Create simple file content
        $fileContent = @"
# Test Backdated Commit
Date: $CommitDate
Time: $commitTime
Commit Number: $CommitNumber
Random ID: $(Get-Random -Maximum 1000000)

This is a test commit to verify the backdating functionality works correctly.
The commit should appear on $CommitDate in the GitHub contribution graph.
"@

        # Create file path
        $fileName = "test-$CommitDate-$CommitNumber.md"
        $filePath = Join-Path $repoPath "test-commits" $fileName

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
        $env:GIT_COMMITTER_DATE = $commitTime
        $env:GIT_AUTHOR_DATE = $commitTime

        # Make the commit with proper backdating
        $commitMessage = "Test commit for $CommitDate (#$CommitNumber)"
        git commit -m $commitMessage --date=$commitTime

        if ($LASTEXITCODE -eq 0) {
            Write-SimpleLog "Created backdated commit: $commitMessage" "SUCCESS"
            return $true
        } else {
            throw "Git commit failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Write-SimpleLog "Failed to create backdated commit for $CommitDate #$CommitNumber : $($_.Exception.Message)" "ERROR"
        return $false
    }
    finally {
        # Always reset environment variables
        $env:GIT_COMMITTER_DATE = ""
        $env:GIT_AUTHOR_DATE = ""
    }
}

# Main execution
try {
    Write-SimpleLog "=== SIMPLE TEST MODE - 5 SAMPLE BACKDATED COMMITS ===" "INFO"
    Write-SimpleLog "This will create 5 test commits across different historical dates" "INFO"
    Write-Host ""

    # Ensure we're in the correct directory
    if (-not (Test-Path $repoPath)) {
        New-Item -ItemType Directory -Path $repoPath -Force | Out-Null
        Write-SimpleLog "Created repository directory: $repoPath" "SUCCESS"
    }

    Set-Location $repoPath

    # Initialize git repository if needed
    if (-not (Test-Path ".git")) {
        git init
        Write-SimpleLog "Initialized Git repository" "SUCCESS"
    }

    # Configure git
    git config user.name $GitHubConfig.Username
    git config user.email $GitHubConfig.Email
    Write-SimpleLog "Git configuration set" "SUCCESS"

    # Configure remote URL with token
    $remoteUrlWithToken = $GitHubConfig.RemoteURL -replace "https://", "https://$($GitHubConfig.Token)@"

    # Check if remote exists
    $existingRemote = git remote get-url origin 2>$null
    if ($existingRemote) {
        git remote set-url origin $remoteUrlWithToken
        Write-SimpleLog "Updated existing remote URL" "SUCCESS"
    }
    else {
        git remote add origin $remoteUrlWithToken
        Write-SimpleLog "Added new remote URL" "SUCCESS"
    }

    # Test dates for backdated commits
    $testDates = @(
        "2022-11-15",  # Early in the historical period
        "2023-03-10",  # Q1 2023
        "2023-08-20",  # Q3 2023
        "2024-01-05",  # Q1 2024
        (Get-Date).AddDays(-30).ToString("yyyy-MM-dd")  # Recent date
    )

    $successCount = 0

    Write-SimpleLog "Creating test commits..." "PROGRESS"

    foreach ($testDate in $testDates) {
        Write-SimpleLog "Creating commit for $testDate..." "PROGRESS"

        $success = New-SimpleBackdatedCommit -CommitDate $testDate -CommitNumber 1

        if ($success) {
            $successCount++
            # Small delay to ensure commit is processed
            Start-Sleep -Seconds 1
        }
    }

    Write-SimpleLog "Created $successCount out of $($testDates.Count) test commits" "INFO"

    # Push test commits
    Write-SimpleLog "Pushing test commits to GitHub..." "PROGRESS"
    git push origin main

    if ($LASTEXITCODE -eq 0) {
        Write-SimpleLog "Test commits pushed successfully!" "SUCCESS"
        Write-Host ""
        Write-SimpleLog "=== TEST RESULTS ===" "SUCCESS"
        Write-SimpleLog "✓ $successCount backdated commits created" "SUCCESS"
        Write-SimpleLog "✓ All commits pushed to GitHub" "SUCCESS"
        Write-SimpleLog "✓ Check your GitHub profile: https://github.com/$($GitHubConfig.Username)" "SUCCESS"
        Write-Host ""
        Write-SimpleLog "The commits should appear on these dates in your contribution graph:" "INFO"
        foreach ($date in $testDates) {
            Write-SimpleLog "  - $date" "INFO"
        }
        Write-Host ""
        Write-SimpleLog "If you see the commits on the correct historical dates, the system is working!" "SUCCESS"
    } else {
        Write-SimpleLog "Failed to push test commits to GitHub" "ERROR"
        Write-SimpleLog "Please check your GitHub token and repository permissions" "ERROR"
    }

}
catch {
    Write-SimpleLog "Test execution failed: $($_.Exception.Message)" "ERROR"
    Write-SimpleLog $_.ScriptStackTrace "ERROR"
}
finally {
    # Reset environment variables
    $env:GIT_COMMITTER_DATE = ""
    $env:GIT_AUTHOR_DATE = ""

    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
