# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# Get today's date
$todayStr = (Get-Date).ToString("yyyy-MM-dd")
Write-Host "Testing commit for today: $todayStr"

# Create or update the activity log
"Test commit: $(Get-Date)" | Out-File -Append -Encoding utf8 "$repoPath\activity.log"

# Configure git user
git config user.name "smilytush"
git config user.email "tushar161@hotmail.com"

# Commit and push
git add .
git commit -m "Test commit on $todayStr"

Write-Host "Test commit successfully made!"
Write-Host "Note: This commit was not pushed to remote. To push, run: git push origin main"
