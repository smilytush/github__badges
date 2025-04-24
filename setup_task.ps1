# This script sets up the Windows Task Scheduler tasks to run the green_commit.ps1 script twice daily
# Path to the repository
$repoPath = "J:\green-commits"
$scriptPath = "$repoPath\green_commit.ps1"

# Morning task name and description
$morningTaskName = "GitHub Green Commit - Morning"
$morningTaskDescription = "Automatically makes commits to keep GitHub profile active (Morning session)"

# Afternoon task name and description
$afternoonTaskName = "GitHub Green Commit - Afternoon"
$afternoonTaskDescription = "Automatically makes commits to keep GitHub profile active (Afternoon session)"

# Check if the tasks already exist and remove them
$existingMorningTask = Get-ScheduledTask -TaskName $morningTaskName -ErrorAction SilentlyContinue
if ($existingMorningTask) {
    Write-Host "Task '$morningTaskName' already exists. Removing it..."
    Unregister-ScheduledTask -TaskName $morningTaskName -Confirm:$false
}

$existingAfternoonTask = Get-ScheduledTask -TaskName $afternoonTaskName -ErrorAction SilentlyContinue
if ($existingAfternoonTask) {
    Write-Host "Task '$afternoonTaskName' already exists. Removing it..."
    Unregister-ScheduledTask -TaskName $afternoonTaskName -Confirm:$false
}

# Check if the old task exists and remove it
$oldTaskName = "GitHub Green Commit"
$existingOldTask = Get-ScheduledTask -TaskName $oldTaskName -ErrorAction SilentlyContinue
if ($existingOldTask) {
    Write-Host "Old task '$oldTaskName' exists. Removing it..."
    Unregister-ScheduledTask -TaskName $oldTaskName -Confirm:$false
}

# Create the morning task
Write-Host "Creating morning scheduled task..."

# Set the trigger to run daily at 9:00 AM
$morningTrigger = New-ScheduledTaskTrigger -Daily -At "9:00 AM"

# Set the action (run PowerShell script)
$morningAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# Set the principal (run with highest privileges)
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType S4U -RunLevel Highest

# Set the settings (run as soon as possible if missed, etc.)
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 5)

# Register the morning task
Register-ScheduledTask -TaskName $morningTaskName -Description $morningTaskDescription -Trigger $morningTrigger -Action $morningAction -Principal $principal -Settings $settings

Write-Host "Task '$morningTaskName' created successfully!"

# Create the afternoon task
Write-Host "Creating afternoon scheduled task..."

# Set the trigger to run daily at 3:00 PM
$afternoonTrigger = New-ScheduledTaskTrigger -Daily -At "3:00 PM"

# Set the action (run PowerShell script)
$afternoonAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# Register the afternoon task
Register-ScheduledTask -TaskName $afternoonTaskName -Description $afternoonTaskDescription -Trigger $afternoonTrigger -Action $afternoonAction -Principal $principal -Settings $settings

Write-Host "Task '$afternoonTaskName' created successfully!"
Write-Host ""
Write-Host "The script will run twice daily: at 9:00 AM and 3:00 PM."
Write-Host ""
Write-Host "To verify the tasks were created correctly:"
Write-Host "1. Open Task Scheduler (taskschd.msc)"
Write-Host "2. Look for the tasks named '$morningTaskName' and '$afternoonTaskName' in the Task Scheduler Library"
Write-Host "3. Right-click on them and select 'Run' to test immediately"
