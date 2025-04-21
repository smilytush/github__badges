# This script creates a GitHub repository and pushes your local repository to it

# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# GitHub username and repository name
$githubUsername = "smilytush"
$repoName = "green-commits"

# Remove existing remote if it exists
$remoteExists = git remote | Where-Object { $_ -eq "origin" }
if ($remoteExists) {
    Write-Host "Removing existing remote 'origin'..."
    git remote remove origin
}

# Instructions for creating the repository manually
Write-Host "Please create a new repository on GitHub:"
Write-Host "1. Go to https://github.com/new"
Write-Host "2. Repository name: $repoName"
Write-Host "3. Set to Private"
Write-Host "4. Do NOT initialize with README, .gitignore, or license"
Write-Host "5. Click 'Create repository'"
Write-Host ""
Write-Host "After creating the repository, press Enter to continue..."
Read-Host

# Add remote
Write-Host "Adding remote..."
git remote add origin "https://github.com/$githubUsername/$repoName.git"

# Get current branch name
$currentBranch = (git rev-parse --abbrev-ref HEAD) 2>&1
if ($LASTEXITCODE -ne 0) {
    $currentBranch = "master" # Default to master if command fails
}

# Push to GitHub
Write-Host "Pushing to GitHub..."
Write-Host "You may be prompted for your GitHub username and password."
Write-Host "Note: For the password, you need to use a Personal Access Token, not your GitHub password."
Write-Host "If you don't have a Personal Access Token, create one at: https://github.com/settings/tokens"
Write-Host ""
git push -u origin $currentBranch

Write-Host ""
if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! Your repository is now on GitHub."
    Write-Host "Repository URL: https://github.com/$githubUsername/$repoName"
} else {
    Write-Host "There was an issue pushing to GitHub. Please check the error message above."
}
