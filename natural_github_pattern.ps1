# Natural GitHub Contribution Pattern Script
# This script will:
# 1. Create a natural yet impressive GitHub contribution pattern
# 2. Make 280 out of 365 days have contributions (about 77%)
# 3. Focus on darker green intensities (levels 4-5)
# 4. Ensure 3 out of 10 days have the darkest green (level 5)

# Parameters
param(
    [int]$StartYear = 2022,
    [int]$StartMonth = 11,
    [int]$EndYear = 2025,
    [int]$EndMonth = 3,
    [switch]$Force = $false,
    [switch]$CleanupUnused = $false
)

# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# Function to log messages
function Write-Log {
    param(
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor Cyan
}

# Function to make a backdated commit
function New-BackdatedCommit {
    param(
        [string]$CommitDate,
        [int]$IntensityLevel = 5,
        [int]$CommitNumber = 1
    )
    
    # Create a simple file change
    $randomContent = "# Natural pattern commit for $CommitDate - #$CommitNumber`n"
    $randomContent += "# This is a backdated commit with natural pattern`n"
    $randomContent += "# Intensity Level: $IntensityLevel ($(Get-IntensityDescription $IntensityLevel))`n"
    
    # Add some code snippets based on the day of the week
    $dayOfWeek = [datetime]::ParseExact($CommitDate, "yyyy-MM-dd", $null).DayOfWeek.value__
    
    if ($dayOfWeek % 3 -eq 0) {
        # Python code
        $randomContent += "```python`n"
        $randomContent += "def process_data_$CommitNumber(data):`n"
        $randomContent += "    result = [x * $IntensityLevel for x in data if x > 0]`n"
        $randomContent += "    return result`n"
        $randomContent += "````n"
    }
    elseif ($dayOfWeek % 3 -eq 1) {
        # TypeScript code
        $randomContent += "```typescript`n"
        $randomContent += "function calculateValue$CommitNumber(input: number): number {`n"
        $randomContent += "    return input * $IntensityLevel + Math.random() * 10;`n"
        $randomContent += "}`n"
        $randomContent += "````n"
    }
    else {
        # Solidity code
        $randomContent += "```solidity`n"
        $randomContent += "function getValue$CommitNumber() public view returns (uint256) {`n"
        $randomContent += "    return $IntensityLevel * 10 + block.timestamp % 100;`n"
        $randomContent += "}`n"
        $randomContent += "````n"
    }
    
    $randomContent += "# Random data: $(Get-Random)`n"
    
    $filePath = "natural_pattern/$CommitDate-$CommitNumber.md"
    
    # Create directory if it doesn't exist
    if (-not (Test-Path "natural_pattern")) {
        New-Item -ItemType Directory -Path "natural_pattern" | Out-Null
    }
    
    # Write content to file
    $randomContent | Out-File -FilePath $filePath -Encoding utf8
    
    # Configure git user to match your GitHub account
    git config user.name "smilytush"
    git config user.email "tushar161@hotmail.com"
    
    # Add and commit with backdated timestamp
    git add $filePath
    
    # Set environment variables for backdating
    $env:GIT_COMMITTER_DATE = "$CommitDate 12:00:00"
    $env:GIT_AUTHOR_DATE = "$CommitDate 12:00:00"
    
    # Make the commit
    git commit -m "Natural pattern commit for $CommitDate (#$CommitNumber, Intensity: $IntensityLevel)" --date="$CommitDate 12:00:00"
    
    # Reset environment variables
    $env:GIT_COMMITTER_DATE = ""
    $env:GIT_AUTHOR_DATE = ""
    
    Write-Log "Created backdated commit for $CommitDate (#$CommitNumber, Intensity: $IntensityLevel)"
}

# Function to describe intensity levels
function Get-IntensityDescription {
    param(
        [int]$Level
    )
    
    switch ($Level) {
        4 { "Medium-dark green (Level 4)" }
        5 { "Dark green (Level 5)" }
        default { "Unknown" }
    }
}

# Function to generate dates for a month
function Get-MonthDates {
    param(
        [int]$Year,
        [int]$Month
    )
    
    $daysInMonth = 1..31 | ForEach-Object {
        try {
            Get-Date -Year $Year -Month $Month -Day $_ -ErrorAction Stop
        }
        catch {
            $null # Skip invalid days (e.g., Feb 30)
        }
    } | Where-Object { $_ -ne $null }
    
    return $daysInMonth
}

# Function to calculate the total number of days in a date range
function Get-TotalDaysInRange {
    param(
        [int]$StartYear,
        [int]$StartMonth,
        [int]$EndYear,
        [int]$EndMonth
    )
    
    $totalDays = 0
    $currentYear = $StartYear
    $currentMonth = $StartMonth
    
    while (($currentYear -lt $EndYear) -or (($currentYear -eq $EndYear) -and ($currentMonth -le $EndMonth))) {
        $daysInMonth = (Get-MonthDates -Year $currentYear -Month $currentMonth).Count
        $totalDays += $daysInMonth
        
        # Move to next month
        $currentMonth++
        if ($currentMonth -gt 12) {
            $currentMonth = 1
            $currentYear++
        }
    }
    
    return $totalDays
}

# Function to create a natural contribution pattern for a month
function New-NaturalMonthContributions {
    param(
        [int]$Year,
        [int]$Month,
        [double]$ContributionRatio,
        [ref]$RemainingContributions
    )
    
    $monthName = (Get-Culture).DateTimeFormat.GetMonthName($Month)
    Write-Log "Creating natural contributions for $monthName $Year..."
    
    # Get all days in the month
    $daysInMonth = Get-MonthDates -Year $Year -Month $Month
    
    # Calculate how many days should have contributions in this month
    # We want to distribute the contributions evenly across all months
    $daysWithContributions = [Math]::Min([Math]::Ceiling($daysInMonth.Count * $ContributionRatio), $RemainingContributions.Value)
    $RemainingContributions.Value -= $daysWithContributions
    
    # Ensure we don't try to select more days than are available
    if ($daysWithContributions -gt $daysInMonth.Count) {
        $daysWithContributions = $daysInMonth.Count
    }
    
    # Select random days for contributions
    $selectedDays = $daysInMonth | Get-Random -Count $daysWithContributions
    
    Write-Log "Selected $daysWithContributions days in $monthName $Year for contributions"
    Write-Log "Remaining contributions to distribute: $($RemainingContributions.Value)"
    
    # Calculate how many days should be each intensity level
    # 30% dark green (level 5), 70% medium-dark green (level 4)
    $darkGreenCount = [Math]::Ceiling($daysWithContributions * 0.3)
    $mediumDarkGreenCount = $daysWithContributions - $darkGreenCount
    
    Write-Log "Setting $darkGreenCount days as dark green (level 5)"
    Write-Log "Setting $mediumDarkGreenCount days as medium-dark green (level 4)"
    
    # Assign intensity levels to days
    $darkGreenDays = $selectedDays | Get-Random -Count $darkGreenCount
    $mediumDarkGreenDays = $selectedDays | Where-Object { $_ -notin $darkGreenDays }
    
    # Group days by week
    $weekGroups = $selectedDays | Group-Object -Property { Get-Date -Date $_ -UFormat %V }
    
    # Ensure each week has at least one dark green day if possible
    foreach ($week in $weekGroups) {
        $daysInWeek = $week.Group
        $darkGreenInWeek = $daysInWeek | Where-Object { $darkGreenDays -contains $_ }
        
        if ($darkGreenInWeek.Count -eq 0 -and $daysInWeek.Count -gt 0) {
            # Add one dark green day to this week
            $newDarkGreenDay = $daysInWeek | Get-Random -Count 1
            
            # Remove from medium-dark green days if needed
            if ($mediumDarkGreenDays -contains $newDarkGreenDay) {
                $mediumDarkGreenDays = $mediumDarkGreenDays | Where-Object { $_ -ne $newDarkGreenDay }
            }
            
            # Add to dark green days
            $darkGreenDays += $newDarkGreenDay
        }
    }
    
    # Process each selected day
    foreach ($day in $selectedDays) {
        $dateStr = $day.ToString("yyyy-MM-dd")
        
        # Determine intensity level
        $intensity = if ($darkGreenDays -contains $day) {
            # Dark green (level 5)
            5
        }
        else {
            # Medium-dark green (level 4)
            4
        }
        
        # Determine number of commits for this day based on intensity
        $numCommits = switch ($intensity) {
            5 { Get-Random -Minimum 6 -Maximum 10 } # More commits for dark green days
            4 { Get-Random -Minimum 3 -Maximum 7 } # Fewer commits for medium-dark days
            default { Get-Random -Minimum 3 -Maximum 7 }
        }
        
        Write-Log "Making $numCommits commits for $dateStr (Intensity: $intensity)"
        
        for ($i = 1; $i -le $numCommits; $i++) {
            New-BackdatedCommit -CommitDate $dateStr -IntensityLevel $intensity -CommitNumber $i
        }
    }
    
    Write-Log "Completed creating natural contributions for $monthName $Year"
    
    # Push changes to ensure they're not lost
    Write-Log "Pushing changes to GitHub..."
    git push origin main
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to push to main. Trying force push..."
        git push -f origin main
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Force push also failed. Please check your GitHub credentials and repository permissions."
            return $false
        }
    }
    
    return $true
}

