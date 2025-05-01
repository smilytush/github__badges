# Enhanced GitHub Contribution Pattern Script
# This script will:
# 1. Create a natural yet impressive GitHub contribution pattern
# 2. Make 22-24 out of 30 days have contributions (about 73-80%)
# 3. Use intensity levels 3-5 (medium to dark green)
# 4. Ensure at least 3 days with high intensity (level 5) in each 10-day period

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
    "[$timestamp] $Message" | Out-File -Append -FilePath "$repoPath\enhanced_pattern_log.txt" -Encoding utf8
}

# Function to make a backdated commit
function New-BackdatedCommit {
    param(
        [string]$CommitDate,
        [int]$IntensityLevel = 5,
        [int]$CommitNumber = 1
    )
    
    # Create a simple file change
    $randomContent = "# Enhanced pattern commit for $CommitDate - #$CommitNumber`n"
    $randomContent += "# This is a backdated commit with enhanced pattern`n"
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
    
    $filePath = "enhanced_pattern/$CommitDate-$CommitNumber.md"
    
    # Create directory if it doesn't exist
    if (-not (Test-Path "enhanced_pattern")) {
        New-Item -ItemType Directory -Path "enhanced_pattern" | Out-Null
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
    git commit -m "Enhanced pattern commit for $CommitDate (#$CommitNumber, Intensity: $IntensityLevel)" --date="$CommitDate 12:00:00"
    
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
        3 { "Medium green (Level 3)" }
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

# Function to create an enhanced contribution pattern for a month
function New-EnhancedMonthContributions {
    param(
        [int]$Year,
        [int]$Month
    )
    
    $monthName = (Get-Culture).DateTimeFormat.GetMonthName($Month)
    Write-Log "Creating enhanced contributions for $monthName $Year..."
    
    # Get all days in the month
    $daysInMonth = Get-MonthDates -Year $Year -Month $Month
    
    # Calculate how many days should have contributions in this month (73-80%)
    $contributionRatio = Get-Random -Minimum 0.73 -Maximum 0.80
    $daysWithContributions = [Math]::Ceiling($daysInMonth.Count * $contributionRatio)
    
    Write-Log "Selected $daysWithContributions days in $monthName $Year for contributions ($(($contributionRatio * 100).ToString("0.0"))%)"
    
    # Select random days for contributions
    $selectedDays = $daysInMonth | Get-Random -Count $daysWithContributions
    
    # Group days by 10-day periods
    $tenDayGroups = @{}
    foreach ($day in $selectedDays) {
        $tenDayPeriod = [Math]::Ceiling($day.Day / 10.0)
        if (-not $tenDayGroups.ContainsKey($tenDayPeriod)) {
            $tenDayGroups[$tenDayPeriod] = @()
        }
        $tenDayGroups[$tenDayPeriod] += $day
    }
    
    # Assign intensity levels to days
    $level5Days = @()
    $level4Days = @()
    $level3Days = @()
    
    # Ensure at least 3 days with level 5 intensity in each 10-day period
    foreach ($period in $tenDayGroups.Keys) {
        $daysInPeriod = $tenDayGroups[$period]
        
        # If we have at least 3 days in this period, assign 3 to level 5
        if ($daysInPeriod.Count -ge 3) {
            $level5InPeriod = $daysInPeriod | Get-Random -Count 3
            $level5Days += $level5InPeriod
            
            # Remaining days in this period
            $remainingDays = $daysInPeriod | Where-Object { $_ -notin $level5InPeriod }
            
            # Distribute remaining days between level 3 and 4
            $level4Count = [Math]::Ceiling($remainingDays.Count * 0.6)
            if ($level4Count -gt 0 -and $remainingDays.Count -gt 0) {
                $level4InPeriod = $remainingDays | Get-Random -Count ([Math]::Min($level4Count, $remainingDays.Count))
                $level4Days += $level4InPeriod
                
                $level3InPeriod = $remainingDays | Where-Object { $_ -notin $level4InPeriod }
                $level3Days += $level3InPeriod
            } else {
                $level3Days += $remainingDays
            }
        } else {
            # If we have fewer than 3 days, assign all to level 5
            $level5Days += $daysInPeriod
        }
    }
    
    Write-Log "Setting $(($level5Days | Measure-Object).Count) days as dark green (level 5)"
    Write-Log "Setting $(($level4Days | Measure-Object).Count) days as medium-dark green (level 4)"
    Write-Log "Setting $(($level3Days | Measure-Object).Count) days as medium green (level 3)"
    
    # Process each selected day
    foreach ($day in $selectedDays) {
        $dateStr = $day.ToString("yyyy-MM-dd")
        
        # Determine intensity level
        $intensity = if ($level5Days -contains $day) {
            5
        } elseif ($level4Days -contains $day) {
            4
        } else {
            3
        }
        
        # Determine number of commits for this day based on intensity
        $numCommits = switch ($intensity) {
            5 { Get-Random -Minimum 6 -Maximum 10 } # More commits for dark green days
            4 { Get-Random -Minimum 4 -Maximum 7 } # Medium commits for medium-dark days
            3 { Get-Random -Minimum 2 -Maximum 5 } # Fewer commits for medium days
            default { Get-Random -Minimum 2 -Maximum 5 }
        }
        
        Write-Log "Making $numCommits commits for $dateStr (Intensity: $intensity)"
        
        for ($i = 1; $i -le $numCommits; $i++) {
            New-BackdatedCommit -CommitDate $dateStr -IntensityLevel $intensity -CommitNumber $i
        }
    }
    
    Write-Log "Completed creating enhanced contributions for $monthName $Year"
    
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
    $directoriesToKeep = @("enhanced_pattern", ".git")
    
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
    $filesToKeep = @(".gitignore", "README.md", "enhanced_github_pattern.ps1", "enhanced-github-pattern.bat", "enhanced_pattern_log.txt")
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
    Write-Log "Starting to create enhanced GitHub contribution pattern..."
    
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
    
    # Process each month in the date range
    $currentYear = $StartYear
    $currentMonth = $StartMonth
    
    while (($currentYear -lt $EndYear) -or (($currentYear -eq $EndYear) -and ($currentMonth -le $EndMonth))) {
        # Create enhanced contributions for this month
        $success = New-EnhancedMonthContributions -Year $currentYear -Month $currentMonth
        
        if (-not $success) {
            $monthName = (Get-Culture).DateTimeFormat.GetMonthName($currentMonth)
            Write-Log "Failed to create enhanced contributions for $monthName $currentYear. Exiting..."
            exit 1
        }
        
        # Move to next month
        $currentMonth++
        if ($currentMonth -gt 12) {
            $currentMonth = 1
            $currentYear++
        }
    }
    
    # Clean up unused files if requested
    if ($CleanupUnused) {
        Remove-UnusedFiles
    }
    
    Write-Log "Successfully created enhanced GitHub contribution pattern!"
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
