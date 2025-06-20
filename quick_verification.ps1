# Quick Verification Script
# Checks that all components are working correctly

Write-Host "=== QUICK VERIFICATION OF ENHANCED HISTORICAL SYSTEM V2.0 ===" -ForegroundColor Magenta
Write-Host ""

$repoPath = "J:\green-commits"
$allGood = $true

# Check 1: Directory exists
Write-Host "1. Checking repository directory..." -ForegroundColor Cyan
if (Test-Path $repoPath) {
    Write-Host "   ✓ Repository directory exists: $repoPath" -ForegroundColor Green
} else {
    Write-Host "   ✗ Repository directory missing: $repoPath" -ForegroundColor Red
    $allGood = $false
}

# Check 2: Required scripts exist
Write-Host "2. Checking required script files..." -ForegroundColor Cyan
$requiredScripts = @(
    "enhanced_historical_system_v2.ps1",
    "comprehensive_test_system.ps1",
    "run_foolproof_system.ps1",
    "run_foolproof_system.bat",
    "run_enhanced_historical_system.bat"
)

foreach ($script in $requiredScripts) {
    $scriptPath = Join-Path $repoPath $script
    if (Test-Path $scriptPath) {
        Write-Host "   ✓ $script" -ForegroundColor Green
    } else {
        Write-Host "   ✗ $script (MISSING)" -ForegroundColor Red
        $allGood = $false
    }
}

# Check 3: PowerShell execution policy
Write-Host "3. Checking PowerShell execution policy..." -ForegroundColor Cyan
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Unrestricted" -or $executionPolicy -eq "Bypass" -or $executionPolicy -eq "RemoteSigned") {
    Write-Host "   ✓ Execution policy allows script execution: $executionPolicy" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Execution policy may block scripts: $executionPolicy" -ForegroundColor Yellow
    Write-Host "     Scripts will use -ExecutionPolicy Bypass to override" -ForegroundColor Yellow
}

# Check 4: Git availability
Write-Host "4. Checking Git availability..." -ForegroundColor Cyan
try {
    $gitVersion = git --version 2>$null
    if ($gitVersion) {
        Write-Host "   ✓ Git is available: $gitVersion" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Git not found in PATH" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "   ✗ Git not available: $($_.Exception.Message)" -ForegroundColor Red
    $allGood = $false
}

# Check 5: Internet connectivity
Write-Host "5. Checking internet connectivity..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "https://api.github.com" -Method Head -TimeoutSec 10 -ErrorAction Stop
    Write-Host "   ✓ GitHub API is accessible" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Cannot reach GitHub API: $($_.Exception.Message)" -ForegroundColor Red
    $allGood = $false
}

# Summary
Write-Host ""
Write-Host "=== VERIFICATION SUMMARY ===" -ForegroundColor Magenta

if ($allGood) {
    Write-Host "✓ ALL CHECKS PASSED - System is ready for execution!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Recommended next steps:" -ForegroundColor Yellow
    Write-Host "1. Run: run_foolproof_system.bat" -ForegroundColor White
    Write-Host "2. Choose option 1 (Test Mode) first" -ForegroundColor White
    Write-Host "3. Then option 3 (Full System) when ready" -ForegroundColor White
} else {
    Write-Host "✗ SOME CHECKS FAILED - Please fix the issues above" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common solutions:" -ForegroundColor Yellow
    Write-Host "- Install Git if missing" -ForegroundColor White
    Write-Host "- Check internet connection" -ForegroundColor White
    Write-Host "- Ensure all script files are present" -ForegroundColor White
}

Write-Host ""
Write-Host "GitHub Configuration:" -ForegroundColor Cyan
Write-Host "- Username: smilytush" -ForegroundColor White
Write-Host "- Repository: github-commits" -ForegroundColor White
Write-Host "- Period: November 1st, 2022 to Present" -ForegroundColor White
Write-Host "- Coverage: 82% of all days" -ForegroundColor White

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
