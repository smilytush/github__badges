# GreenCommits Environment Setup Script
# This script sets up the required environment variables securely
# Run this script before executing any GreenCommits operations

param(
    [string]$GitHubToken = "",
    [switch]$Interactive = $false,
    [switch]$Validate = $false
)

# Set execution policy and error handling
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$ErrorActionPreference = "Stop"

Write-Host "=== GreenCommits Environment Setup ===" -ForegroundColor Cyan
Write-Host "Setting up secure environment variables..." -ForegroundColor Yellow

# Function to validate GitHub token format
function Test-GitHubTokenFormat {
    param([string]$Token)
    
    if ([string]::IsNullOrEmpty($Token)) {
        return $false
    }
    
    # Check for GitHub Personal Access Token or Fine-grained token format
    return ($Token -match '^ghp_[A-Za-z0-9]{36}$|^github_pat_[A-Za-z0-9_]{82}$')
}

# Function to test GitHub API access
function Test-GitHubAPIAccess {
    param([string]$Token)
    
    try {
        $headers = @{ Authorization = "token $Token" }
        $response = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers -Method GET
        Write-Host "✓ GitHub API access confirmed for user: $($response.login)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ GitHub API access failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Get GitHub token
if ([string]::IsNullOrEmpty($GitHubToken)) {
    if ($Interactive) {
        Write-Host "Please enter your GitHub Personal Access Token:" -ForegroundColor Yellow
        Write-Host "  - Go to: https://github.com/settings/tokens" -ForegroundColor Gray
        Write-Host "  - Generate a new token with 'repo' scope" -ForegroundColor Gray
        Write-Host "  - Copy and paste the token here" -ForegroundColor Gray
        $GitHubToken = Read-Host -AsSecureString "GitHub Token" | ConvertFrom-SecureString -AsPlainText
    }
    else {
        # Check if already set in environment
        $GitHubToken = $env:GITHUB_TOKEN
        if ([string]::IsNullOrEmpty($GitHubToken)) {
            Write-Host "ERROR: GitHub token not provided!" -ForegroundColor Red
            Write-Host "Options:" -ForegroundColor Yellow
            Write-Host "  1. Run with -Interactive flag to enter token interactively" -ForegroundColor Gray
            Write-Host "  2. Set GITHUB_TOKEN environment variable" -ForegroundColor Gray
            Write-Host "  3. Pass token with -GitHubToken parameter" -ForegroundColor Gray
            exit 1
        }
    }
}

# Validate token format
if (-not (Test-GitHubTokenFormat -Token $GitHubToken)) {
    Write-Host "ERROR: Invalid GitHub token format!" -ForegroundColor Red
    Write-Host "Expected format: ghp_XXXXXX... or github_pat_XXXXXX..." -ForegroundColor Gray
    exit 1
}

Write-Host "✓ GitHub token format is valid" -ForegroundColor Green

# Test API access if requested
if ($Validate) {
    Write-Host "Testing GitHub API access..." -ForegroundColor Yellow
    if (-not (Test-GitHubAPIAccess -Token $GitHubToken)) {
        Write-Host "ERROR: GitHub API access test failed!" -ForegroundColor Red
        exit 1
    }
}

# Set environment variables for current session
$env:GITHUB_TOKEN = $GitHubToken
$env:GITHUB_USERNAME = "smilytush"
$env:GITHUB_EMAIL = "tushar161@hotmail.com"

Write-Host "✓ Environment variables set for current session" -ForegroundColor Green

# Configure git with secure credentials
Write-Host "Configuring Git with secure credentials..." -ForegroundColor Yellow
try {
    git config user.name "smilytush"
    git config user.email "tushar161@hotmail.com"
    Write-Host "✓ Git configuration updated" -ForegroundColor Green
}
catch {
    Write-Host "WARNING: Git configuration failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Environment Setup Complete ===" -ForegroundColor Green
Write-Host "You can now run GreenCommits scripts safely." -ForegroundColor Cyan
Write-Host ""
Write-Host "To make environment variables persistent across sessions:" -ForegroundColor Yellow
Write-Host "  [System.Environment]::SetEnvironmentVariable('GITHUB_TOKEN', 'your_token', 'User')" -ForegroundColor Gray
Write-Host ""
Write-Host "SECURITY NOTE: Never commit your GitHub token to version control!" -ForegroundColor Red
