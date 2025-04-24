# Script to clean up duplicate and unused files from the repository
# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# Path to log file
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

Write-Log "Starting repository cleanup..."

# List of essential files to keep
$essentialFiles = @(
    "README.md",
    "green_commit_v2.ps1",
    "activity.log",
    "commit_schedule.txt",
    "script_log.txt",
    "dashboard.html",
    "GREEN-COMMITS-GUIDE.txt",
    "cleanup_repo.ps1",
    ".gitignore"
)

# List of essential directories to keep
$essentialDirs = @(
    "snippets"
)

# Get all files in the repository
$allFiles = Get-ChildItem -Path $repoPath -File -Recurse | Where-Object { 
    # Exclude files in .git directory
    $_.FullName -notmatch "\\\.git\\" 
}

# Get all directories in the repository
$allDirs = Get-ChildItem -Path $repoPath -Directory | Where-Object { 
    # Exclude .git directory
    $_.Name -ne ".git" -and $_.FullName -notmatch "\\\.git\\" 
}

# Files to remove
$filesToRemove = @()

# Check each file
foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Substring($repoPath.Length + 1)
    $fileName = $file.Name
    
    # Skip files in essential directories
    $inEssentialDir = $false
    foreach ($dir in $essentialDirs) {
        if ($relativePath.StartsWith($dir)) {
            $inEssentialDir = $true
            break
        }
    }
    
    if ($inEssentialDir) {
        continue
    }
    
    # Check if file is in the essential list
    if ($essentialFiles -notcontains $fileName) {
        $filesToRemove += $relativePath
    }
}

# Display files to be removed
if ($filesToRemove.Count -gt 0) {
    Write-Log "The following files will be removed:"
    foreach ($file in $filesToRemove) {
        Write-Log "- $file"
    }
    
    # Confirm removal
    $confirmation = Read-Host "Do you want to remove these files? (Y/N)"
    if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
        foreach ($file in $filesToRemove) {
            $fullPath = Join-Path -Path $repoPath -ChildPath $file
            Remove-Item -Path $fullPath -Force
            Write-Log "Removed: $file"
            
            # Remove from git
            git rm --cached $file
            Write-Log "Removed from git: $file"
        }
        
        # Commit the changes
        git commit -m "Remove duplicate and unused files"
        git push origin main
        
        Write-Log "Cleanup completed and changes pushed to GitHub."
    } else {
        Write-Log "Cleanup cancelled."
    }
} else {
    Write-Log "No files to remove."
}

# Update the main script
if (Test-Path "$repoPath\green_commit.ps1" -and (Test-Path "$repoPath\green_commit_v2.ps1")) {
    Write-Log "Updating main script..."
    
    # Backup the old script
    Copy-Item "$repoPath\green_commit.ps1" "$repoPath\green_commit.ps1.bak"
    Write-Log "Backed up green_commit.ps1 to green_commit.ps1.bak"
    
    # Replace with the new script
    Copy-Item "$repoPath\green_commit_v2.ps1" "$repoPath\green_commit.ps1" -Force
    Write-Log "Updated green_commit.ps1 with the new version"
    
    # Remove the v2 script
    Remove-Item "$repoPath\green_commit_v2.ps1"
    Write-Log "Removed green_commit_v2.ps1"
    
    # Commit the changes
    git add green_commit.ps1
    git commit -m "Update main script to support multiple commits per day and code snippets"
    git push origin main
    
    Write-Log "Main script updated and changes pushed to GitHub."
}
