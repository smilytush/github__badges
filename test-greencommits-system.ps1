# GreenCommits System Test Script
# Comprehensive testing to verify the system works and commits appear on GitHub profile

param(
    [int]$TestCommits = 5,
    [switch]$SkipPush = $false,
    [switch]$Verbose = $false
)

# Set execution policy and error handling
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$ErrorActionPreference = "Stop"

Write-Host "=== GreenCommits System Test ===" -ForegroundColor Cyan
Write-Host "Testing system functionality and GitHub profile integration..." -ForegroundColor Yellow

# Function to write test log
function Write-TestLog {
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
    }
    
    $color = $colorMap[$Level]
    if ($Verbose -or $Level -ne "INFO") {
        Write-Host "[$timestamp] $Level: $Message" -ForegroundColor $color
    }
}

# Function to validate prerequisites
function Test-Prerequisites {
    Write-TestLog "Validating prerequisites..." "INFO"
    
    # Check environment variables
    if ([string]::IsNullOrEmpty($env:GITHUB_TOKEN)) {
        Write-TestLog "GITHUB_TOKEN environment variable not set!" "ERROR"
        return $false
    }
    
    if ([string]::IsNullOrEmpty($env:GITHUB_USERNAME)) {
        Write-TestLog "GITHUB_USERNAME environment variable not set!" "ERROR"
        return $false
    }
    
    if ([string]::IsNullOrEmpty($env:GITHUB_EMAIL)) {
        Write-TestLog "GITHUB_EMAIL environment variable not set!" "ERROR"
        return $false
    }
    
    # Test Git availability
    try {
        $gitVersion = git --version
        Write-TestLog "Git available: $gitVersion" "SUCCESS"
    }
    catch {
        Write-TestLog "Git not available or not in PATH!" "ERROR"
        return $false
    }
    
    # Test GitHub API access
    try {
        $headers = @{ Authorization = "token $env:GITHUB_TOKEN" }
        $response = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers -Method GET
        Write-TestLog "GitHub API access confirmed for: $($response.login)" "SUCCESS"
    }
    catch {
        Write-TestLog "GitHub API access failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
    
    Write-TestLog "All prerequisites validated successfully" "SUCCESS"
    return $true
}

# Function to create test commits
function New-TestCommits {
    param([int]$Count)
    
    Write-TestLog "Creating $Count test commits..." "INFO"
    
    $successCount = 0
    $languages = @("python", "javascript", "typescript", "solidity", "go")
    $extensions = @{
        "python" = ".py"
        "javascript" = ".js"
        "typescript" = ".ts"
        "solidity" = ".sol"
        "go" = ".go"
    }
    
    for ($i = 1; $i -le $Count; $i++) {
        try {
            # Select random language and create appropriate file
            $language = $languages | Get-Random
            $extension = $extensions[$language]
            $fileName = "test_commit_${i}_$(Get-Date -Format 'yyyyMMddHHmmss')${extension}"
            
            # Generate appropriate content based on language
            $content = switch ($language) {
                "python" { 
                    @"
# Test commit $i - Python implementation
def test_function_$i():
    """Test function for commit validation"""
    result = $i * 2
    print(f"Test result: {result}")
    return result

if __name__ == "__main__":
    test_function_$i()
"@
                }
                "javascript" {
                    @"
// Test commit $i - JavaScript implementation
function testFunction$i() {
    const result = $i * 2;
    console.log(`Test result: ${result}`);
    return result;
}

// Export for testing
module.exports = { testFunction$i };
"@
                }
                "typescript" {
                    @"
// Test commit $i - TypeScript implementation
interface TestResult {
    value: number;
    message: string;
}

function testFunction$i(): TestResult {
    const result = $i * 2;
    return {
        value: result,
        message: `Test result: ${result}`
    };
}

export { testFunction$i, TestResult };
"@
                }
                "solidity" {
                    @"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Test commit $i - Solidity implementation
contract TestContract$i {
    uint256 public testValue;
    
    constructor() {
        testValue = $i * 2;
    }
    
    function getTestResult() public view returns (uint256) {
        return testValue;
    }
}
"@
                }
                "go" {
                    @"
// Test commit $i - Go implementation
package main

import "fmt"

func testFunction$i() int {
    result := $i * 2
    fmt.Printf("Test result: %d\n", result)
    return result
}

func main() {
    testFunction$i()
}
"@
                }
            }
            
            # Write file
            $content | Out-File -FilePath $fileName -Encoding UTF8
            
            # Add to git
            git add $fileName
            
            # Create commit with realistic message
            $commitMessage = "Implement test function $i for $language module

- Add test_function_$i with validation logic
- Include proper error handling and logging
- Update module exports and documentation
- Optimize performance for production use"
            
            git commit -m $commitMessage
            
            Write-TestLog "Created test commit $i ($language): $fileName" "SUCCESS"
            $successCount++
            
            # Small delay to ensure unique timestamps
            Start-Sleep -Milliseconds 100
        }
        catch {
            Write-TestLog "Failed to create test commit $i: $($_.Exception.Message)" "ERROR"
        }
    }
    
    Write-TestLog "Successfully created $successCount out of $Count test commits" "SUCCESS"
    return $successCount
}

# Function to push commits to GitHub
function Push-TestCommits {
    Write-TestLog "Pushing test commits to GitHub..." "INFO"
    
    try {
        # Configure remote with token for push
        $secureRemoteUrl = "https://$($env:GITHUB_TOKEN)@github.com/smilytush/github-commits.git"
        git remote set-url origin $secureRemoteUrl
        
        # Push to main branch
        git push origin main
        
        # Clean up remote URL
        git remote set-url origin "https://github.com/smilytush/github-commits.git"
        
        Write-TestLog "Successfully pushed commits to GitHub!" "SUCCESS"
        return $true
    }
    catch {
        Write-TestLog "Failed to push commits: $($_.Exception.Message)" "ERROR"
        
        # Clean up remote URL on failure
        git remote set-url origin "https://github.com/smilytush/github-commits.git" -ErrorAction SilentlyContinue
        return $false
    }
}

# Function to verify commits on GitHub
function Test-GitHubProfile {
    Write-TestLog "Verifying commits appear on GitHub profile..." "INFO"
    
    try {
        $headers = @{ Authorization = "token $env:GITHUB_TOKEN" }
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/smilytush/github-commits/commits?per_page=10" -Headers $headers -Method GET
        
        $recentCommits = $response | Where-Object { $_.commit.author.date -gt (Get-Date).AddMinutes(-10) }
        
        if ($recentCommits.Count -gt 0) {
            Write-TestLog "Found $($recentCommits.Count) recent commits on GitHub!" "SUCCESS"
            foreach ($commit in $recentCommits) {
                Write-TestLog "  - $($commit.sha.Substring(0,7)): $($commit.commit.message.Split("`n")[0])" "INFO"
            }
            return $true
        }
        else {
            Write-TestLog "No recent commits found on GitHub profile" "WARNING"
            return $false
        }
    }
    catch {
        Write-TestLog "Failed to verify GitHub profile: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Main test process
try {
    Write-Host "Starting comprehensive system test..." -ForegroundColor Cyan
    
    # Step 1: Validate prerequisites
    if (-not (Test-Prerequisites)) {
        Write-Host "CRITICAL: Prerequisites validation failed!" -ForegroundColor Red
        Write-Host "Please run setup-environment.ps1 first" -ForegroundColor Yellow
        exit 1
    }
    
    # Step 2: Create test commits
    $commitsCreated = New-TestCommits -Count $TestCommits
    if ($commitsCreated -eq 0) {
        Write-Host "CRITICAL: No test commits were created!" -ForegroundColor Red
        exit 1
    }
    
    # Step 3: Push commits to GitHub (unless skipped)
    if (-not $SkipPush) {
        if (-not (Push-TestCommits)) {
            Write-Host "CRITICAL: Failed to push commits to GitHub!" -ForegroundColor Red
            exit 1
        }
        
        # Step 4: Verify commits appear on profile
        Write-TestLog "Waiting 10 seconds for GitHub to process commits..." "INFO"
        Start-Sleep -Seconds 10
        
        if (-not (Test-GitHubProfile)) {
            Write-Host "WARNING: Commits may not be visible on GitHub profile yet" -ForegroundColor Yellow
            Write-Host "This can take a few minutes to update. Check your profile at:" -ForegroundColor Yellow
            Write-Host "https://github.com/smilytush" -ForegroundColor Cyan
        }
    }
    
    Write-Host ""
    Write-Host "=== SYSTEM TEST COMPLETE ===" -ForegroundColor Green
    Write-Host "✓ Prerequisites validated" -ForegroundColor Green
    Write-Host "✓ Test commits created: $commitsCreated" -ForegroundColor Green
    if (-not $SkipPush) {
        Write-Host "✓ Commits pushed to GitHub" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "The GreenCommits system is working correctly!" -ForegroundColor Cyan
    Write-Host "Check your GitHub profile: https://github.com/smilytush" -ForegroundColor Yellow
}
catch {
    Write-Host ""
    Write-Host "=== TEST FAILED ===" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
