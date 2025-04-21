# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# Path to schedule file
$scheduleFile = "$repoPath\commit_schedule.txt"

# Generate 280 random commit days if not already created
if (-not (Test-Path $scheduleFile)) {
    $today = Get-Date
    $daysToPick = 280
    $totalDays = 365

    $dates = 1..$totalDays | ForEach-Object { $today.AddDays($_).ToString("yyyy-MM-dd") }
    $selectedDates = $dates | Get-Random -Count $daysToPick
    $selectedDates | Sort-Object | Set-Content $scheduleFile
    Write-Host "Created commit schedule with $daysToPick days"
}

# Get today's date
$todayStr = (Get-Date).ToString("yyyy-MM-dd")

# Check if today is in the selected commit dates
$commitDays = Get-Content $scheduleFile
if ($commitDays -contains $todayStr) {
    Write-Host "Today ($todayStr) is a commit day. Making a commit..."
    
    # Create or update the activity log
    "Update: $(Get-Date)" | Out-File -Append -Encoding utf8 "$repoPath\activity.log"

    # Configure git user (already done globally, but included for completeness)
    git config user.name "smilytush"
    git config user.email "tushar161@hotmail.com"

    # Commit and push
    git add .
    git commit -m "Auto commit on $todayStr"
    git push origin main
    
    Write-Host "Commit successfully made and pushed!"
} else {
    Write-Host "Today ($todayStr) is not scheduled for a commit."
}
