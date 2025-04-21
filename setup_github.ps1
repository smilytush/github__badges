# This script sets up the GitHub repository and connects it to your local repository

# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# GitHub username and repository name
$githubUsername = "smilytush"
$repoName = "green-commits"

# Check if remote already exists
$remoteExists = git remote | Where-Object { $_ -eq "origin" }
if ($remoteExists) {
    Write-Host "Remote 'origin' already exists. Skipping setup."
    exit 0
}

# Create GitHub repository using GitHub CLI if available
$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue
if ($ghInstalled) {
    Write-Host "GitHub CLI found. Creating repository..."
    gh repo create $repoName --private --confirm
} else {
    Write-Host "GitHub CLI not found. Please create the repository manually at:"
    Write-Host "https://github.com/new"
    Write-Host ""
    Write-Host "Repository name: $repoName"
    Write-Host "Private: Yes"
    Write-Host ""
    Write-Host "After creating the repository, press Enter to continue..."
    Read-Host
}

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
git push -u origin $currentBranch

Write-Host "Setup complete!"
Write-Host "Your repository is now connected to GitHub and all files have been pushed."
Write-Host "Repository URL: https://github.com/$githubUsername/$repoName"
