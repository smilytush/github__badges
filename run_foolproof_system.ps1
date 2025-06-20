# Foolproof Execution Script for Enhanced Historical Backdated GitHub Commit System
# Single command execution with comprehensive validation and error handling

param(
    [switch]$TestOnly = $false,
    [switch]$ValidateOnly = $false,
    [switch]$Force = $false
)

# Set execution policy for current session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Repository path
$repoPath = "J:\green-commits"

# Enhanced logging function
function Write-FoolproofLog {
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
        "HEADER" = "Blue"
    }
    
    $color = $colorMap[$Level]
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# Function to ensure directory and navigate
function Set-WorkingDirectory {
    try {
        if (-not (Test-Path $repoPath)) {
            New-Item -ItemType Directory -Path $repoPath -Force | Out-Null
            Write-FoolproofLog "Created repository directory: $repoPath" "SUCCESS"
        }
        
        Set-Location $repoPath
        Write-FoolproofLog "Working directory set to: $repoPath" "INFO"
        return $true
    }
    catch {
        Write-FoolproofLog "Failed to set working directory: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Function to check if scripts exist
function Test-ScriptFiles {
    $requiredScripts = @(
        "enhanced_historical_system_v2.ps1",
        "comprehensive_test_system.ps1"
    )
    
    $missingScripts = @()
    
    foreach ($script in $requiredScripts) {
        $scriptPath = Join-Path $repoPath $script
        if (-not (Test-Path $scriptPath)) {
            $missingScripts += $script
        }
    }
    
    if ($missingScripts.Count -gt 0) {
        Write-FoolproofLog "Missing required scripts: $($missingScripts -join ', ')" "ERROR"
        return $false
    }
    
    Write-FoolproofLog "All required scripts found" "SUCCESS"
    return $true
}

# Main execution function
function Start-FoolproofExecution {
    Write-FoolproofLog "=== FOOLPROOF ENHANCED HISTORICAL BACKDATE SYSTEM ===" "HEADER"
    Write-FoolproofLog "Single command execution with comprehensive validation" "INFO"
    Write-FoolproofLog "Target: November 1st, 2022 to Present (82% coverage)" "INFO"
    Write-Host ""
    
    # Step 1: Set working directory
    Write-FoolproofLog "Step 1: Setting up working directory..." "PROGRESS"
    if (-not (Set-WorkingDirectory)) {
        throw "Failed to set up working directory"
    }
    
    # Step 2: Check script files
    Write-FoolproofLog "Step 2: Checking required script files..." "PROGRESS"
    if (-not (Test-ScriptFiles)) {
        throw "Required script files are missing"
    }
    
    # Step 3: Run comprehensive tests
    Write-FoolproofLog "Step 3: Running comprehensive validation tests..." "PROGRESS"
    try {
        & "$repoPath\comprehensive_test_system.ps1" -QuickTest
        Write-FoolproofLog "Comprehensive tests completed" "SUCCESS"
    }
    catch {
        Write-FoolproofLog "Comprehensive tests failed: $($_.Exception.Message)" "ERROR"
        if (-not $Force) {
            throw "Validation tests failed. Use -Force to override."
        }
        Write-FoolproofLog "Continuing with -Force override..." "WARNING"
    }
    
    # Step 4: Execute based on parameters
    if ($ValidateOnly) {
        Write-FoolproofLog "Step 4: Validation-only mode - Running system validation..." "PROGRESS"
        & "$repoPath\enhanced_historical_system_v2.ps1" -ValidateOnly
        Write-FoolproofLog "Validation completed successfully" "SUCCESS"
        return
    }
    
    if ($TestOnly) {
        Write-FoolproofLog "Step 4: Test-only mode - Creating 5 sample backdated commits..." "PROGRESS"
        Write-FoolproofLog "Using quick test mode to bypass comprehensive tests..." "INFO"
        & "$repoPath\quick_test_mode.ps1"
        Write-FoolproofLog "Test mode completed successfully" "SUCCESS"
        return
    }
    
    # Step 4: Full system execution
    Write-FoolproofLog "Step 4: Executing full historical backdate system..." "PROGRESS"
    Write-FoolproofLog "This will create thousands of backdated commits from November 1st, 2022 to present" "WARNING"
    
    if (-not $Force) {
        Write-Host ""
        Write-Host "⚠️  FINAL CONFIRMATION REQUIRED ⚠️" -ForegroundColor Red
        Write-Host "This will create a large number of backdated commits on your GitHub profile." -ForegroundColor Yellow
        Write-Host "Are you absolutely sure you want to proceed?" -ForegroundColor Yellow
        Write-Host ""
        
        do {
            $response = Read-Host "Type 'YES' to proceed, 'TEST' for test mode, or 'NO' to cancel"
            $response = $response.ToUpper().Trim()
            
            switch ($response) {
                "YES" {
                    Write-FoolproofLog "User confirmed full execution" "SUCCESS"
                    break
                }
                "TEST" {
                    Write-FoolproofLog "User selected test mode" "INFO"
                    & "$repoPath\enhanced_historical_system_v2.ps1" -TestMode
                    return
                }
                "NO" {
                    Write-FoolproofLog "User cancelled execution" "WARNING"
                    return
                }
                default {
                    Write-Host "Please type 'YES', 'TEST', or 'NO'" -ForegroundColor Red
                    continue
                }
            }
            break
        } while ($true)
    }
    
    # Execute the full system
    & "$repoPath\enhanced_historical_system_v2.ps1" -SkipConfirmation
    
    Write-FoolproofLog "Full system execution completed!" "SUCCESS"
    Write-FoolproofLog "Check your GitHub profile: https://github.com/smilytush" "INFO"
}

# Error handling and execution
try {
    Start-FoolproofExecution
    
    Write-Host ""
    Write-FoolproofLog "=== EXECUTION COMPLETED SUCCESSFULLY ===" "SUCCESS"
    Write-FoolproofLog "Your GitHub contribution graph should now show historical activity from November 1st, 2022 to present" "SUCCESS"
    Write-FoolproofLog "Visit https://github.com/smilytush to verify the results" "INFO"
}
catch {
    Write-Host ""
    Write-FoolproofLog "=== EXECUTION FAILED ===" "ERROR"
    Write-FoolproofLog "Error: $($_.Exception.Message)" "ERROR"
    Write-FoolproofLog "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    
    Write-Host ""
    Write-Host "Troubleshooting steps:" -ForegroundColor Yellow
    Write-Host "1. Check your internet connection" -ForegroundColor White
    Write-Host "2. Verify your GitHub token is valid" -ForegroundColor White
    Write-Host "3. Ensure you have Git installed and configured" -ForegroundColor White
    Write-Host "4. Try running with -TestOnly first" -ForegroundColor White
    Write-Host "5. Check the log files for detailed error information" -ForegroundColor White
}
finally {
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
