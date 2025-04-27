# Green Optimizer Script (Dark Green Focus)
# This script optimizes the commit schedule to create a greener GitHub contribution graph
# with more dark green contributions twice per week
# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# Path to schedule file
$scheduleFile = "$repoPath\commit_schedule.txt"
$intensityFile = "$repoPath\commit_intensity.txt"
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

# Helper function to describe green levels
function Get-GreenLevelDescription {
    param(
        [int]$Level
    )
    
    switch ($Level) {
        2 { "Medium-light green" }
        3 { "Medium green" }
        4 { "Medium-dark green" }
        5 { "Dark green" }
        default { "Unknown" }
    }
}

# Backup the old schedule
if (Test-Path $scheduleFile) {
    Copy-Item $scheduleFile "$scheduleFile.bak"
    Write-Log "Backed up existing schedule to $scheduleFile.bak"
}

# Generate new optimized schedule
$today = Get-Date
$daysToPick = 320  # Increased from 280 to 320 for more green days
$totalDays = 365

Write-Log "Generating optimized commit schedule for maximum greenness with more dark green"

# Generate dates starting from today
$dates = 0..$totalDays | ForEach-Object { $today.AddDays($_).ToString("yyyy-MM-dd") }

# Create a weighted selection to favor weekdays (more realistic)
$weightedDates = @()
foreach ($date in $dates) {
    $dayOfWeek = [DateTime]::Parse($date).DayOfWeek
    
    # Assign weights: higher for weekdays, lower for weekends
    $weight = switch ($dayOfWeek) {
        "Monday" { 12 }    # Increased weight for Monday
        "Tuesday" { 12 }   # Increased weight for Tuesday
        "Wednesday" { 14 } # Highest weight for Wednesday
        "Thursday" { 12 }  # Increased weight for Thursday
        "Friday" { 10 }
        "Saturday" { 5 }
        "Sunday" { 3 }
        default { 1 }
    }
    
    # Add the date multiple times based on its weight
    for ($i = 0; $i -lt $weight; $i++) {
        $weightedDates += $date
    }
}

# Select dates with bias toward weekdays
$selectedDates = $weightedDates | Get-Random -Count $daysToPick | Select-Object -Unique

# Make sure today is included in the schedule for testing
if (-not ($selectedDates -contains $today.ToString("yyyy-MM-dd"))) {
    Write-Log "Adding today to the schedule for testing"
    $selectedDates = @($today.ToString("yyyy-MM-dd")) + $selectedDates
}

# Remove duplicates and ensure we have the right number of days
$selectedDates = $selectedDates | Select-Object -Unique | Select-Object -First $daysToPick

# Sort and save
$selectedDates | Sort-Object | Set-Content -Path $scheduleFile -Encoding utf8

Write-Log "Created optimized commit schedule with $($selectedDates.Count) days"
Write-Log "First scheduled date: $($selectedDates | Sort-Object | Select-Object -First 1)"
Write-Log "Schedule includes today: $($selectedDates -contains $today.ToString('yyyy-MM-dd'))"

# Generate commit intensity for each day (2-5 commits per day)
# This will create darker green squares on the GitHub contribution graph
$intensityMap = @{}

foreach ($date in $selectedDates) {
    # Determine day of week
    $dayOfWeek = [DateTime]::Parse($date).DayOfWeek
    
    # Assign base intensity based on day of week (more commits on weekdays)
    # Increased base intensity for all days
    $baseIntensity = switch ($dayOfWeek) {
        "Monday" { 3 }
        "Tuesday" { 4 }    # Increased to 4 (medium-dark)
        "Wednesday" { 4 }  # Increased to 4 (medium-dark)
        "Thursday" { 3 }
        "Friday" { 3 }
        "Saturday" { 2 }
        "Sunday" { 2 }
        default { 2 }
    }
    
    # Add some randomness (±1) but ensure minimum of 2 and maximum of 5
    $randomFactor = Get-Random -Minimum -1 -Maximum 2
    $intensity = [Math]::Max(2, [Math]::Min(5, $baseIntensity + $randomFactor))
    
    # Store in map
    $intensityMap[$date] = $intensity
}

# Create a pattern of high-intensity days (level 5 dark green) twice per week
# This creates darker green patches that stand out
$startDate = $today
$weekCount = [Math]::Ceiling($totalDays / 7)

