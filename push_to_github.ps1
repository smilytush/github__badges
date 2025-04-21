# This script helps you push your repository to GitHub

# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# GitHub username
$githubUsername = "smilytush"
$repoName = "green-commits"

# Prompt for Personal Access Token
Write-Host "You need to enter your GitHub Personal Access Token (PAT)."
Write-Host "If you don't have one, create it at: https://github.com/settings/tokens"
Write-Host "Make sure to select the 'repo' scope."
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

if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! Your repository is now on GitHub."
    Write-Host "Repository URL: https://github.com/$githubUsername/$repoName"
} else {
    Write-Host "There was an issue pushing to GitHub. Please check the error message above."
}

# Clear the PAT from memory
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
