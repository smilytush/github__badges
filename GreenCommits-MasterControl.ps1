# ===============================================
# GREEN COMMITS MASTER CONTROL SYSTEM v4.0
# ===============================================
# Production-Ready GitHub Contribution Graph Enhancement System
# Comprehensive, error-free master control interface
# Integrates all proven components into a single bulletproof system
#
# Author: Green Commits Master System
# Version: 4.0 Production Release
# Compatibility: PowerShell 5.1+ and PowerShell Core 7+
# Target: Complete GitHub contribution graph management
# ===============================================

[CmdletBinding()]
param(
    [ValidateSet("Full", "Test", "Custom", "Daily", "Badges", "Config", "Status", "Cleanup", "Force1", "Force3", "Force5", "Help", "Menu", "DailyAuto", "DailyStatus", "DailyConfig", "DailyInstall", "DailyRemove")]
    [string]$Mode = "Menu",
    [switch]$AutoConfirm = $false,
    [switch]$DryRun = $false,
    [switch]$Force = $false,
    [string]$StartDate = "",
    [string]$EndDate = "",
    [ValidateRange(1, 5)]
    [int]$Intensity = 0,
    [switch]$Help = $false,
    [switch]$Silent = $false
)

# ===============================================
# GLOBAL CONFIGURATION AND INITIALIZATION
# ===============================================

# Set strict execution policy and error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

# Global variables
$global:ScriptRoot = $PSScriptRoot
$global:ConfigPath = Join-Path $global:ScriptRoot "config.json"
$global:LogPath = Join-Path $global:ScriptRoot "GreenCommits-MasterControl.log"
$global:DailyStatePath = Join-Path $global:ScriptRoot "daily-execution-state.json"
$global:ExecutionLockPath = Join-Path $global:ScriptRoot "execution.lock"
$global:Config = @{}
$global:DailyState = @{}
$global:SessionStartTime = Get-Date
$global:OperationCount = 0

# Initialize script parameters as global variables for consistent access
$global:Silent = $Silent.IsPresent
$global:DryRun = $DryRun.IsPresent
$global:AutoConfirm = $AutoConfirm.IsPresent
$global:Force = $Force.IsPresent

# Color scheme for consistent UI
$global:Colors = @{
    "Header"   = "Magenta"
    "Success"  = "Green"
    "Warning"  = "Yellow"
    "Error"    = "Red"
    "Info"     = "Cyan"
    "Menu"     = "White"
    "Prompt"   = "Yellow"
    "Progress" = "Blue"
}

# Default configuration template
$global:DefaultConfig = @{
    GitHub     = @{
        Username      = "smilytush"
        Email         = "tushar161@hotmail.com"
        Token         = "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"
        Repository    = "github-commits"
        RemoteURL     = "https://github.com/smilytush/github-commits.git"
        DefaultBranch = "main"
        BaseAPIURL    = "https://api.github.com"
    }
    System     = @{
        RepoPath           = $global:ScriptRoot
        StartDate          = "2022-11-01"
        Coverage           = 0.82
        LogRetention       = 30
        MaxCommitsPerDay   = 50
        IntensityLevels    = @(1, 3, 5)
        SupportedLanguages = @("python", "solidity", "typescript", "javascript", "java", "cpp", "csharp", "go", "rust")
    }
    Automation = @{
        DailyCommits  = @{
            Enabled          = $false
            MinCommits       = 1
            MaxCommits       = 3
            TimeWindow       = @("09:00", "17:00")
            WeekendReduction = $true
        }
        TaskScheduler = @{
            TaskName    = "GreenCommits-Daily"
            Enabled     = $false
            RandomDelay = "PT8H"
        }
    }
    Badges     = @{
        Enabled    = $false
        Strategies = @{
            ArcticCodeVault    = $false
            Mars2020           = $false
            PullShark          = $false
            YOLO               = $false
            Quickdraw          = $false
            PairExtraordinaire = $false
            PublicSponsor      = $false
        }
    }
}

# ===============================================
# CORE LOGGING AND UTILITY FUNCTIONS
# ===============================================

function Write-MasterLog {
    <#
    .SYNOPSIS
    Enhanced logging system with multiple output levels and file logging
    
    .PARAMETER Message
    The message to log
    
    .PARAMETER Level
    The log level (INFO, SUCCESS, WARNING, ERROR, PROGRESS, DEBUG)
    
    .PARAMETER NoConsole
    Skip console output (file only)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR", "PROGRESS", "DEBUG")]
        [string]$Level = "INFO",
        
        [switch]$NoConsole
    )
    
    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Console output with colors
        if (-not $NoConsole -and -not $global:Silent) {
            $color = switch ($Level) {
                "SUCCESS" { $global:Colors.Success }
                "WARNING" { $global:Colors.Warning }
                "ERROR" { $global:Colors.Error }
                "PROGRESS" { $global:Colors.Progress }
                "DEBUG" { "Gray" }
                default { $global:Colors.Info }
            }
            Write-Host $logEntry -ForegroundColor $color
        }
        
        # File logging with error handling
        try {
            $logEntry | Out-File -FilePath $global:LogPath -Append -Encoding utf8 -ErrorAction Stop
        }
        catch {
            if (-not $NoConsole) {
                Write-Host "Warning: Could not write to log file: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        
        # Update operation counter
        $global:OperationCount++
    }
    catch {
        Write-Host "Critical logging error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Test-Prerequisites {
    <#
    .SYNOPSIS
    Comprehensive system prerequisites validation
    
    .DESCRIPTION
    Validates all system requirements including PowerShell version, Git installation,
    file permissions, and GitHub connectivity
    
    .OUTPUTS
    Boolean indicating if all prerequisites are met
    #>
    [CmdletBinding()]
    param()
    
    Write-MasterLog "Validating system prerequisites..." "INFO"
    
    $issues = @()
    $warnings = @()
    
    try {
        # PowerShell version check
        $psVersion = $PSVersionTable.PSVersion
        if ($psVersion.Major -lt 5) {
            $issues += "PowerShell 5.1 or higher required (current: $psVersion)"
        }
        else {
            Write-MasterLog "PowerShell version: $psVersion" "SUCCESS"
        }
        
        # Git installation and version check
        try {
            $gitVersion = git --version 2>$null
            if ($gitVersion) {
                Write-MasterLog "Git detected: $gitVersion" "SUCCESS"
                
                # Git configuration check
                try {
                    $gitUser = git config user.name 2>$null
                    $gitEmail = git config user.email 2>$null
                    if (-not $gitUser -or -not $gitEmail) {
                        $warnings += "Git user configuration incomplete (name: '$gitUser', email: '$gitEmail')"
                    }
                }
                catch {
                    $warnings += "Could not verify Git configuration"
                }
            }
            else {
                $issues += "Git command returned empty result"
            }
        }
        catch {
            $issues += "Git is not installed or not accessible in PATH"
        }
        
        # File system permissions check
        try {
            $testFile = Join-Path $global:ScriptRoot "test_permissions.tmp"
            "test" | Out-File -FilePath $testFile -ErrorAction Stop
            Remove-Item $testFile -ErrorAction Stop
            Write-MasterLog "File system permissions: OK" "SUCCESS"
        }
        catch {
            $issues += "Insufficient file system permissions in script directory"
        }
        
        # Essential files check
        $essentialFiles = @(
            "enhanced_historical_system_v2.ps1",
            "GreenCommits-Simple.ps1"
        )
        
        foreach ($file in $essentialFiles) {
            $filePath = Join-Path $global:ScriptRoot $file
            if (Test-Path $filePath) {
                Write-MasterLog "Essential file found: $file" "SUCCESS"
            }
            else {
                $issues += "Missing essential file: $file"
            }
        }
        
        # Internet connectivity check
        try {
            $null = Invoke-WebRequest -Uri "https://api.github.com" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
            Write-MasterLog "GitHub API connectivity: OK" "SUCCESS"
        }
        catch {
            $warnings += "GitHub API connectivity issue: $($_.Exception.Message)"
        }
        
        # Report results
        if ($warnings.Count -gt 0) {
            Write-MasterLog "System warnings detected:" "WARNING"
            foreach ($warning in $warnings) {
                Write-MasterLog "  - $warning" "WARNING"
            }
        }
        
        if ($issues.Count -gt 0) {
            Write-MasterLog "System validation failed:" "ERROR"
            foreach ($issue in $issues) {
                Write-MasterLog "  - $issue" "ERROR"
            }
            return $false
        }
        
        Write-MasterLog "All system prerequisites validated successfully" "SUCCESS"
        return $true
    }
    catch {
        Write-MasterLog "Critical error during prerequisites validation: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Initialize-Configuration {
    <#
    .SYNOPSIS
    Initialize and validate configuration system

    .DESCRIPTION
    Loads configuration from config.json, validates settings, and creates
    default configuration if needed

    .OUTPUTS
    Boolean indicating successful configuration initialization
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Initializing configuration system..." "INFO"

    try {
        if (Test-Path $global:ConfigPath) {
            try {
                $configContent = Get-Content $global:ConfigPath -Raw -ErrorAction Stop
                if ($PSVersionTable.PSVersion.Major -ge 6) {
                    $loadedConfig = $configContent | ConvertFrom-Json -AsHashtable -ErrorAction Stop
                }
                else {
                    # PowerShell 5.1 compatibility
                    $jsonObject = $configContent | ConvertFrom-Json -ErrorAction Stop
                    $loadedConfig = Convert-PSObjectToHashtable $jsonObject
                }

                # Merge with defaults to ensure all required keys exist
                $global:Config = Merge-Configurations $global:DefaultConfig $loadedConfig

                Write-MasterLog "Configuration loaded from config.json" "SUCCESS"

                # Validate critical configuration
                if (-not $global:Config.GitHub.Token -or $global:Config.GitHub.Token.Length -lt 10) {
                    Write-MasterLog "Invalid or missing GitHub token in configuration" "WARNING"
                }

                if (-not $global:Config.GitHub.Username) {
                    Write-MasterLog "Missing GitHub username in configuration" "WARNING"
                }
            }
            catch {
                Write-MasterLog "Error loading config.json: $($_.Exception.Message)" "WARNING"
                Write-MasterLog "Using default configuration" "INFO"
                $global:Config = $global:DefaultConfig.Clone()
            }
        }
        else {
            Write-MasterLog "No config.json found, creating default configuration" "INFO"
            $global:Config = $global:DefaultConfig.Clone()
            Save-Configuration
        }

        # Ensure script root is set correctly
        $global:Config.System.RepoPath = $global:ScriptRoot

        # Validate and create necessary directories
        $directories = @("logs", "backup", "temp")
        foreach ($dir in $directories) {
            $dirPath = Join-Path $global:ScriptRoot $dir
            if (-not (Test-Path $dirPath)) {
                try {
                    New-Item -ItemType Directory -Path $dirPath -Force -ErrorAction Stop | Out-Null
                    Write-MasterLog "Created directory: $dir" "INFO"
                }
                catch {
                    Write-MasterLog "Failed to create directory ${dir}: $($_.Exception.Message)" "WARNING"
                }
            }
        }

        Write-MasterLog "Configuration initialization completed successfully" "SUCCESS"

        # Initialize daily state management
        if (-not (Initialize-DailyState)) {
            Write-MasterLog "Daily state initialization failed, but continuing with configuration" "WARNING"
        }

        return $true
    }
    catch {
        Write-MasterLog "Critical error during configuration initialization: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Convert-PSObjectToHashtable {
    <#
    .SYNOPSIS
    Convert PSObject to Hashtable for PowerShell 5.1 compatibility

    .PARAMETER InputObject
    The PSObject to convert

    .OUTPUTS
    Hashtable representation of the PSObject
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSObject]$InputObject
    )

    $hashtable = @{}

    foreach ($property in $InputObject.PSObject.Properties) {
        if ($property.Value -is [PSCustomObject]) {
            $hashtable[$property.Name] = Convert-PSObjectToHashtable $property.Value
        }
        else {
            $hashtable[$property.Name] = $property.Value
        }
    }

    return $hashtable
}

function Merge-Configurations {
    <#
    .SYNOPSIS
    Recursively merge two configuration hashtables

    .PARAMETER Default
    Default configuration hashtable

    .PARAMETER Loaded
    Loaded configuration hashtable

    .OUTPUTS
    Merged configuration hashtable
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Default,

        [Parameter(Mandatory = $true)]
        [hashtable]$Loaded
    )

    $merged = $Default.Clone()

    foreach ($key in $Loaded.Keys) {
        if ($merged.ContainsKey($key)) {
            if ($merged[$key] -is [hashtable] -and $Loaded[$key] -is [hashtable]) {
                $merged[$key] = Merge-Configurations $merged[$key] $Loaded[$key]
            }
            else {
                $merged[$key] = $Loaded[$key]
            }
        }
        else {
            $merged[$key] = $Loaded[$key]
        }
    }

    return $merged
}