for ($week = 0; $week -lt $weekCount; $week++) {
    # Get the Monday of this week
    $weekStart = $startDate.AddDays($week * 7)
    while ($weekStart.DayOfWeek -ne "Monday") {
        $weekStart = $weekStart.AddDays(-1)
    }
    
    # Choose two days in this week for dark green (level 5)
    # Prefer Tuesday and Thursday for dark green
    $tuesdayDate = $weekStart.AddDays(1).ToString("yyyy-MM-dd")  # Tuesday
    $thursdayDate = $weekStart.AddDays(3).ToString("yyyy-MM-dd") # Thursday
    
    # Set Tuesday to level 5 if it's in the selected dates
    if ($selectedDates -contains $tuesdayDate) {
        $intensityMap[$tuesdayDate] = 5  # Dark green
        Write-Log "Set $tuesdayDate (Tuesday) to dark green (level 5)"
    }
    
    # Set Thursday to level 5 if it's in the selected dates
    if ($selectedDates -contains $thursdayDate) {
        $intensityMap[$thursdayDate] = 5  # Dark green
        Write-Log "Set $thursdayDate (Thursday) to dark green (level 5)"
    }
}

# Ensure all level 4 are preserved (no downgrading)
foreach ($date in $selectedDates) {
    if ($intensityMap[$date] -eq 4) {
        # Keep all level 4 as is
        continue
    }
}

# Save intensity map to file
$intensityContent = @()
foreach ($date in $selectedDates | Sort-Object) {
    $intensityContent += "$date,$($intensityMap[$date])"
}
$intensityContent | Out-File -FilePath $intensityFile -Encoding utf8

# Calculate statistics
$level5Count = ($intensityMap.Values | Where-Object { $_ -eq 5 }).Count
$level4Count = ($intensityMap.Values | Where-Object { $_ -eq 4 }).Count
$totalDarkGreen = $level5Count + $level4Count
$darkGreenPercentage = [Math]::Round(($totalDarkGreen / $selectedDates.Count) * 100, 1)

Write-Log "Created commit intensity map with varying commit counts per day (levels 2-5)"
Write-Log "Dark green days (levels 4-5): $totalDarkGreen ($darkGreenPercentage%)"
Write-Log "Level 5 (darkest green) days: $level5Count"
Write-Log "Level 4 (medium-dark green) days: $level4Count"
Write-Log "Average commits per day: $([Math]::Round(($intensityMap.Values | Measure-Object -Average).Average, 2))"
Write-Log "Maximum commits per day: $($intensityMap.Values | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum)"

# Remove the last_run.txt file to allow the script to run today
if (Test-Path "$repoPath\last_run.txt") {
    Remove-Item "$repoPath\last_run.txt" -Force
    Write-Log "Removed last_run.txt to allow script to run today"
}

Write-Log "Green optimization complete. The GitHub contribution graph will now appear more green with more dark green squares."
Write-Log "Run green_workflow_4levels.ps1 to start making commits with the optimized schedule."

# Display summary
Write-Host "`nGreen Optimization Summary:" -ForegroundColor Green
Write-Host "----------------------------" -ForegroundColor Green
Write-Host "Total commit days: $($selectedDates.Count) out of 365" -ForegroundColor Cyan
Write-Host "Dark green days (levels 4-5): $totalDarkGreen ($darkGreenPercentage%)" -ForegroundColor Green
Write-Host "Weekday distribution:" -ForegroundColor Cyan

$dayDistribution = @{
    "Monday" = 0
    "Tuesday" = 0
    "Wednesday" = 0
    "Thursday" = 0
    "Friday" = 0
    "Saturday" = 0
    "Sunday" = 0
}

foreach ($date in $selectedDates) {
    $dayOfWeek = [DateTime]::Parse($date).DayOfWeek
    $dayDistribution[$dayOfWeek.ToString()] += 1
}

foreach ($day in $dayDistribution.Keys | Sort-Object {
    switch ($_) {
        "Monday" { 1 }
        "Tuesday" { 2 }
        "Wednesday" { 3 }
        "Thursday" { 4 }
        "Friday" { 5 }
        "Saturday" { 6 }
        "Sunday" { 7 }
    }
}) {
    $percentage = [Math]::Round(($dayDistribution[$day] / $selectedDates.Count) * 100, 1)
    Write-Host "  $day`: $($dayDistribution[$day]) days ($percentage%)" -ForegroundColor White
}

Write-Host "`nCommit intensity distribution:" -ForegroundColor Cyan
$intensityDistribution = @{
    2 = 0
    3 = 0
    4 = 0
    5 = 0
}

foreach ($intensity in $intensityMap.Values) {
    $intensityDistribution[$intensity] += 1
}

foreach ($level in 2..5) {
    $count = $intensityDistribution[$level]
    $percentage = [Math]::Round(($count / $selectedDates.Count) * 100, 1)
    $color = switch ($level) {
        2 { "White" }
        3 { "Cyan" }
        4 { "Yellow" }
        5 { "Green" }
    }
    Write-Host "  Level $level ($(Get-GreenLevelDescription $level)): $count days ($percentage%)" -ForegroundColor $color
}