# Function to clean up unused files and directories
function Remove-UnusedFiles {
    Write-Log "Cleaning up unused files and directories..."
    
    # List of directories to keep
    $directoriesToKeep = @("natural_pattern", ".git")
    
    # Get all directories in the repository
    $allDirectories = Get-ChildItem -Path $repoPath -Directory
    
    # Remove directories that are not in the keep list
    foreach ($directory in $allDirectories) {
        if ($directoriesToKeep -notcontains $directory.Name) {
            Write-Log "Removing directory: $($directory.FullName)"
            Remove-Item -Path $directory.FullName -Recurse -Force
        }
    }
    
    # Remove unused files in the root directory
    $filesToKeep = @(".gitignore", "README.md", "natural_github_pattern.ps1", "natural-github-pattern.bat")
    $allFiles = Get-ChildItem -Path $repoPath -File
    
    foreach ($file in $allFiles) {
        if ($filesToKeep -notcontains $file.Name) {
            Write-Log "Removing file: $($file.FullName)"
            Remove-Item -Path $file.FullName -Force
        }
    }
    
    # Commit the cleanup
    git add -A
    git commit -m "Cleanup unused files and directories"
    git push origin main
    
    Write-Log "Cleanup completed successfully!"
}

# Main execution
try {
    Write-Log "Starting to create natural GitHub contribution pattern..."
    
    # Ensure we're on the main branch
    Write-Log "Checking out main branch..."
    git checkout main
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to checkout main branch. Exiting..."
        exit 1
    }
    
    # Pull latest changes
    Write-Log "Pulling latest changes..."
    git pull origin main
    
    if ($LASTEXITCODE -ne 0 -and -not $Force) {
        Write-Log "Failed to pull latest changes. If you want to force push, run the script with -Force parameter."
        exit 1
    }
    
    # Calculate the total number of days in the date range
    $totalDays = Get-TotalDaysInRange -StartYear $StartYear -StartMonth $StartMonth -EndYear $EndYear -EndMonth $EndMonth
    Write-Log "Total days in date range: $totalDays"
    
    # We want 280 out of 365 days to have contributions (about 77%)
    # Calculate the contribution ratio based on the total days in the range
    $targetContributions = [Math]::Min(280, [Math]::Ceiling($totalDays * 0.77))
    $contributionRatio = $targetContributions / $totalDays
    
    Write-Log "Target contributions: $targetContributions (about 77% of days)"
    Write-Log "Contribution ratio: $([Math]::Round($contributionRatio * 100))%"
    
    # Keep track of remaining contributions to distribute
    $remainingContributions = [ref]$targetContributions
    
    # Process each month in the date range
    $currentYear = $StartYear
    $currentMonth = $StartMonth
    
    while (($currentYear -lt $EndYear) -or (($currentYear -eq $EndYear) -and ($currentMonth -le $EndMonth))) {
        # Create natural contributions for this month
        $success = New-NaturalMonthContributions -Year $currentYear -Month $currentMonth `
                                               -ContributionRatio $contributionRatio `
                                               -RemainingContributions $remainingContributions
        
        if (-not $success) {
            $monthName = (Get-Culture).DateTimeFormat.GetMonthName($currentMonth)
            Write-Log "Failed to create natural contributions for $monthName $currentYear. Exiting..."
            exit 1
        }
        
        # Move to next month
        $currentMonth++
        if ($currentMonth -gt 12) {
            $currentMonth = 1
            $currentYear++
        }
        
        # If we've distributed all contributions, we're done
        if ($remainingContributions.Value -le 0) {
            Write-Log "All contributions have been distributed. Stopping early."
            break
        }
    }
    
    # Clean up unused files if requested
    if ($CleanupUnused) {
        Remove-UnusedFiles
    }
    
    Write-Log "Successfully created natural GitHub contribution pattern!"
    Write-Log "Please check your GitHub profile to verify the contributions are now showing."
    Write-Log "Note: It may take a few minutes for GitHub to update your contribution graph."
    
    # Open GitHub profile in browser
    Start-Process "https://github.com/smilytush"
}
catch {
    Write-Log "Error: $_"
    Write-Log $_.ScriptStackTrace
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
