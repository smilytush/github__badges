# ===============================================
# DAILY AUTOMATION SETUP SCRIPT
# ===============================================
# Sets up Windows Task Scheduler for automated daily commits
# Creates 1-3 commits per day at randomized times
# ===============================================

param(
    [switch]$Remove = $false,
    [switch]$Force = $false
)

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $colors = @{
        "INFO" = "White"
        "SUCCESS" = "Green"
        "WARNING" = "Yellow"
        "ERROR" = "Red"
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $colors[$Level]
}

function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Remove-ExistingTask {
    $taskName = "GreenCommits-Daily"
    
    try {
        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Write-Log "Removing existing task: $taskName" "INFO"
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
            Write-Log "Existing task removed successfully" "SUCCESS"
        } else {
            Write-Log "No existing task found" "INFO"
        }
    }
    catch {
        Write-Log "Error removing existing task: $($_.Exception.Message)" "ERROR"
    }
}

function Create-DailyTask {
    $taskName = "GreenCommits-Daily"
    $scriptPath = Join-Path $PSScriptRoot "GreenCommits-Simple.ps1"
    
    # Verify script exists
    if (-not (Test-Path $scriptPath)) {
        Write-Log "Script not found: $scriptPath" "ERROR"
        return $false
    }
    
    try {
        # Create action
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`" -Mode Daily"
        
        # Create trigger - daily at 9 AM with random delay up to 8 hours
        $trigger = New-ScheduledTaskTrigger -Daily -At "09:00AM"
        $trigger.RandomDelay = "PT8H"  # Random delay up to 8 hours
        
        # Create settings
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable
        $settings.ExecutionTimeLimit = "PT1H"  # 1 hour timeout
        $settings.RestartCount = 3
        $settings.RestartInterval = "PT15M"  # Restart every 15 minutes if failed
        
        # Create principal (run as current user)
        $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
        
        # Register the task
        Write-Log "Creating scheduled task: $taskName" "INFO"
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Green Commits Daily Automation - Creates 1-3 commits per day"
        
        Write-Log "Scheduled task created successfully" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Error creating scheduled task: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Show-TaskInfo {
    $taskName = "GreenCommits-Daily"
    
    try {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($task) {
            Write-Log "Task Status: $($task.State)" "INFO"
            
            $taskInfo = Get-ScheduledTaskInfo -TaskName $taskName
            Write-Log "Last Run Time: $($taskInfo.LastRunTime)" "INFO"
            Write-Log "Next Run Time: $($taskInfo.NextRunTime)" "INFO"
            Write-Log "Last Result: $($taskInfo.LastTaskResult)" "INFO"
            
            return $true
        } else {
            Write-Log "Task not found: $taskName" "WARNING"
            return $false
        }
    }
    catch {
        Write-Log "Error getting task info: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-TaskExecution {
    $taskName = "GreenCommits-Daily"
    
    try {
        Write-Log "Testing task execution..." "INFO"
        Start-ScheduledTask -TaskName $taskName
        
        # Wait a moment for task to start
        Start-Sleep -Seconds 5
        
        $taskInfo = Get-ScheduledTaskInfo -TaskName $taskName
        Write-Log "Task execution test completed. Last result: $($taskInfo.LastTaskResult)" "INFO"
        
        return $true
    }
    catch {
        Write-Log "Error testing task execution: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Main {
    Write-Host ""
    Write-Host "GREEN COMMITS DAILY AUTOMATION SETUP" -ForegroundColor Magenta
    Write-Host "=====================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Check admin rights
    if (-not (Test-AdminRights)) {
        Write-Log "Administrator rights required for Task Scheduler operations" "WARNING"
        Write-Log "Please run this script as Administrator" "WARNING"
        
        if (-not $Force) {
            Write-Host ""
            $continue = Read-Host "Continue anyway? (y/N)"
            if ($continue -ne "y" -and $continue -ne "Y") {
                Write-Log "Operation cancelled" "INFO"
                return
            }
        }
    }
    
    # Remove mode
    if ($Remove) {
        Write-Log "Removing daily automation..." "INFO"
        Remove-ExistingTask
        Write-Log "Daily automation removal completed" "INFO"
        return
    }
    
    # Setup mode
    Write-Log "Setting up daily automation..." "INFO"
    
    # Remove existing task if present
    Remove-ExistingTask
    
    # Create new task
    if (Create-DailyTask) {
        Write-Host ""
        Write-Log "Daily automation setup completed successfully!" "SUCCESS"
        Write-Host ""
        
        # Show task information
        Show-TaskInfo
        
        Write-Host ""
        Write-Log "The system will now create 1-3 commits daily at random times between 9 AM and 5 PM" "INFO"
        Write-Log "You can monitor the task in Windows Task Scheduler under 'GreenCommits-Daily'" "INFO"
        
        # Ask if user wants to test
        if (-not $Force) {
            Write-Host ""
            $test = Read-Host "Would you like to test the automation now? (y/N)"
            if ($test -eq "y" -or $test -eq "Y") {
                Test-TaskExecution
            }
        }
    } else {
        Write-Log "Failed to setup daily automation" "ERROR"
    }
}

# Run main function
Main
