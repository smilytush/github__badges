# This script sets up the Windows Task Scheduler to run the green_workflow_4levels.ps1 script at startup
# Path to the repository
$repoPath = "J:\green-commits"
$scriptPath = "$repoPath\green_workflow_4levels.ps1"

# Startup task name and description
$startupTaskName = "Green GitHub Workflow - Startup"
$startupTaskDescription = "Automatically runs GitHub workflow when the computer starts"

# Check if the task already exists and remove it
$existingStartupTask = Get-ScheduledTask -TaskName $startupTaskName -ErrorAction SilentlyContinue
if ($existingStartupTask) {
    Write-Host "Task '$startupTaskName' already exists. Removing it..."
    Unregister-ScheduledTask -TaskName $startupTaskName -Confirm:$false
}

# Create the startup task
Write-Host "Creating startup scheduled task..."

# Set the trigger to run at startup
$startupTrigger = New-ScheduledTaskTrigger -AtStartup

# Set the action (run PowerShell script with morning session)
$startupAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -Command `"& { `$env:WORKFLOW_SESSION = 'morning'; & '$scriptPath' }`""

# Set the principal (run with highest privileges)
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType S4U -RunLevel Highest

# Set the settings (run as soon as possible if missed, etc.)
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 5)

# Register the startup task
Register-ScheduledTask -TaskName $startupTaskName -Description $startupTaskDescription -Trigger $startupTrigger -Action $startupAction -Principal $principal -Settings $settings

Write-Host "Task '$startupTaskName' created successfully!"

# Also create a logon task as a backup
$logonTaskName = "Green GitHub Workflow - Logon"
$logonTaskDescription = "Automatically runs GitHub workflow when the user logs on"

# Check if the task already exists and remove it
$existingLogonTask = Get-ScheduledTask -TaskName $logonTaskName -ErrorAction SilentlyContinue
if ($existingLogonTask) {
    Write-Host "Task '$logonTaskName' already exists. Removing it..."
    Unregister-ScheduledTask -TaskName $logonTaskName -Confirm:$false
}

# Set the trigger to run at logon
$logonTrigger = New-ScheduledTaskTrigger -AtLogOn

# Set the action (run PowerShell script with afternoon session)
$logonAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -Command `"& { `$env:WORKFLOW_SESSION = 'afternoon'; & '$scriptPath' }`""

# Register the logon task
Register-ScheduledTask -TaskName $logonTaskName -Description $logonTaskDescription -Trigger $logonTrigger -Action $logonAction -Principal $principal -Settings $settings

Write-Host "Task '$logonTaskName' created successfully!"
Write-Host ""
Write-Host "The script will now run:"
Write-Host "1. At system startup (morning session)"
Write-Host "2. When you log on (afternoon session)"
Write-Host "3. Daily at 9:00 AM (morning session)"
Write-Host "4. Daily at 3:00 PM (afternoon session)"
Write-Host ""
Write-Host "This ensures the system runs whenever your machine is turned on, regardless of date or month."
Write-Host ""
Write-Host "To verify the tasks were created correctly:"
Write-Host "1. Open Task Scheduler (taskschd.msc)"
Write-Host "2. Look for the tasks in the Task Scheduler Library"
Write-Host "3. Right-click on them and select 'Run' to test immediately"
