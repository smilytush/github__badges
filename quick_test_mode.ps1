# Quick Test Mode - Bypasses comprehensive tests and creates 5 sample commits directly
# This is the fastest way to test the backdating functionality

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

$GitHubConfig = @{
    Username = "smilytush"
    Email = "tushar161@hotmail.com"
    Token = "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"
    Repository = "github-commits"
    RemoteURL = "https://github.com/smilytush/github-commits.git"
}

$repoPath = "J:\green-commits"

function Write-QuickLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $colors = @{"INFO"="Cyan"; "SUCCESS"="Green"; "ERROR"="Red"; "PROGRESS"="Magenta"; "HEADER"="Blue"; "WARNING"="Yellow"}
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $colors[$Level]
}

function New-QuickBackdatedCommit {
    param([string]$CommitDate, [int]$CommitNumber = 1)
    
    $hour = Get-Random -Minimum 9 -Maximum 18
    $minute = Get-Random -Minimum 0 -Maximum 60
    $second = Get-Random -Minimum 0 -Maximum 60
    $commitTime = "$CommitDate $($hour.ToString('00')):$($minute.ToString('00')):$($second.ToString('00'))"
    
    $randomId = Get-Random -Maximum 1000000
    $fileContent = "# Quick Test Commit`n`nDate: $CommitDate`nTime: $commitTime`nNumber: $CommitNumber`nID: $randomId`n"
    
    $fileName = "quick-test-$CommitDate-$CommitNumber.md"
    $filePath = Join-Path (Join-Path $repoPath "quick-tests") $fileName
    
    $directory = Split-Path $filePath -Parent
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    $fileContent | Out-File -FilePath $filePath -Encoding utf8 -Force
    
    git add $filePath
    if ($LASTEXITCODE -ne 0) {
        Write-QuickLog "Failed to add file to git: $filePath" "ERROR"
        return $false
    }
    
    $env:GIT_COMMITTER_DATE = $commitTime
    $env:GIT_AUTHOR_DATE = $commitTime
    
    $commitMessage = "Quick test commit for $CommitDate (#$CommitNumber)"
    git commit -m $commitMessage --date=$commitTime
    
    $env:GIT_COMMITTER_DATE = ""
    $env:GIT_AUTHOR_DATE = ""
    
    if ($LASTEXITCODE -eq 0) {
        Write-QuickLog "Created backdated commit: $commitMessage" "SUCCESS"
        return $true
    } else {
        Write-QuickLog "Git commit failed with exit code $LASTEXITCODE" "ERROR"
        return $false
    }
}

Write-QuickLog "=== QUICK TEST MODE - 5 SAMPLE BACKDATED COMMITS ===" "HEADER"
Write-QuickLog "Creating test commits across different historical dates" "INFO"
Write-Host ""

try {
    if (-not (Test-Path $repoPath)) {
        New-Item -ItemType Directory -Path $repoPath -Force | Out-Null
        Write-QuickLog "Created repository directory: $repoPath" "SUCCESS"
    }
    
    Set-Location $repoPath
    Write-QuickLog "Working directory: $repoPath" "INFO"
    
    if (-not (Test-Path ".git")) {
        git init
        Write-QuickLog "Initialized Git repository" "SUCCESS"
    }
    
    # Configure git with minimal error output
    git config user.name $GitHubConfig.Username
    git config user.email $GitHubConfig.Email
    Write-QuickLog "Git configuration completed" "SUCCESS"
    
    # Configure remote
    $remoteUrlWithToken = $GitHubConfig.RemoteURL -replace "https://", "https://$($GitHubConfig.Token)@"
    
    $existingRemote = git remote get-url origin 2>$null
    if ($LASTEXITCODE -eq 0) {
        git remote set-url origin $remoteUrlWithToken
        Write-QuickLog "Updated remote URL" "SUCCESS"
    } else {
        git remote add origin $remoteUrlWithToken
        Write-QuickLog "Added remote URL" "SUCCESS"
    }
    
    $testDates = @("2022-11-15", "2023-03-10", "2023-08-20", "2024-01-05", (Get-Date).AddDays(-30).ToString("yyyy-MM-dd"))
    
    Write-QuickLog "Target dates for test commits:" "INFO"
    foreach ($date in $testDates) {
        Write-QuickLog "  - $date" "INFO"
    }
    Write-Host ""
    
    $successCount = 0
    $totalDates = $testDates.Count
    
    Write-QuickLog "Creating backdated commits..." "PROGRESS"
    
    for ($i = 0; $i -lt $testDates.Count; $i++) {
        $testDate = $testDates[$i]
        $progress = $i + 1
        
        Write-QuickLog "[$progress/$totalDates] Creating commit for $testDate..." "PROGRESS"
        
        $success = New-QuickBackdatedCommit -CommitDate $testDate -CommitNumber 1
        
        if ($success) {
            $successCount++
            Write-QuickLog "[$progress/$totalDates] Success" "SUCCESS"
        } else {
            Write-QuickLog "[$progress/$totalDates] Failed" "ERROR"
        }
        
        Start-Sleep -Seconds 1
    }
    
    Write-Host ""
    Write-QuickLog "Commit creation completed: $successCount/$totalDates successful" "INFO"
    
    if ($successCount -gt 0) {
        Write-QuickLog "Pushing $successCount test commits to GitHub..." "PROGRESS"
        
        # First try to pull any remote changes
        Write-QuickLog "Checking for remote changes..." "INFO"
        $pullResult = git pull origin main --no-edit 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-QuickLog "Pull failed or no remote branch, continuing with push..." "WARNING"
        }
        
        # Now try to push
        $pushResult = git push origin main 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-QuickLog "Normal push failed, trying force push..." "WARNING"
            $pushResult = git push origin main --force 2>&1
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-QuickLog "=== QUICK TEST RESULTS ===" "SUCCESS"
            Write-QuickLog "$successCount backdated commits created successfully" "SUCCESS"
            Write-QuickLog "All commits pushed to GitHub repository" "SUCCESS"
            Write-QuickLog "Repository: $($GitHubConfig.RemoteURL)" "SUCCESS"
            Write-Host ""
            
            Write-QuickLog "VERIFICATION STEPS:" "INFO"
            Write-QuickLog "1. Visit your GitHub profile: https://github.com/$($GitHubConfig.Username)" "INFO"
            Write-QuickLog "2. Check the contribution graph for these dates:" "INFO"
            for ($j = 0; $j -lt $successCount; $j++) {
                Write-QuickLog "   - $($testDates[$j]) (should show 1 contribution)" "INFO"
            }
            Write-Host ""
            
            Write-QuickLog "If you see contributions on the correct historical dates, the backdating system is working!" "SUCCESS"
            Write-QuickLog "You can now proceed with the full historical system if desired." "SUCCESS"
            
        } else {
            Write-QuickLog "Failed to push test commits to GitHub" "ERROR"
            Write-QuickLog "Push output: $pushResult" "ERROR"
            Write-QuickLog "Error code: $LASTEXITCODE" "ERROR"
        }
    } else {
        Write-QuickLog "No commits were created successfully" "ERROR"
        Write-QuickLog "Please check the error messages above" "ERROR"
    }
    
} catch {
    Write-QuickLog "Quick test execution failed: $($_.Exception.Message)" "ERROR"
} finally {
    $env:GIT_COMMITTER_DATE = ""
    $env:GIT_AUTHOR_DATE = ""
    Write-Host ""
    Write-Host "Script completed!" -ForegroundColor Green
}
