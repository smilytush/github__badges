# This script updates the commit schedule to include dates starting from today
# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# Path to schedule file
$scheduleFile = "$repoPath\commit_schedule.txt"
$logFile = "$repoPath\script_log.txt"

# Function to log messages
function Write-Log {
    param(
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] $Message" | Out-File -Append -Encoding utf8 $logFile
    Write-Host $Message
}

# Backup the old schedule
if (Test-Path $scheduleFile) {
    Copy-Item $scheduleFile "$scheduleFile.bak"
    Write-Log "Backed up existing schedule to $scheduleFile.bak"
}

# Generate new schedule
$today = Get-Date
$daysToPick = 280
$totalDays = 365

Write-Log "Generating new commit schedule starting from today: $($today.ToString('yyyy-MM-dd'))"

# Generate dates starting from today
$dates = 0..$totalDays | ForEach-Object { $today.AddDays($_).ToString("yyyy-MM-dd") }
$selectedDates = $dates | Get-Random -Count $daysToPick

# Make sure today is included in the schedule for testing
if (-not ($selectedDates -contains $today.ToString("yyyy-MM-dd"))) {
    Write-Log "Adding today to the schedule for testing"
    $selectedDates = @($today.ToString("yyyy-MM-dd")) + $selectedDates
    $selectedDates = $selectedDates | Select-Object -First $daysToPick
}

# Sort and save
$selectedDates | Sort-Object | Set-Content -Path $scheduleFile -Encoding utf8

Write-Log "Created new commit schedule with $daysToPick days"
Write-Log "First scheduled date: $($selectedDates | Sort-Object | Select-Object -First 1)"
Write-Log "Schedule includes today: $($selectedDates -contains $today.ToString('yyyy-MM-dd'))"

# Remove the last_run.txt file to allow the script to run today
if (Test-Path "$repoPath\last_run.txt") {
    Remove-Item "$repoPath\last_run.txt" -Force
    Write-Log "Removed last_run.txt to allow script to run today"
}

Write-Log "Schedule update complete. Run green_commit.ps1 to test."
