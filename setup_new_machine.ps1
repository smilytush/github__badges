# Setup script for new machines
# This script sets up the green-commits system on a new machine

# Define the repository URL
$repoUrl = "https://github.com/smilytush/green-commits.git"

# Ask for the installation directory
Write-Host "Green GitHub Workflow Setup for New Machine" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
$installDir = Read-Host "Enter the directory where you want to install the green-commits system (e.g., C:\green-commits)"

# Create the directory if it doesn't exist
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
    Write-Host "Created directory: $installDir" -ForegroundColor Cyan
}

# Change to the installation directory
Set-Location $installDir

# Check if git is installed
try {
    $gitVersion = git --version
    Write-Host "Git is installed: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "Git is not installed. Please install Git before continuing." -ForegroundColor Red
    Write-Host "You can download Git from: https://git-scm.com/downloads" -ForegroundColor Yellow
    exit
}

# Clone the repository
Write-Host "Cloning the green-commits repository..." -ForegroundColor Cyan
git clone $repoUrl .

# Check if the clone was successful
if (-not $?) {
    Write-Host "Failed to clone the repository. Please check your internet connection and try again." -ForegroundColor Red
    exit
}

Write-Host "Repository cloned successfully!" -ForegroundColor Green

# Run the natural optimizer to create a schedule
Write-Host "Generating natural commit schedule..." -ForegroundColor Cyan
& .\green_optimizer_natural.ps1

# Set up the scheduled tasks
Write-Host "Setting up scheduled tasks..." -ForegroundColor Cyan
Write-Host "This requires administrator privileges." -ForegroundColor Yellow
$runAsAdmin = Read-Host "Run as administrator? (Y/N)"
if ($runAsAdmin -eq 'Y' -or $runAsAdmin -eq 'y') {
    # Update the repository path in the setup scripts
    $setupTaskContent = Get-Content .\setup_task_green.ps1 -Raw
    $setupTaskContent = $setupTaskContent -replace 'J:\\green-commits', $installDir.Replace('\', '\\')
    $setupTaskContent | Out-File -FilePath .\setup_task_green.ps1 -Encoding utf8
    
    $setupStartupContent = Get-Content .\setup_task_startup.ps1 -Raw
    $setupStartupContent = $setupStartupContent -replace 'J:\\green-commits', $installDir.Replace('\', '\\')
    $setupStartupContent | Out-File -FilePath .\setup_task_startup.ps1 -Encoding utf8
    
    # Run the setup scripts
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$installDir\setup_task_green.ps1`"" -Verb RunAs
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$installDir\setup_task_startup.ps1`"" -Verb RunAs
}

# Create a desktop shortcut
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "Green GitHub Workflow.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$installDir\green_github.bat`""
$shortcut.WorkingDirectory = $installDir
$shortcut.IconLocation = "shell32.dll,238"
$shortcut.Save()

Write-Host "Created desktop shortcut: $shortcutPath" -ForegroundColor Green

# Update the menu to reflect the new installation directory
$menuContent = Get-Content .\green_menu_fixed.ps1 -Raw
$menuContent = $menuContent -replace 'J:\\green-commits', $installDir.Replace('\', '\\')
$menuContent | Out-File -FilePath .\green_menu_fixed.ps1 -Encoding utf8

# Update the workflow script to reflect the new installation directory
$workflowContent = Get-Content .\green_workflow_4levels.ps1 -Raw
$workflowContent = $workflowContent -replace 'J:\\green-commits', $installDir.Replace('\', '\\')
$workflowContent | Out-File -FilePath .\green_workflow_4levels.ps1 -Encoding utf8

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "The green-commits system has been installed and configured on this machine." -ForegroundColor Cyan
Write-Host "The system will run automatically:" -ForegroundColor Cyan
Write-Host "- When the computer starts" -ForegroundColor White
Write-Host "- When you log on" -ForegroundColor White
Write-Host "- Daily at 9:00 AM" -ForegroundColor White
Write-Host "- Daily at 3:00 PM" -ForegroundColor White
Write-Host ""
Write-Host "You can also run the system manually by double-clicking the desktop shortcut" -ForegroundColor Cyan
Write-Host "or by running green_github.bat in the installation directory." -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
