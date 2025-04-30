# Backdate Commits Script for 2023-2024
# This script creates commits with dates in the 2023-2024 period to fill in the GitHub contribution graph

Write-Host "GitHub Contribution Graph Backdating Tool (2023-2024)" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""

# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# Path to log file
$logFile = "$repoPath\backdate_log_2023_2024.txt"

# Function to log messages
function Write-Log {
    param(
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] $Message" | Out-File -Append -Encoding utf8 $logFile
    Write-Host $Message
}

# Function to create a backdated commit
function Create-BackdatedCommit {
    param(
        [DateTime]$CommitDate,
        [int]$IntensityLevel = 3
    )
    
    $dateStr = $CommitDate.ToString("yyyy-MM-dd")
    $timeStr = Get-Random -Minimum 9 -Maximum 17
    $minuteStr = Get-Random -Minimum 0 -Maximum 59
    $fullDateStr = "$dateStr $timeStr`:$minuteStr`:00"
    
    # Create or update Python snippet
    $pythonFile = "$repoPath\snippets\backdated_2023_2024.py"
    
    @"
# Backdated Python example (2023-2024) - Created on $fullDateStr
class BackdatedProcessor2023:
    def __init__(self, data):
        self.data = data
        self.processed = False
    
    def process(self):
        # Process the data
        result = [x * 3 for x in self.data if x > 0]
        self.processed = True
        return result

def main():
    # Sample data for $dateStr
    data = [2, 6, -4, 11, 9, 0, -6]
    processor = BackdatedProcessor2023(data)
    result = processor.process()
    print(f"Processed data for 2023-2024: {result}")

if __name__ == "__main__":
    main()
"@ | Out-File -FilePath $pythonFile -Encoding utf8 -Force
    
    # Stage the file
    git add $pythonFile
    
    # Create the commit with a backdated timestamp
    $env:GIT_AUTHOR_DATE = $fullDateStr
    $env:GIT_COMMITTER_DATE = $fullDateStr
    
    git commit -m "Backdated commit for $dateStr (2023-2024, Intensity: $IntensityLevel)"
    
    # Clear the environment variables
    $env:GIT_AUTHOR_DATE = $null
    $env:GIT_COMMITTER_DATE = $null
    
    Write-Log "Created backdated commit for $dateStr (2023-2024, Intensity: $IntensityLevel)"
}

# Function to generate a natural-looking commit schedule for 2023-2024
function Generate-BackdatedSchedule {
    param(
        [int]$CommitDays = 280
    )
    
    # Define the date range for 2023-2024
    $startDate = [DateTime]::Parse("2023-05-01")  # May 1, 2023
    $endDate = [DateTime]::Parse("2024-04-30")    # April 30, 2024
    
    # Generate all dates in the range
    $allDates = @()
    $currentDate = $startDate
    while ($currentDate -le $endDate) {
        $allDates += $currentDate
        $currentDate = $currentDate.AddDays(1)
    }
    
    # Select random dates for commits
    $commitDays = [Math]::Min($CommitDays, $allDates.Count)
    $commitDates = $allDates | Get-Random -Count $commitDays
    
    # Sort the dates
    $commitDates = $commitDates | Sort-Object
    
    # Create a distribution of intensity levels (2-5)
    $intensityLevels = @()
    
    # 15% level 2 (light green)
    $level2Count = [math]::Floor($CommitDays * 0.15)
    $intensityLevels += @(2) * $level2Count
    
    # 20% level 3 (medium green)
    $level3Count = [math]::Floor($CommitDays * 0.20)
    $intensityLevels += @(3) * $level3Count
    
    # 20% level 4 (medium-dark green)
    $level4Count = [math]::Floor($CommitDays * 0.20)
    $intensityLevels += @(4) * $level4Count
    
    # 45% level 5 (dark green)
    $level5Count = $CommitDays - $level2Count - $level3Count - $level4Count
    $intensityLevels += @(5) * $level5Count
    
    # Shuffle the intensity levels
    $intensityLevels = $intensityLevels | Get-Random -Count $intensityLevels.Count
    
    # Create a map of date to intensity
    $commitSchedule = @{}
    for ($i = 0; $i -lt $commitDates.Count; $i++) {
        $commitSchedule[$commitDates[$i]] = $intensityLevels[$i]
    }
    
    return $commitSchedule
}

# Main execution
Write-Host "Generating backdated commit schedule for 2023-2024..." -ForegroundColor Yellow
$commitSchedule = Generate-BackdatedSchedule -CommitDays 280

Write-Host "Schedule generated with $($commitSchedule.Count) days" -ForegroundColor Cyan
Write-Host "First date: $($commitSchedule.Keys | Sort-Object | Select-Object -First 1)" -ForegroundColor Cyan
Write-Host "Last date: $($commitSchedule.Keys | Sort-Object | Select-Object -Last 1)" -ForegroundColor Cyan

# Make sure we're on the main branch
git checkout main
if ($LASTEXITCODE -ne 0) {
    Write-Log "Failed to checkout main branch. Creating it..."
    git checkout -b main
}

# Ask for confirmation
Write-Host ""
Write-Host "This script will create $($commitSchedule.Count) backdated commits for 2023-2024." -ForegroundColor Yellow
Write-Host "This operation will modify your Git history and should be used with caution." -ForegroundColor Yellow
Write-Host "It's recommended to run this on a fresh repository or branch." -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Do you want to proceed? (Y/N)"

if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Operation cancelled." -ForegroundColor Red
    exit
}

# Create the backdated commits
Write-Host ""
Write-Host "Creating backdated commits for 2023-2024..." -ForegroundColor Yellow
$counter = 0
$total = $commitSchedule.Count

foreach ($date in $commitSchedule.Keys | Sort-Object) {
    $intensity = $commitSchedule[$date]
    $counter++
    
    Write-Progress -Activity "Creating backdated commits for 2023-2024" -Status "Processing $counter of $total" -PercentComplete (($counter / $total) * 100)
    
    # Create 1-5 commits per day based on intensity
    $commitsPerDay = $intensity
    for ($i = 1; $i -le $commitsPerDay; $i++) {
        Create-BackdatedCommit -CommitDate $date -IntensityLevel $intensity
    }
}

Write-Host ""
Write-Host "Backdated commits for 2023-2024 created successfully!" -ForegroundColor Green
Write-Host "Created $counter days of backdated commits" -ForegroundColor Green

# Push the changes
Write-Host ""
$pushConfirm = Read-Host "Do you want to push these commits to GitHub now? (Y/N)"

if ($pushConfirm -eq "Y" -or $pushConfirm -eq "y") {
    Write-Host "Pushing commits to GitHub..." -ForegroundColor Yellow
    git push -f origin main
    Write-Host "Commits pushed successfully!" -ForegroundColor Green
} else {
    Write-Host "Commits were not pushed. You can push them manually later with 'git push -f origin main'" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Backdating process for 2023-2024 complete!" -ForegroundColor Green
Write-Host "Your GitHub contribution graph should now show activity for 2023-2024." -ForegroundColor Green
Write-Host "Note: It may take some time for GitHub to update your contribution graph." -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
