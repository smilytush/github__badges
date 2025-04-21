# This script sets up the Windows Task Scheduler task to run the green_commit.ps1 script daily

# Path to the repository
$repoPath = "J:\green-commits"
$scriptPath = "$repoPath\green_commit.ps1"

# Task name and description
$taskName = "GitHub Green Commit"
$taskDescription = "Automatically makes commits to keep GitHub profile active"

# Check if the task already exists
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "Task '$taskName' already exists. Removing it..."
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Create a new task
Write-Host "Creating new scheduled task..."

# Set the execution time (10:00 AM)
$trigger = New-ScheduledTaskTrigger -Daily -At 10am

# Set the action (run PowerShell script)
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# Set the principal (run with highest privileges)
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType S4U -RunLevel Highest

# Set the settings (run as soon as possible if missed, etc.)
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 5)

# Register the task
Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Trigger $trigger -Action $action -Principal $principal -Settings $settings

Write-Host "Task '$taskName' created successfully!"
Write-Host "The script will run daily at 10:00 AM."
Write-Host ""
Write-Host "To verify the task was created correctly:"
Write-Host "1. Open Task Scheduler (taskschd.msc)"
Write-Host "2. Look for the task named '$taskName' in the Task Scheduler Library"
Write-Host "3. Right-click on it and select 'Run' to test it immediately"