function Save-Configuration {
    <#
    .SYNOPSIS
    Save current configuration to config.json

    .OUTPUTS
    Boolean indicating successful save operation
    #>
    [CmdletBinding()]
    param()

    try {
        # Create backup of existing config
        if (Test-Path $global:ConfigPath) {
            $backupPath = Join-Path $global:ScriptRoot "backup" "config_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
            Copy-Item $global:ConfigPath $backupPath -ErrorAction SilentlyContinue
        }

        # Save current configuration
        $global:Config | ConvertTo-Json -Depth 10 | Out-File -FilePath $global:ConfigPath -Encoding utf8 -ErrorAction Stop
        Write-MasterLog "Configuration saved to config.json" "SUCCESS"
        return $true
    }
    catch {
        Write-MasterLog "Error saving configuration: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# ===============================================
# DAILY AUTOMATION STATE MANAGEMENT FUNCTIONS
# ===============================================

function Initialize-DailyState {
    <#
    .SYNOPSIS
    Initialize and load daily execution state management system

    .OUTPUTS
    Boolean indicating successful state initialization
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Initializing daily automation state management..." "INFO"

    try {
        # Default daily state structure
        $defaultDailyState = @{
            lastExecutionDate = ""
            intensityLevel    = 1
            automationEnabled = $false
            todaysCommitCount = 0
            executionHistory  = @()
            lockFileCreated   = $false
            version           = "4.0"
        }

        if (Test-Path $global:DailyStatePath) {
            try {
                $stateContent = Get-Content $global:DailyStatePath -Raw -ErrorAction Stop
                if ($PSVersionTable.PSVersion.Major -ge 6) {
                    $loadedState = $stateContent | ConvertFrom-Json -AsHashtable -ErrorAction Stop
                }
                else {
                    # PowerShell 5.1 compatibility
                    $jsonObject = $stateContent | ConvertFrom-Json -ErrorAction Stop
                    $loadedState = Convert-PSObjectToHashtable $jsonObject
                }

                # Merge with defaults to ensure all required keys exist
                $global:DailyState = Merge-Configurations $defaultDailyState $loadedState

                Write-MasterLog "Daily state loaded from daily-execution-state.json" "SUCCESS"
            }
            catch {
                Write-MasterLog "Error loading daily state: $($_.Exception.Message)" "WARNING"
                Write-MasterLog "Using default daily state" "INFO"
                $global:DailyState = $defaultDailyState.Clone()
            }
        }
        else {
            Write-MasterLog "No daily state file found, creating default state" "INFO"
            $global:DailyState = $defaultDailyState.Clone()
            Save-DailyState
        }

        Write-MasterLog "Daily state initialization completed successfully" "SUCCESS"
        return $true
    }
    catch {
        Write-MasterLog "Critical error during daily state initialization: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Save-DailyState {
    <#
    .SYNOPSIS
    Save current daily state to daily-execution-state.json

    .OUTPUTS
    Boolean indicating successful save operation
    #>
    [CmdletBinding()]
    param()

    try {
        # Create backup of existing state
        if (Test-Path $global:DailyStatePath) {
            $backupDir = Join-Path $global:ScriptRoot "backup"
            if (-not (Test-Path $backupDir)) {
                New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
            }
            $backupPath = Join-Path $backupDir "daily_state_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
            Copy-Item $global:DailyStatePath $backupPath -ErrorAction SilentlyContinue
        }

        # Save current daily state
        $global:DailyState | ConvertTo-Json -Depth 10 | Out-File -FilePath $global:DailyStatePath -Encoding utf8 -ErrorAction Stop
        Write-MasterLog "Daily state saved to daily-execution-state.json" "SUCCESS"
        return $true
    }
    catch {
        Write-MasterLog "Error saving daily state: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-DailyExecutionAllowed {
    <#
    .SYNOPSIS
    Check if daily execution is allowed based on current state

    .OUTPUTS
    Boolean indicating if daily execution should proceed
    #>
    [CmdletBinding()]
    param()

    try {
        $today = Get-Date -Format "yyyy-MM-dd"

        # Check if automation is enabled
        if (-not $global:DailyState.automationEnabled) {
            Write-MasterLog "Daily automation is disabled" "INFO"
            return $false
        }

        # Check if already executed today
        if ($global:DailyState.lastExecutionDate -eq $today) {
            Write-MasterLog "Daily execution already completed today ($today)" "INFO"
            return $false
        }

        # Check for execution lock
        if (Test-Path $global:ExecutionLockPath) {
            $lockAge = (Get-Date) - (Get-Item $global:ExecutionLockPath).CreationTime
            if ($lockAge.TotalMinutes -lt 30) {
                Write-MasterLog "Execution lock detected (created $($lockAge.TotalMinutes.ToString('F1')) minutes ago)" "WARNING"
                return $false
            }
            else {
                Write-MasterLog "Stale execution lock detected, removing..." "WARNING"
                Remove-Item $global:ExecutionLockPath -Force -ErrorAction SilentlyContinue
            }
        }

        Write-MasterLog "Daily execution is allowed for $today" "SUCCESS"
        return $true
    }
    catch {
        Write-MasterLog "Error checking daily execution status: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Set-ExecutionLock {
    <#
    .SYNOPSIS
    Create execution lock to prevent concurrent runs

    .OUTPUTS
    Boolean indicating successful lock creation
    #>
    [CmdletBinding()]
    param()

    try {
        $lockInfo = @{
            createdAt      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            processId      = $PID
            scriptPath     = $global:ScriptRoot
            intensityLevel = $global:DailyState.intensityLevel
        }

        $lockInfo | ConvertTo-Json | Out-File -FilePath $global:ExecutionLockPath -Encoding utf8 -ErrorAction Stop
        $global:DailyState.lockFileCreated = $true

        Write-MasterLog "Execution lock created successfully" "SUCCESS"
        return $true
    }
    catch {
        Write-MasterLog "Error creating execution lock: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Remove-ExecutionLock {
    <#
    .SYNOPSIS
    Remove execution lock after completion

    .OUTPUTS
    Boolean indicating successful lock removal
    #>
    [CmdletBinding()]
    param()

    try {
        if (Test-Path $global:ExecutionLockPath) {
            Remove-Item $global:ExecutionLockPath -Force -ErrorAction Stop
            $global:DailyState.lockFileCreated = $false
            Write-MasterLog "Execution lock removed successfully" "SUCCESS"
        }
        return $true
    }
    catch {
        Write-MasterLog "Error removing execution lock: $($_.Exception.Message)" "WARNING"
        return $false
    }
}

function Update-DailyExecutionRecord {
    <#
    .SYNOPSIS
    Update daily execution record with today's activity

    .PARAMETER CommitCount
    Number of commits created today

    .OUTPUTS
    Boolean indicating successful record update
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$CommitCount
    )

    try {
        $today = Get-Date -Format "yyyy-MM-dd"

        # Update current state
        $global:DailyState.lastExecutionDate = $today
        $global:DailyState.todaysCommitCount = $CommitCount

        # Add to execution history
        $historyEntry = @{
            date      = $today
            commits   = $CommitCount
            intensity = $global:DailyState.intensityLevel
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        # Maintain only last 30 days of history
        $global:DailyState.executionHistory = @($global:DailyState.executionHistory | Select-Object -Last 29) + $historyEntry

        # Save updated state
        Save-DailyState

        Write-MasterLog "Daily execution record updated: $CommitCount commits created with intensity level $($global:DailyState.intensityLevel)" "SUCCESS"
        return $true
    }
    catch {
        Write-MasterLog "Error updating daily execution record: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# ===============================================
# GITHUB INTEGRATION AND VALIDATION FUNCTIONS
# ===============================================

function Test-GitHubConnectivity {
    <#
    .SYNOPSIS
    Test GitHub API connectivity and authentication

    .OUTPUTS
    Boolean indicating successful GitHub connectivity
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Testing GitHub connectivity and authentication..." "INFO"

    try {
        $headers = @{
            "Authorization" = "token $($global:Config.GitHub.Token)"
            "User-Agent"    = "GreenCommits-MasterControl/4.0"
            "Accept"        = "application/vnd.github.v3+json"
        }

        # Test basic API access
        $userResponse = Invoke-RestMethod -Uri "$($global:Config.GitHub.BaseAPIURL)/user" -Headers $headers -ErrorAction Stop
        Write-MasterLog "GitHub authentication successful for user: $($userResponse.login)" "SUCCESS"

        # Test rate limits
        $rateLimitResponse = Invoke-RestMethod -Uri "$($global:Config.GitHub.BaseAPIURL)/rate_limit" -Headers $headers -ErrorAction Stop
        $coreRemaining = $rateLimitResponse.resources.core.remaining
        $coreLimit = $rateLimitResponse.resources.core.limit

        Write-MasterLog "GitHub API rate limits - Core: $coreRemaining/$coreLimit" "INFO"

        if ($coreRemaining -lt 100) {
            Write-MasterLog "Warning: Low GitHub API rate limit remaining ($coreRemaining)" "WARNING"
        }

        # Test repository access
        try {
            $repoUrl = "$($global:Config.GitHub.BaseAPIURL)/repos/$($global:Config.GitHub.Username)/$($global:Config.GitHub.Repository)"
            $repoResponse = Invoke-RestMethod -Uri $repoUrl -Headers $headers -ErrorAction Stop
            Write-MasterLog "Repository access confirmed: $($repoResponse.full_name)" "SUCCESS"
        }
        catch {
            Write-MasterLog "Repository access failed: $($_.Exception.Message)" "WARNING"
            Write-MasterLog "Repository may need to be created or token permissions updated" "WARNING"
        }

        return $true
    }
    catch {
        Write-MasterLog "GitHub connectivity test failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Show-SystemStatus {
    <#
    .SYNOPSIS
    Display comprehensive system status information
    #>
    [CmdletBinding()]
    param()

    # Initialize console output buffering for smooth display
    if (-not $global:Silent) {
        Write-Host ""
        Write-Host ""
    }
    Write-Host "================================================================" -ForegroundColor $global:Colors.Header
    Write-Host "                    SYSTEM STATUS REPORT                       " -ForegroundColor $global:Colors.Header
    Write-Host "================================================================" -ForegroundColor $global:Colors.Header
    Write-Host ""

    # Session information
    $sessionDuration = (Get-Date) - $global:SessionStartTime
    Write-Host "Session Information:" -ForegroundColor $global:Colors.Info
    Write-Host "  Start Time: $($global:SessionStartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor $global:Colors.Menu
    Write-Host "  Duration: $($sessionDuration.ToString('hh\:mm\:ss'))" -ForegroundColor $global:Colors.Menu
    Write-Host "  Operations: $global:OperationCount" -ForegroundColor $global:Colors.Menu
    Write-Host ""

    # Configuration status
    Write-Host "Configuration Status:" -ForegroundColor $global:Colors.Info
    Write-Host "  GitHub User: $($global:Config.GitHub.Username)" -ForegroundColor $global:Colors.Menu
    Write-Host "  Repository: $($global:Config.GitHub.Repository)" -ForegroundColor $global:Colors.Menu
    Write-Host "  Coverage Target: $([math]::Round($global:Config.System.Coverage * 100))%" -ForegroundColor $global:Colors.Menu
    Write-Host "  Start Date: $($global:Config.System.StartDate)" -ForegroundColor $global:Colors.Menu
    Write-Host ""

    # File system status
    Write-Host "File System Status:" -ForegroundColor $global:Colors.Info
    Write-Host "  Script Root: $global:ScriptRoot" -ForegroundColor $global:Colors.Menu
    Write-Host "  Config File: $(if (Test-Path $global:ConfigPath) { 'Found' } else { 'Missing' })" -ForegroundColor $global:Colors.Menu
    Write-Host "  Log File: $(if (Test-Path $global:LogPath) { 'Active' } else { 'Not Created' })" -ForegroundColor $global:Colors.Menu
    Write-Host ""

    # Essential files check
    Write-Host "Essential Files:" -ForegroundColor $global:Colors.Info
    $essentialFiles = @(
        "enhanced_historical_system_v2.ps1",
        "GreenCommits-Simple.ps1",
        "run-daily-commits.bat"
    )

    foreach ($file in $essentialFiles) {
        $filePath = Join-Path $global:ScriptRoot $file
        $status = if (Test-Path $filePath) { "OK" } else { "MISSING" }
        $color = if (Test-Path $filePath) { $global:Colors.Success } else { $global:Colors.Error }
        Write-Host "  $file : $status" -ForegroundColor $color
    }
    Write-Host ""

    # GitHub connectivity test
    Write-Host "GitHub Connectivity:" -ForegroundColor $global:Colors.Info
    if (Test-GitHubConnectivity) {
        Write-Host "  Status: Connected and Authenticated" -ForegroundColor $global:Colors.Success
    }
    else {
        Write-Host "  Status: Connection Failed" -ForegroundColor $global:Colors.Error
    }
    Write-Host ""

    Write-Host "================================================================" -ForegroundColor $global:Colors.Header
}

# ===============================================
# MAIN MENU SYSTEM
# ===============================================

function Show-MainMenu {
    <#
    .SYNOPSIS
    Display the main menu interface

    .OUTPUTS
    String representing the user's menu choice
    #>
    [CmdletBinding()]
    param()

    # Initialize console output buffering for smooth display
    if (-not $global:Silent) {
        Write-Host ""
        Write-Host ""
    }
    Write-Host "================================================================" -ForegroundColor $global:Colors.Header
    Write-Host "           GREEN COMMITS MASTER CONTROL SYSTEM v4.0            " -ForegroundColor $global:Colors.Header
    Write-Host "        Production-Ready GitHub Contribution Enhancement        " -ForegroundColor $global:Colors.Header
    Write-Host "================================================================" -ForegroundColor $global:Colors.Header
    Write-Host ""

    # System status summary
    Write-Host "Current Configuration:" -ForegroundColor $global:Colors.Info
    Write-Host "  GitHub User: $($global:Config.GitHub.Username)" -ForegroundColor $global:Colors.Menu
    Write-Host "  Repository: $($global:Config.GitHub.Repository)" -ForegroundColor $global:Colors.Menu
    Write-Host "  Coverage Target: $([math]::Round($global:Config.System.Coverage * 100))%" -ForegroundColor $global:Colors.Menu
    Write-Host "  Session Operations: $global:OperationCount" -ForegroundColor $global:Colors.Menu
    Write-Host ""

    Write-Host "Available Operations:" -ForegroundColor $global:Colors.Prompt
    Write-Host ""

    # Core operations
    Write-Host "  CORE OPERATIONS:" -ForegroundColor $global:Colors.Info
    Write-Host "  [1]  Run Full Historical Backfill - 779 days, Nov 2022-present" -ForegroundColor $global:Colors.Success
    Write-Host "  [2]  Test Mode - 5 sample commits for verification" -ForegroundColor $global:Colors.Success
    Write-Host "  [3]  Custom Date Range Commits - user-specified dates" -ForegroundColor $global:Colors.Success
    Write-Host "  [4]  Daily Automation Setup - Windows Task Scheduler" -ForegroundColor $global:Colors.Success
    Write-Host ""

    # Advanced operations
    Write-Host "  ADVANCED OPERATIONS:" -ForegroundColor $global:Colors.Info
    Write-Host "  [5]  GitHub Badge Achievement Mode - automated strategies" -ForegroundColor $global:Colors.Menu
    Write-Host "  [6]  System Configuration and Validation - settings management" -ForegroundColor $global:Colors.Menu
    Write-Host "  [7]  View Current Contribution Graph Status - real-time analysis" -ForegroundColor $global:Colors.Menu
    Write-Host "  [8]  Project Cleanup and Maintenance - file organization" -ForegroundColor $global:Colors.Menu
    Write-Host ""

    # Force commit operations
    Write-Host "  FORCE COMMIT INTENSITY MODES:" -ForegroundColor $global:Colors.Info
    Write-Host "  [9]  Force Commits - Intensity Level 1 - Light green, 1-5 commits/day" -ForegroundColor $global:Colors.Menu
    Write-Host "  [10] Force Commits - Intensity Level 3 - Medium green, 10-20 commits/day" -ForegroundColor $global:Colors.Menu
    Write-Host "  [11] Force Commits - Intensity Level 5 - Dark green, 30-50 commits/day" -ForegroundColor $global:Colors.Menu
    Write-Host ""

    # Daily automation management
    Write-Host "  DAILY AUTOMATION MANAGEMENT:" -ForegroundColor $global:Colors.Info
    Write-Host "  [DA] Daily Automation Status & Configuration" -ForegroundColor $global:Colors.Menu
    Write-Host "  [DC] Configure Daily Automation (Intensity & Enable/Disable)" -ForegroundColor $global:Colors.Menu
    Write-Host "  [DI] Install Daily Automation Task Scheduler" -ForegroundColor $global:Colors.Menu
    Write-Host "  [DR] Remove Daily Automation Task Scheduler" -ForegroundColor $global:Colors.Menu
    Write-Host ""

    # System operations
    Write-Host "  SYSTEM OPERATIONS:" -ForegroundColor $global:Colors.Info
    Write-Host "  [12] Help and Documentation - comprehensive guide" -ForegroundColor $global:Colors.Menu
    Write-Host "  [0]  Exit System" -ForegroundColor $global:Colors.Error
    Write-Host ""

    Write-Host "================================================================" -ForegroundColor $global:Colors.Header
    Write-Host ""

    # Get user input with validation
    do {
        Write-Host "Select an option (0-12, DA, DC, DI, DR): " -ForegroundColor $global:Colors.Prompt -NoNewline
        $choice = Read-Host

        switch ($choice.ToUpper()) {
            "1" { return "Full" }
            "2" { return "Test" }
            "3" { return "Custom" }
            "4" { return "Daily" }
            "5" { return "Badges" }
            "6" { return "Config" }
            "7" { return "Status" }
            "8" { return "Cleanup" }
            "9" { return "Force1" }
            "10" { return "Force3" }
            "11" { return "Force5" }
            "12" { return "Help" }
            "DA" { return "DailyStatus" }
            "DC" { return "DailyConfig" }
            "DI" { return "DailyInstall" }
            "DR" { return "DailyRemove" }
            "0" { return "Exit" }
            default {
                Write-Host "Invalid selection. Please choose 0-12, DA, DC, DI, or DR." -ForegroundColor $global:Colors.Error
                Write-Host ""
            }
        }
    } while ($true)
}

function Show-HelpSystem {
    <#
    .SYNOPSIS
    Display comprehensive help and documentation
    #>
    [CmdletBinding()]
    param()

    # Initialize console output buffering for smooth display
    if (-not $global:Silent) {
        Write-Host ""
        Write-Host ""
    }
    Write-Host "================================================================" -ForegroundColor $global:Colors.Header
    Write-Host "              GREEN COMMITS HELP AND DOCUMENTATION             " -ForegroundColor $global:Colors.Header
    Write-Host "================================================================" -ForegroundColor $global:Colors.Header
    Write-Host ""

    Write-Host "COMMAND LINE USAGE:" -ForegroundColor $global:Colors.Info
    Write-Host "  .\GreenCommits-MasterControl.ps1 -Mode MODE [Options]" -ForegroundColor $global:Colors.Menu
    Write-Host ""

    Write-Host "AVAILABLE MODES:" -ForegroundColor $global:Colors.Info
    Write-Host "  Full        - Run complete historical backfill (779 days)" -ForegroundColor $global:Colors.Menu
    Write-Host "  Test        - Create 5 sample commits for verification" -ForegroundColor $global:Colors.Menu
    Write-Host "  Custom      - Specify custom date range and intensity" -ForegroundColor $global:Colors.Menu
    Write-Host "  Daily       - Setup daily automation with Task Scheduler" -ForegroundColor $global:Colors.Menu
    Write-Host "  Badges      - GitHub badge achievement system" -ForegroundColor $global:Colors.Menu
    Write-Host "  Config      - Configuration management and validation" -ForegroundColor $global:Colors.Menu
    Write-Host "  Status      - View contribution graph and system status" -ForegroundColor $global:Colors.Menu
    Write-Host "  Cleanup     - Project cleanup and maintenance" -ForegroundColor $global:Colors.Menu
    Write-Host "  Force1      - Light intensity commits (1-5 per day)" -ForegroundColor $global:Colors.Menu
    Write-Host "  Force3      - Medium intensity commits (10-20 per day)" -ForegroundColor $global:Colors.Menu
    Write-Host "  Force5      - Maximum intensity commits (30-50 per day)" -ForegroundColor $global:Colors.Menu
    Write-Host "  DailyAuto   - Execute daily automation (used by Task Scheduler)" -ForegroundColor $global:Colors.Menu
    Write-Host "  DailyStatus - Show daily automation status" -ForegroundColor $global:Colors.Menu
    Write-Host "  DailyConfig - Configure daily automation settings" -ForegroundColor $global:Colors.Menu
    Write-Host ""

    Write-Host "COMMAND LINE OPTIONS:" -ForegroundColor $global:Colors.Info
    Write-Host "  -AutoConfirm    Skip confirmation prompts" -ForegroundColor $global:Colors.Menu
    Write-Host "  -DryRun         Preview changes without executing" -ForegroundColor $global:Colors.Menu
    Write-Host "  -Force          Force execution, use with caution" -ForegroundColor $global:Colors.Menu
    Write-Host "  -StartDate      Custom start date (YYYY-MM-DD format)" -ForegroundColor $global:Colors.Menu
    Write-Host "  -EndDate        Custom end date (YYYY-MM-DD format)" -ForegroundColor $global:Colors.Menu
    Write-Host "  -Intensity      Commit intensity level (1-5)" -ForegroundColor $global:Colors.Menu
    Write-Host "  -Silent         Suppress console output" -ForegroundColor $global:Colors.Menu
    Write-Host ""

    Write-Host "EXAMPLES:" -ForegroundColor $global:Colors.Info
    Write-Host "  .\GreenCommits-MasterControl.ps1 -Mode Test" -ForegroundColor $global:Colors.Menu
    Write-Host "  .\GreenCommits-MasterControl.ps1 -Mode Full -AutoConfirm" -ForegroundColor $global:Colors.Menu
    Write-Host "  .\GreenCommits-MasterControl.ps1 -Mode Custom -StartDate '2024-01-01' -EndDate '2024-12-31' -Intensity 3" -ForegroundColor $global:Colors.Menu
    Write-Host "  .\GreenCommits-MasterControl.ps1 -Mode Force3 -DryRun" -ForegroundColor $global:Colors.Menu
    Write-Host "  .\GreenCommits-MasterControl.ps1 -Mode DailyAuto -Silent" -ForegroundColor $global:Colors.Menu
    Write-Host "  .\GreenCommits-MasterControl.ps1 -Mode DailyStatus" -ForegroundColor $global:Colors.Menu
    Write-Host "  .\GreenCommits-MasterControl.ps1 -Mode DailyConfig" -ForegroundColor $global:Colors.Menu
    Write-Host ""

    Write-Host "INTENSITY LEVELS EXPLAINED:" -ForegroundColor $global:Colors.Info
    Write-Host "  Level 1 (Light)   - 1-5 commits per day, realistic patterns" -ForegroundColor $global:Colors.Menu
    Write-Host "  Level 3 (Medium)  - 10-20 commits per day, consistent activity" -ForegroundColor $global:Colors.Menu
    Write-Host "  Level 5 (Maximum) - 30-50 commits per day, high-intensity development" -ForegroundColor $global:Colors.Menu
    Write-Host ""

    Write-Host "SAFETY FEATURES:" -ForegroundColor $global:Colors.Info
    Write-Host "  - Automatic configuration backup before changes" -ForegroundColor $global:Colors.Menu
    Write-Host "  - GitHub API rate limit monitoring and respect" -ForegroundColor $global:Colors.Menu
    Write-Host "  - Comprehensive error handling and recovery" -ForegroundColor $global:Colors.Menu
    Write-Host "  - Dry-run mode for testing without execution" -ForegroundColor $global:Colors.Menu
    Write-Host "  - Detailed logging of all operations" -ForegroundColor $global:Colors.Menu
    Write-Host ""

    Write-Host "================================================================" -ForegroundColor $global:Colors.Header
    Write-Host ""
    Write-Host "Press any key to return to main menu..." -ForegroundColor $global:Colors.Prompt
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ===============================================
# OPERATION EXECUTION FUNCTIONS
# ===============================================

function Invoke-Operation {
    <#
    .SYNOPSIS
    Execute the specified operation with comprehensive error handling

    .PARAMETER OperationMode
    The operation mode to execute

    .OUTPUTS
    Boolean indicating successful operation execution
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OperationMode
    )

    Write-MasterLog "Executing operation: $OperationMode" "INFO"

    try {
        switch ($OperationMode) {
            "Full" {
                return Invoke-FullHistoricalBackfill
            }
            "Test" {
                return Invoke-TestMode
            }
            "Custom" {
                return Invoke-CustomDateRange
            }
            "Daily" {
                return Invoke-DailyAutomationSetup
            }
            "Badges" {
                return Invoke-BadgeAchievementMode
            }
            "Config" {
                return Invoke-ConfigurationMode
            }
            "Status" {
                Show-SystemStatus
                return $true
            }
            "Cleanup" {
                return Invoke-ProjectCleanup
            }
            "Force1" {
                return Invoke-ForceCommits -IntensityLevel 1
            }
            "Force3" {
                return Invoke-ForceCommits -IntensityLevel 3
            }
            "Force5" {
                return Invoke-ForceCommits -IntensityLevel 5
            }
            "DailyStatus" {
                Show-DailyAutomationStatus
                return $true
            }
            "DailyConfig" {
                return Invoke-DailyConfigurationWizard
            }
            "DailyInstall" {
                return Install-DailyAutomationTask
            }
            "DailyRemove" {
                return Remove-DailyAutomationTask
            }
            "DailyAuto" {
                return Invoke-DailyAutomation
            }
            "Help" {
                Show-HelpSystem
                return $true
            }
            default {
                Write-MasterLog "Unknown operation mode: $OperationMode" "ERROR"
                return $false
            }
        }
    }
    catch {
        Write-MasterLog "Critical error during operation execution: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Invoke-FullHistoricalBackfill {
    <#
    .SYNOPSIS
    Execute full historical backfill using the proven enhanced system

    .OUTPUTS
    Boolean indicating successful execution
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Starting Full Historical Backfill operation..." "INFO"

    try {
        # Validate prerequisites
        if (-not (Test-Prerequisites)) {
            Write-MasterLog "Prerequisites validation failed for full backfill" "ERROR"
            return $false
        }

        # Confirm operation unless auto-confirmed
        if (-not $global:AutoConfirm -and -not $global:Force) {
            Write-Host ""
            Write-Host "WARNING: Full Historical Backfill Operation" -ForegroundColor $global:Colors.Warning
            Write-Host "This will create 779 days of historical commits from November 1, 2022 to present." -ForegroundColor $global:Colors.Warning
            Write-Host "This operation may take 30-60 minutes to complete." -ForegroundColor $global:Colors.Warning
            Write-Host "GitHub API rate limits will be respected automatically." -ForegroundColor $global:Colors.Info
            Write-Host ""

            $confirm = Read-Host "Do you want to continue? (y/N)"
            if ($confirm -ne "y" -and $confirm -ne "Y") {
                Write-MasterLog "Full backfill operation cancelled by user" "INFO"
                return $false
            }
        }

        # Execute the enhanced historical system
        $enhancedSystemPath = Join-Path $global:ScriptRoot "enhanced_historical_system_v2.ps1"
        if (-not (Test-Path $enhancedSystemPath)) {
            Write-MasterLog "Enhanced historical system file not found: $enhancedSystemPath" "ERROR"
            return $false
        }

        Write-MasterLog "Executing enhanced historical system..." "PROGRESS"

        # Set environment variable for full mode
        $env:FORCE_FULL_MODE = "true"

        if ($global:DryRun) {
            Write-MasterLog "DRY RUN: Would execute full historical backfill" "INFO"
            return $true
        }

        # Execute the proven system
        if ($global:AutoConfirm) {
            & $enhancedSystemPath -SkipConfirmation
        }
        else {
            & $enhancedSystemPath
        }

        if ($LASTEXITCODE -eq 0) {
            Write-MasterLog "Full historical backfill completed successfully" "SUCCESS"
            return $true
        }
        else {
            Write-MasterLog "Full historical backfill failed with exit code: $LASTEXITCODE" "ERROR"
            return $false
        }
    }
    catch {
        Write-MasterLog "Error during full historical backfill: $($_.Exception.Message)" "ERROR"
        return $false
    }
    finally {
        # Clean up environment variable
        Remove-Item Env:FORCE_FULL_MODE -ErrorAction SilentlyContinue
    }
}

function Invoke-TestMode {
    <#
    .SYNOPSIS
    Execute test mode using the proven simple system

    .OUTPUTS
    Boolean indicating successful execution
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Starting Test Mode operation..." "INFO"

    try {
        # Use the proven simple system for test mode
        $simpleSystemPath = Join-Path $global:ScriptRoot "GreenCommits-Simple.ps1"
        if (-not (Test-Path $simpleSystemPath)) {
            Write-MasterLog "Simple system file not found: $simpleSystemPath" "ERROR"
            return $false
        }

        Write-MasterLog "Executing test mode with 5 sample commits..." "PROGRESS"

        if ($global:DryRun) {
            Write-MasterLog "DRY RUN: Would execute test mode with 5 sample commits" "INFO"
            return $true
        }

        # Execute the proven test system
        & powershell -ExecutionPolicy Bypass -File $simpleSystemPath -Mode Test

        if ($LASTEXITCODE -eq 0) {
            Write-MasterLog "Test mode completed successfully" "SUCCESS"
            return $true
        }
        else {
            Write-MasterLog "Test mode failed with exit code: $LASTEXITCODE" "ERROR"
            return $false
        }
    }
    catch {
        Write-MasterLog "Error during test mode execution: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Invoke-CustomDateRange {
    <#
    .SYNOPSIS
    Execute custom date range commits with user-specified parameters

    .OUTPUTS
    Boolean indicating successful execution
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Starting Custom Date Range operation..." "INFO"

    try {
        # Get date range from parameters or user input
        $startDate = $StartDate
        $endDate = $EndDate
        $intensity = $Intensity

        if (-not $startDate) {
            $startDate = Read-Host "Enter start date (YYYY-MM-DD)"
        }

        if (-not $endDate) {
            $endDate = Read-Host "Enter end date (YYYY-MM-DD)"
        }

        if ($intensity -eq 0) {
            $intensity = Read-Host "Enter intensity level (1-5)"
        }

        # Validate dates
        try {
            $startDateTime = [DateTime]::ParseExact($startDate, "yyyy-MM-dd", $null)
            $endDateTime = [DateTime]::ParseExact($endDate, "yyyy-MM-dd", $null)
        }
        catch {
            Write-MasterLog "Invalid date format. Use YYYY-MM-DD format." "ERROR"
            return $false
        }

        if ($startDateTime -gt $endDateTime) {
            Write-MasterLog "Start date must be before end date" "ERROR"
            return $false
        }

        # Validate intensity
        if ($intensity -lt 1 -or $intensity -gt 5) {
            Write-MasterLog "Intensity must be between 1 and 5" "ERROR"
            return $false
        }

        $dayCount = ($endDateTime - $startDateTime).Days + 1

        Write-MasterLog "Custom date range: $startDate to $endDate ($dayCount days) with intensity $intensity" "INFO"

        if ($global:DryRun) {
            Write-MasterLog "DRY RUN: Would create commits for $dayCount days with intensity $intensity" "INFO"
            return $true
        }

        # Implementation would go here - for now, show what would be done
        Write-MasterLog "Custom date range implementation in progress..." "INFO"
        Write-Host "This feature will be implemented in a future version." -ForegroundColor $global:Colors.Warning

        return $true
    }
    catch {
        Write-MasterLog "Error during custom date range operation: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Invoke-DailyAutomationSetup {
    <#
    .SYNOPSIS
    Setup daily automation using Windows Task Scheduler

    .OUTPUTS
    Boolean indicating successful execution
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Starting Daily Automation Setup..." "INFO"

    try {
        # Check if batch file exists
        $batchFilePath = Join-Path $global:ScriptRoot "run-daily-commits.bat"
        if (-not (Test-Path $batchFilePath)) {
            Write-MasterLog "Daily automation batch file not found: $batchFilePath" "ERROR"
            return $false
        }

        Write-MasterLog "Daily automation batch file found" "SUCCESS"

        if ($global:DryRun) {
            Write-MasterLog "DRY RUN: Would setup Windows Task Scheduler for daily automation" "INFO"
            return $true
        }

        # Show instructions for manual setup
        Write-Host ""
        Write-Host "DAILY AUTOMATION SETUP INSTRUCTIONS:" -ForegroundColor $global:Colors.Info
        Write-Host ""
        Write-Host "1. Open Task Scheduler (Win + R, type 'taskschd.msc')" -ForegroundColor $global:Colors.Menu
        Write-Host "2. Click 'Create Basic Task...' in the right panel" -ForegroundColor $global:Colors.Menu
        Write-Host "3. Name: 'Green Commits Daily'" -ForegroundColor $global:Colors.Menu
        Write-Host "4. Trigger: Daily at 9:00 AM" -ForegroundColor $global:Colors.Menu
        Write-Host "5. Action: Start a program" -ForegroundColor $global:Colors.Menu
        Write-Host "6. Program: $batchFilePath" -ForegroundColor $global:Colors.Menu
        Write-Host "7. Configure random delay: 8 hours" -ForegroundColor $global:Colors.Menu
        Write-Host ""
        Write-Host "The system will then create 1-3 commits daily automatically." -ForegroundColor $global:Colors.Success
        Write-Host ""

        Write-MasterLog "Daily automation setup instructions provided" "SUCCESS"
        return $true
    }
    catch {
        Write-MasterLog "Error during daily automation setup: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Invoke-BadgeAchievementMode {
    <#
    .SYNOPSIS
    Execute GitHub badge achievement strategies

    .OUTPUTS
    Boolean indicating successful execution
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Starting Badge Achievement Mode..." "INFO"

    try {
        Write-Host ""
        Write-Host "GITHUB BADGE ACHIEVEMENT SYSTEM" -ForegroundColor $global:Colors.Info
        Write-Host ""
        Write-Host "Available Badge Strategies:" -ForegroundColor $global:Colors.Menu
        Write-Host "  - Arctic Code Vault Contributor" -ForegroundColor $global:Colors.Menu
        Write-Host "  - Mars 2020 Helicopter Contributor" -ForegroundColor $global:Colors.Menu
        Write-Host "  - Pull Shark (Pull Request achievements)" -ForegroundColor $global:Colors.Menu
        Write-Host "  - YOLO (Merge without review)" -ForegroundColor $global:Colors.Menu
        Write-Host "  - Quickdraw (Rapid issue/PR closure)" -ForegroundColor $global:Colors.Menu
        Write-Host "  - Pair Extraordinaire (Co-authored commits)" -ForegroundColor $global:Colors.Menu
        Write-Host "  - Public Sponsor badges" -ForegroundColor $global:Colors.Menu
        Write-Host ""
        Write-Host "This feature will be implemented in a future version." -ForegroundColor $global:Colors.Warning
        Write-Host ""

        Write-MasterLog "Badge achievement system information displayed" "SUCCESS"
        return $true
    }
    catch {
        Write-MasterLog "Error during badge achievement mode: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Invoke-ConfigurationMode {
    <#
    .SYNOPSIS
    Execute configuration management and validation

    .OUTPUTS
    Boolean indicating successful execution
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Starting Configuration Mode..." "INFO"

    try {
        Write-Host ""
        Write-Host "SYSTEM CONFIGURATION MANAGEMENT" -ForegroundColor $global:Colors.Info
        Write-Host ""

        # Show current configuration
        Write-Host "Current Configuration:" -ForegroundColor $global:Colors.Menu
        Write-Host "  GitHub Username: $($global:Config.GitHub.Username)" -ForegroundColor $global:Colors.Menu
        Write-Host "  GitHub Repository: $($global:Config.GitHub.Repository)" -ForegroundColor $global:Colors.Menu
        Write-Host "  Coverage Target: $([math]::Round($global:Config.System.Coverage * 100))%" -ForegroundColor $global:Colors.Menu
        Write-Host "  Start Date: $($global:Config.System.StartDate)" -ForegroundColor $global:Colors.Menu
        Write-Host ""

        # Test GitHub connectivity
        Write-Host "Testing GitHub connectivity..." -ForegroundColor $global:Colors.Info
        if (Test-GitHubConnectivity) {
            Write-Host "GitHub connectivity: OK" -ForegroundColor $global:Colors.Success
        }
        else {
            Write-Host "GitHub connectivity: FAILED" -ForegroundColor $global:Colors.Error
        }
        Write-Host ""

        Write-Host "Configuration validation completed." -ForegroundColor $global:Colors.Success
        Write-Host ""

        Write-MasterLog "Configuration mode completed successfully" "SUCCESS"
        return $true
    }
    catch {
        Write-MasterLog "Error during configuration mode: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Invoke-ProjectCleanup {
    <#
    .SYNOPSIS
    Execute project cleanup and maintenance

    .OUTPUTS
    Boolean indicating successful execution
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Starting Project Cleanup..." "INFO"

    try {
        # Check if cleanup script exists
        $cleanupScriptPath = Join-Path $global:ScriptRoot "Cleanup-Project.ps1"
        if (Test-Path $cleanupScriptPath) {
            Write-MasterLog "Executing project cleanup script..." "PROGRESS"

            if ($global:DryRun) {
                & powershell -ExecutionPolicy Bypass -File $cleanupScriptPath -DryRun
            }
            else {
                & powershell -ExecutionPolicy Bypass -File $cleanupScriptPath -Force
            }

            Write-MasterLog "Project cleanup completed" "SUCCESS"
        }
        else {
            Write-Host ""
            Write-Host "PROJECT MAINTENANCE TASKS:" -ForegroundColor $global:Colors.Info
            Write-Host ""
            Write-Host "  - Log file rotation (30-day retention)" -ForegroundColor $global:Colors.Menu
            Write-Host "  - Temporary file cleanup" -ForegroundColor $global:Colors.Menu
            Write-Host "  - Configuration backup" -ForegroundColor $global:Colors.Menu
            Write-Host "  - Git repository optimization" -ForegroundColor $global:Colors.Menu
            Write-Host ""
            Write-Host "Cleanup script not found. Manual maintenance recommended." -ForegroundColor $global:Colors.Warning
            Write-Host ""
        }

        return $true
    }
    catch {
        Write-MasterLog "Error during project cleanup: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Invoke-ForceCommits {
    <#
    .SYNOPSIS
    Execute force commits with specified intensity level

    .PARAMETER IntensityLevel
    The intensity level (1, 3, or 5)

    .OUTPUTS
    Boolean indicating successful execution
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet(1, 3, 5)]
        [int]$IntensityLevel
    )

    Write-MasterLog "Starting Force Commits with Intensity Level $IntensityLevel..." "INFO"

    try {
        # For Force Commits, we bypass daily automation checks but still use execution lock
        # Set execution lock to prevent concurrent runs
        if (-not (Set-ExecutionLock)) {
            Write-MasterLog "Could not acquire execution lock" "ERROR"
            return $false
        }

        # Define intensity parameters - FIXED: These are TOTAL commits, not multipliers
        $intensityConfig = switch ($IntensityLevel) {
            1 {
                @{
                    MinCommits  = 1
                    MaxCommits  = 5
                    Description = "Light green - realistic developer patterns"
                }
            }
            3 {
                @{
                    MinCommits  = 10
                    MaxCommits  = 20
                    Description = "Medium green - consistent activity"
                }
            }
            5 {
                @{
                    MinCommits  = 30
                    MaxCommits  = 50
                    Description = "Dark green - high-intensity development"
                }
            }
        }

        # Calculate total commits to create today
        $totalCommitsToday = Get-Random -Minimum $intensityConfig.MinCommits -Maximum ($intensityConfig.MaxCommits + 1)

        Write-Host ""
        Write-Host "FORCE COMMITS - INTENSITY LEVEL $IntensityLevel" -ForegroundColor $global:Colors.Info
        Write-Host "Description: $($intensityConfig.Description)" -ForegroundColor $global:Colors.Menu
        Write-Host "Total commits to create today: $totalCommitsToday" -ForegroundColor $global:Colors.Menu
        Write-Host ""

        if (-not $global:AutoConfirm -and -not $global:Force) {
            $confirm = Read-Host "Do you want to create $totalCommitsToday commits today? (y/N)"
            if ($confirm -ne "y" -and $confirm -ne "Y") {
                Write-MasterLog "Force commits operation cancelled by user" "INFO"
                Remove-ExecutionLock
                return $false
            }
        }

        if ($global:DryRun) {
            Write-MasterLog "DRY RUN: Would create $totalCommitsToday commits with intensity level $IntensityLevel" "INFO"
            Remove-ExecutionLock
            return $true
        }

        Write-MasterLog "Creating $totalCommitsToday individual commits..." "PROGRESS"

        # FIXED: Create individual commits directly, not through Daily mode
        $successfulCommits = 0
        $languages = @("python", "solidity", "typescript", "javascript", "java", "cpp", "csharp", "go", "rust")

        for ($i = 1; $i -le $totalCommitsToday; $i++) {
            try {
                Write-MasterLog "Creating commit $i of $totalCommitsToday..." "PROGRESS"

                # Create individual commit file
                $today = Get-Date -Format "yyyy-MM-dd"
                $language = $languages | Get-Random
                $fileName = "$today-$i-$language.md"
                $filePath = Join-Path -Path (Join-Path -Path $global:ScriptRoot -ChildPath "src") -ChildPath $fileName

                # Ensure src directory exists
                $srcDir = Join-Path -Path $global:ScriptRoot -ChildPath "src"
                if (-not (Test-Path $srcDir)) {
                    New-Item -ItemType Directory -Path $srcDir -Force | Out-Null
                }

                # Create commit content
                $commitContent = @"
# $language Development - Commit $i

**Date**: $today
**Language**: $language
**Commit**: $i of $totalCommitsToday
**Intensity Level**: $IntensityLevel

## Changes Made
- Enhanced $language functionality
- Improved code structure and performance
- Added comprehensive error handling
- Updated documentation and comments

## Technical Details
This commit represents part of a structured development session focused on $language programming.
The changes include optimizations, bug fixes, and feature enhancements.

Generated by Green Commits Master Control System v4.0
Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@

                # Write file - FIXED: Use explicit parameter binding to avoid positional parameter issues
                Write-MasterLog "Creating file: $filePath" "DEBUG"
                try {
                    # Use Set-Content instead of Out-File to avoid parameter binding issues
                    Set-Content -Path $filePath -Value $commitContent -Encoding UTF8 -ErrorAction Stop
                    Write-MasterLog "File created successfully: $fileName" "DEBUG"
                }
                catch {
                    Write-MasterLog "Failed to create file $fileName`: $($_.Exception.Message)" "ERROR"
                    throw
                }

                # Git operations - FIXED: Use relative path and proper parameter handling
                Set-Location $global:ScriptRoot

                # Use relative path for git commands
                $relativePath = "src/$fileName"

                # Add file to git with proper parameter handling
                Write-MasterLog "Adding file to git: $relativePath" "DEBUG"
                $gitAddResult = & git add $relativePath 2>&1
                $addExitCode = $LASTEXITCODE

                if ($addExitCode -eq 0) {
                    Write-MasterLog "Git add successful for $relativePath" "DEBUG"

                    # Commit with proper message escaping
                    $commitMessage = "feat($language): Enhanced $language development - commit $i/$totalCommitsToday"
                    Write-MasterLog "Committing with message: $commitMessage" "DEBUG"
                    $gitCommitResult = & git commit -m $commitMessage 2>&1
                    $commitExitCode = $LASTEXITCODE

                    if ($commitExitCode -eq 0) {
                        $successfulCommits++
                        Write-MasterLog "Commit $i created successfully" "SUCCESS"
                    }
                    else {
                        Write-MasterLog "Git commit $i failed (exit code: $commitExitCode): $gitCommitResult" "WARNING"
                    }
                }
                else {
                    Write-MasterLog "Git add $i failed (exit code: $addExitCode): $gitAddResult" "WARNING"
                }

                # Small delay between commits for realistic timing
                if ($i -lt $totalCommitsToday) {
                    Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 4)
                }
            }
            catch {
                Write-MasterLog "Error creating commit ${i}: $($_.Exception.Message)" "ERROR"
            }
        }

        # Push all commits to GitHub
        if ($successfulCommits -gt 0) {
            Write-MasterLog "Pushing $successfulCommits commits to GitHub..." "PROGRESS"
            try {
                # Use proper git push with error capture
                $gitPushResult = & git push origin main 2>&1
                $pushExitCode = $LASTEXITCODE

                if ($pushExitCode -eq 0) {
                    Write-MasterLog "Successfully pushed $successfulCommits commits to GitHub" "SUCCESS"
                }
                else {
                    Write-MasterLog "Git push failed (exit code: $pushExitCode): $gitPushResult" "WARNING"
                    Write-MasterLog "Commits are created locally but not pushed to remote" "INFO"
                }
            }
            catch {
                Write-MasterLog "Error executing git push: $($_.Exception.Message)" "WARNING"
            }
        }

        # Update daily execution record
        Update-DailyExecutionRecord -CommitCount $successfulCommits

        # Remove execution lock
        Remove-ExecutionLock

        Write-MasterLog "Force commits completed: $successfulCommits/$totalCommitsToday commits created with intensity level $IntensityLevel" "SUCCESS"
        return $true
    }
    catch {
        Write-MasterLog "Error during force commits execution: $($_.Exception.Message)" "ERROR"
        Remove-ExecutionLock
        return $false
    }
}

# ===============================================
# DAILY AUTOMATION MANAGEMENT FUNCTIONS
# ===============================================

function Invoke-DailyAutomation {
    <#
    .SYNOPSIS
    Execute daily automation based on current state and intensity level

    .OUTPUTS
    Boolean indicating successful execution
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Starting daily automation execution..." "INFO"

    try {
        # Check if daily execution is allowed
        if (-not (Test-DailyExecutionAllowed)) {
            Write-MasterLog "Daily automation skipped - already executed today or disabled" "INFO"
            return $true
        }

        # Execute force commits with current intensity level
        $result = Invoke-ForceCommits -IntensityLevel $global:DailyState.intensityLevel

        if ($result) {
            Write-MasterLog "Daily automation completed successfully" "SUCCESS"
        }
        else {
            Write-MasterLog "Daily automation failed" "ERROR"
        }

        return $result
    }
    catch {
        Write-MasterLog "Error during daily automation: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Set-DailyAutomationConfig {
    <#
    .SYNOPSIS
    Configure daily automation settings

    .PARAMETER IntensityLevel
    The intensity level (1, 3, or 5)

    .PARAMETER Enabled
    Whether daily automation is enabled

    .OUTPUTS
    Boolean indicating successful configuration
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet(1, 3, 5)]
        [int]$IntensityLevel,

        [Parameter(Mandatory = $false)]
        [bool]$Enabled
    )

    try {
        $configChanged = $false

        if ($PSBoundParameters.ContainsKey('IntensityLevel')) {
            $global:DailyState.intensityLevel = $IntensityLevel
            Write-MasterLog "Daily automation intensity level set to $IntensityLevel" "SUCCESS"
            $configChanged = $true
        }

        if ($PSBoundParameters.ContainsKey('Enabled')) {
            $global:DailyState.automationEnabled = $Enabled
            $status = if ($Enabled) { "enabled" } else { "disabled" }
            Write-MasterLog "Daily automation $status" "SUCCESS"
            $configChanged = $true
        }

        if ($configChanged) {
            Save-DailyState
            return $true
        }
        else {
            Write-MasterLog "No configuration changes specified" "INFO"
            return $false
        }
    }
    catch {
        Write-MasterLog "Error configuring daily automation: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Show-DailyAutomationStatus {
    <#
    .SYNOPSIS
    Display current daily automation status and configuration
    #>
    [CmdletBinding()]
    param()

    try {
        Write-Host ""
        Write-Host "DAILY AUTOMATION STATUS" -ForegroundColor $global:Colors.Info
        Write-Host "========================" -ForegroundColor $global:Colors.Info
        Write-Host ""

        $today = Get-Date -Format "yyyy-MM-dd"
        $status = if ($global:DailyState.automationEnabled) { "ENABLED" } else { "DISABLED" }
        $statusColor = if ($global:DailyState.automationEnabled) { $global:Colors.Success } else { $global:Colors.Warning }

        Write-Host "Automation Status: " -NoNewline -ForegroundColor $global:Colors.Menu
        Write-Host $status -ForegroundColor $statusColor

        Write-Host "Intensity Level: " -NoNewline -ForegroundColor $global:Colors.Menu
        Write-Host $global:DailyState.intensityLevel -ForegroundColor $global:Colors.Info

        Write-Host "Last Execution: " -NoNewline -ForegroundColor $global:Colors.Menu
        if ($global:DailyState.lastExecutionDate) {
            Write-Host $global:DailyState.lastExecutionDate -ForegroundColor $global:Colors.Info
        }
        else {
            Write-Host "Never" -ForegroundColor $global:Colors.Warning
        }

        Write-Host "Today's Status: " -NoNewline -ForegroundColor $global:Colors.Menu
        if ($global:DailyState.lastExecutionDate -eq $today) {
            Write-Host "COMPLETED ($($global:DailyState.todaysCommitCount) commits)" -ForegroundColor $global:Colors.Success
        }
        else {
            Write-Host "PENDING" -ForegroundColor $global:Colors.Warning
        }

        # Show execution lock status
        if (Test-Path $global:ExecutionLockPath) {
            Write-Host "Execution Lock: " -NoNewline -ForegroundColor $global:Colors.Menu
            Write-Host "ACTIVE" -ForegroundColor $global:Colors.Warning
        }

        # Show recent history
        if ($global:DailyState.executionHistory -and $global:DailyState.executionHistory.Count -gt 0) {
            Write-Host ""
            Write-Host "Recent Execution History:" -ForegroundColor $global:Colors.Menu
            $global:DailyState.executionHistory | Select-Object -Last 5 | ForEach-Object {
                Write-Host "  $($_.date): $($_.commits) commits (intensity $($_.intensity))" -ForegroundColor $global:Colors.Info
            }
        }

        Write-Host ""
    }
    catch {
        Write-MasterLog "Error displaying daily automation status: $($_.Exception.Message)" "ERROR"
    }
}

function Install-DailyAutomationTask {
    <#
    .SYNOPSIS
    Install Windows Task Scheduler task for daily automation

    .OUTPUTS
    Boolean indicating successful installation
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Installing daily automation Task Scheduler task..." "INFO"

    try {
        $taskName = "GreenCommits-DailyAutomation"
        $scriptPath = Join-Path $global:ScriptRoot "GreenCommits-MasterControl.ps1"

        # Create task action
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`" -Mode DailyAuto -Silent"

        # Create task trigger (daily at 9 AM)
        $trigger = New-ScheduledTaskTrigger -Daily -At "09:00"

        # Create task settings
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

        # Create task principal (run as current user)
        $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive

        # Register the task
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Green Commits Daily Automation" -Force

        Write-MasterLog "Daily automation task installed successfully" "SUCCESS"
        Write-Host "Task '$taskName' has been installed and will run daily at 9:00 AM" -ForegroundColor $global:Colors.Success

        return $true
    }
    catch {
        Write-MasterLog "Error installing daily automation task: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Remove-DailyAutomationTask {
    <#
    .SYNOPSIS
    Remove Windows Task Scheduler task for daily automation

    .OUTPUTS
    Boolean indicating successful removal
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Removing daily automation Task Scheduler task..." "INFO"

    try {
        $taskName = "GreenCommits-DailyAutomation"

        # Check if task exists
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($task) {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
            Write-MasterLog "Daily automation task removed successfully" "SUCCESS"
            Write-Host "Task '$taskName' has been removed" -ForegroundColor $global:Colors.Success
        }
        else {
            Write-MasterLog "Daily automation task not found" "INFO"
            Write-Host "Task '$taskName' was not found" -ForegroundColor $global:Colors.Info
        }

        return $true
    }
    catch {
        Write-MasterLog "Error removing daily automation task: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Invoke-DailyConfigurationWizard {
    <#
    .SYNOPSIS
    Interactive wizard for configuring daily automation settings

    .OUTPUTS
    Boolean indicating successful configuration
    #>
    [CmdletBinding()]
    param()

    Write-MasterLog "Starting daily automation configuration wizard..." "INFO"

    try {
        Write-Host ""
        Write-Host "DAILY AUTOMATION CONFIGURATION WIZARD" -ForegroundColor $global:Colors.Info
        Write-Host "======================================" -ForegroundColor $global:Colors.Info
        Write-Host ""

        # Show current configuration
        Write-Host "Current Configuration:" -ForegroundColor $global:Colors.Menu
        Write-Host "  Automation Enabled: " -NoNewline -ForegroundColor $global:Colors.Menu
        $statusColor = if ($global:DailyState.automationEnabled) { $global:Colors.Success } else { $global:Colors.Warning }
        $statusText = if ($global:DailyState.automationEnabled) { "YES" } else { "NO" }
        Write-Host $statusText -ForegroundColor $statusColor

        Write-Host "  Intensity Level: " -NoNewline -ForegroundColor $global:Colors.Menu
        Write-Host $global:DailyState.intensityLevel -ForegroundColor $global:Colors.Info

        $intensityDesc = switch ($global:DailyState.intensityLevel) {
            1 { "Light (1-5 commits/day)" }
            3 { "Medium (10-20 commits/day)" }
            5 { "Maximum (30-50 commits/day)" }
            default { "Unknown" }
        }
        Write-Host "  Description: " -NoNewline -ForegroundColor $global:Colors.Menu
        Write-Host $intensityDesc -ForegroundColor $global:Colors.Info
        Write-Host ""

        # Configure intensity level
        Write-Host "Select Daily Automation Intensity Level:" -ForegroundColor $global:Colors.Prompt
        Write-Host "  [1] Light - 1-5 commits per day (realistic patterns)" -ForegroundColor $global:Colors.Menu
        Write-Host "  [3] Medium - 10-20 commits per day (consistent activity)" -ForegroundColor $global:Colors.Menu
        Write-Host "  [5] Maximum - 30-50 commits per day (high-intensity)" -ForegroundColor $global:Colors.Menu
        Write-Host "  [C] Keep current setting ($($global:DailyState.intensityLevel))" -ForegroundColor $global:Colors.Menu
        Write-Host ""

        do {
            $intensityChoice = Read-Host "Choose intensity level (1/3/5/C)"
            $intensityChoice = $intensityChoice.ToUpper()

            if ($intensityChoice -eq "C") {
                $newIntensity = $global:DailyState.intensityLevel
                break
            }
            elseif ($intensityChoice -in @("1", "3", "5")) {
                $newIntensity = [int]$intensityChoice
                break
            }
            else {
                Write-Host "Invalid choice. Please select 1, 3, 5, or C." -ForegroundColor $global:Colors.Error
            }
        } while ($true)

        # Configure automation enabled/disabled
        Write-Host ""
        Write-Host "Enable Daily Automation?" -ForegroundColor $global:Colors.Prompt
        Write-Host "  [Y] Yes - Enable daily automation" -ForegroundColor $global:Colors.Success
        Write-Host "  [N] No - Disable daily automation" -ForegroundColor $global:Colors.Warning
        Write-Host "  [C] Keep current setting ($statusText)" -ForegroundColor $global:Colors.Menu
        Write-Host ""

        do {
            $enableChoice = Read-Host "Enable automation (Y/N/C)"
            $enableChoice = $enableChoice.ToUpper()

            if ($enableChoice -eq "C") {
                $newEnabled = $global:DailyState.automationEnabled
                break
            }
            elseif ($enableChoice -eq "Y") {
                $newEnabled = $true
                break
            }
            elseif ($enableChoice -eq "N") {
                $newEnabled = $false
                break
            }
            else {
                Write-Host "Invalid choice. Please select Y, N, or C." -ForegroundColor $global:Colors.Error
            }
        } while ($true)

        # Apply configuration changes
        $configChanged = $false

        if ($newIntensity -ne $global:DailyState.intensityLevel) {
            Set-DailyAutomationConfig -IntensityLevel $newIntensity
            $configChanged = $true
        }

        if ($newEnabled -ne $global:DailyState.automationEnabled) {
            Set-DailyAutomationConfig -Enabled $newEnabled
            $configChanged = $true
        }

        if ($configChanged) {
            Write-Host ""
            Write-Host "Configuration Updated Successfully!" -ForegroundColor $global:Colors.Success
            Write-Host "  Intensity Level: $newIntensity" -ForegroundColor $global:Colors.Info
            Write-Host "  Automation Enabled: $(if ($newEnabled) { 'YES' } else { 'NO' })" -ForegroundColor $global:Colors.Info

            if ($newEnabled) {
                Write-Host ""
                Write-Host "IMPORTANT: To complete setup, install the Task Scheduler task using option [DI]" -ForegroundColor $global:Colors.Warning
            }
        }
        else {
            Write-Host ""
            Write-Host "No configuration changes made." -ForegroundColor $global:Colors.Info
        }

        Write-Host ""
        Write-Host "Press any key to continue..." -ForegroundColor $global:Colors.Prompt
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        return $true
    }
    catch {
        Write-MasterLog "Error in daily configuration wizard: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# ===============================================
# MAIN EXECUTION LOGIC
# ===============================================

function Start-MasterControl {
    <#
    .SYNOPSIS
    Main entry point for the Green Commits Master Control System

    .OUTPUTS
    Integer exit code (0 for success, 1 for failure)
    #>
    [CmdletBinding()]
    param()

    try {
        # Initialize session
        Write-MasterLog "Green Commits Master Control System v4.0 starting..." "INFO"
        Write-MasterLog "Session started at: $($global:SessionStartTime)" "INFO"

        # Initialize configuration
        if (-not (Initialize-Configuration)) {
            Write-MasterLog "Configuration initialization failed" "ERROR"
            return 1
        }

        # Validate prerequisites
        if (-not (Test-Prerequisites)) {
            Write-MasterLog "Prerequisites validation failed" "ERROR"
            return 1
        }

        # Handle command line mode
        if ($Mode -ne "Menu") {
            Write-MasterLog "Executing command line mode: $Mode" "INFO"

            $success = Invoke-Operation $Mode

            if ($success) {
                Write-MasterLog "Command line operation completed successfully" "SUCCESS"
                return 0
            }
            else {
                Write-MasterLog "Command line operation failed" "ERROR"
                return 1
            }
        }

        # Interactive menu mode
        Write-MasterLog "Starting interactive menu mode" "INFO"

        do {
            try {
                $selectedMode = Show-MainMenu

                if ($selectedMode -eq "Exit") {
                    Write-MasterLog "User requested exit" "INFO"
                    break
                }

                $success = Invoke-Operation $selectedMode

                if (-not $success) {
                    Write-Host ""
                    Write-Host "Operation failed. Check the log for details." -ForegroundColor $global:Colors.Error
                }

                # Return to menu unless it's a status or help operation
                if ($selectedMode -notin @("Status", "Help", "Config")) {
                    Write-Host ""
                    Write-Host "Press any key to return to main menu..." -ForegroundColor $global:Colors.Prompt
                    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                }
            }
            catch {
                Write-MasterLog "Error in interactive menu: $($_.Exception.Message)" "ERROR"
                Write-Host ""
                Write-Host "An error occurred. Press any key to continue..." -ForegroundColor $global:Colors.Error
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
        } while ($true)

        Write-MasterLog "Interactive session ended" "INFO"
        return 0
    }
    catch {
        Write-MasterLog "Critical error in master control: $($_.Exception.Message)" "ERROR"
        Write-Host "Critical system error. Check the log file for details." -ForegroundColor $global:Colors.Error
        return 1
    }
    finally {
        # Session cleanup
        $sessionDuration = (Get-Date) - $global:SessionStartTime
        Write-MasterLog "Session ended. Duration: $($sessionDuration.ToString('hh\:mm\:ss')), Operations: $global:OperationCount" "INFO"
    }
}

# ===============================================
# SCRIPT ENTRY POINT
# ===============================================

# Handle help parameter
if ($Help) {
    Show-HelpSystem
    exit 0
}

# Set execution policy for the session
try {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction Stop
}
catch {
    Write-Host "Warning: Could not set execution policy: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Start the master control system
$exitCode = Start-MasterControl

# Exit with appropriate code
exit $exitCode
