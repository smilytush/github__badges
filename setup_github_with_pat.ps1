# This script helps set up the GitHub repository using a Personal Access Token

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

# Prompt for Personal Access Token
Write-Host "You need to create a Personal Access Token (PAT) on GitHub:"
Write-Host "1. Go to https://github.com/settings/tokens"
Write-Host "2. Click 'Generate new token'"
Write-Host "3. Give it a name like 'Green Commits'"
Write-Host "4. Select the 'repo' scope"
Write-Host "5. Click 'Generate token'"
Write-Host "6. Copy the token and paste it below"
Write-Host ""
$pat = Read-Host "Enter your GitHub Personal Access Token" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pat)
$patPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Add remote with PAT
Write-Host "Adding remote with PAT..."
git remote add origin "https://$githubUsername:$patPlain@github.com/$githubUsername/$repoName.git"

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

# Clear the PAT from memory
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
