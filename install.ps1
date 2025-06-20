# ===============================================
# GREEN COMMITS INSTALLATION SCRIPT v3.0
# ===============================================
# First-time setup and installation for Green Commits Master System
# Preserves existing functionality while adding new features
#
# Author: Green Commits Installation System
# ===============================================

param(
    [switch]$Force = $false,
    [switch]$SkipValidation = $false,
    [switch]$Quiet = $false
)

# Set execution policy and error handling
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$ErrorActionPreference = "Stop"

# Installation configuration
$InstallConfig = @{
    ProjectName = "Green Commits Master System"
    Version = "3.0"
    RequiredFiles = @(
        "GreenCommits-Master.ps1",
        "enhanced_historical_system_v2.ps1",
        "config.json"
    )
    OptionalFiles = @(
        "README-Enhanced.md",
        "TaskScheduler-Template.xml"
    )
    Directories = @(
        "logs",
        "backups",
        "temp"
    )
}

# Logging function
function Write-InstallLog {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR", "PROGRESS")]
        [string]$Level = "INFO"
    )
    
    if ($Quiet -and $Level -eq "INFO") { return }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Color mapping
    $colors = @{
        "INFO" = "White"
        "SUCCESS" = "Green"
        "WARNING" = "Yellow"
        "ERROR" = "Red"
        "PROGRESS" = "Cyan"
    }
    
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry -ForegroundColor $colors[$Level]
}

# System requirements check
function Test-InstallationRequirements {
    Write-InstallLog "Checking system requirements..." "PROGRESS"
    
    $issues = @()
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        $issues += "PowerShell 5.0 or higher required (current: $($PSVersionTable.PSVersion))"
    } else {
        Write-InstallLog "PowerShell version: $($PSVersionTable.PSVersion) ✓" "SUCCESS"
    }
    
    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) {
        $issues += "Windows 10 or higher recommended (current: $($osVersion))"
    } else {
        Write-InstallLog "Windows version: $($osVersion) ✓" "SUCCESS"
    }
    
    # Check Git installation
    try {
        $gitVersion = git --version 2>$null
        if ($gitVersion) {
            Write-InstallLog "Git detected: $gitVersion ✓" "SUCCESS"
        } else {
            $issues += "Git is not installed or not in PATH"
        }
    }
    catch {
        $issues += "Git is not installed or not accessible"
    }
    
    # Check internet connectivity
    try {
        $response = Test-NetConnection -ComputerName "github.com" -Port 443 -InformationLevel Quiet
        if ($response) {
            Write-InstallLog "GitHub connectivity confirmed ✓" "SUCCESS"
        } else {
            $issues += "Cannot connect to GitHub"
        }
    }
    catch {
        Write-InstallLog "Network connectivity check failed, but continuing..." "WARNING"
    }
    
    # Check execution policy
    $executionPolicy = Get-ExecutionPolicy
    if ($executionPolicy -eq "Restricted") {
        Write-InstallLog "Execution policy is Restricted. This may cause issues." "WARNING"
        Write-InstallLog "Consider running: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" "INFO"
    } else {
        Write-InstallLog "Execution policy: $executionPolicy ✓" "SUCCESS"
    }
    
    # Check available disk space
    $drive = (Get-Location).Drive
    $freeSpace = (Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$($drive.Name)'").FreeSpace / 1GB
    if ($freeSpace -lt 1) {
        $issues += "Less than 1GB free space available"
    } else {
        Write-InstallLog "Available disk space: $([math]::Round($freeSpace, 2)) GB ✓" "SUCCESS"
    }
    
    if ($issues.Count -gt 0 -and -not $SkipValidation) {
        Write-InstallLog "System requirements check failed:" "ERROR"
        foreach ($issue in $issues) {
            Write-InstallLog "  - $issue" "ERROR"
        }
        Write-InstallLog "Use -SkipValidation to bypass these checks" "INFO"
        return $false
    }
    
    Write-InstallLog "System requirements validation completed" "SUCCESS"
    return $true
}

# File integrity check
function Test-FileIntegrity {
    Write-InstallLog "Checking file integrity..." "PROGRESS"
    
    $missingFiles = @()
    
    foreach ($file in $InstallConfig.RequiredFiles) {
        if (-not (Test-Path $file)) {
            $missingFiles += $file
        } else {
            Write-InstallLog "Found: $file ✓" "SUCCESS"
        }
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-InstallLog "Missing required files:" "ERROR"
        foreach ($file in $missingFiles) {
            Write-InstallLog "  - $file" "ERROR"
        }
        return $false
    }
    
    # Check optional files
    foreach ($file in $InstallConfig.OptionalFiles) {
        if (Test-Path $file) {
            Write-InstallLog "Found optional: $file ✓" "SUCCESS"
        } else {
            Write-InstallLog "Optional file missing: $file" "WARNING"
        }
    }
    
    Write-InstallLog "File integrity check completed" "SUCCESS"
    return $true
}

# Create directory structure
function Initialize-DirectoryStructure {
    Write-InstallLog "Creating directory structure..." "PROGRESS"
    
    foreach ($dir in $InstallConfig.Directories) {
        if (-not (Test-Path $dir)) {
            try {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
                Write-InstallLog "Created directory: $dir ✓" "SUCCESS"
            }
            catch {
                Write-InstallLog "Failed to create directory: $dir - $($_.Exception.Message)" "ERROR"
                return $false
            }
        } else {
            Write-InstallLog "Directory exists: $dir ✓" "SUCCESS"
        }
    }
    
    return $true
}

# Configuration setup
function Initialize-Configuration {
    Write-InstallLog "Initializing configuration..." "PROGRESS"
    
    if (Test-Path "config.json") {
        Write-InstallLog "Configuration file already exists" "INFO"
        
        if (-not $Force) {
            $overwrite = Read-Host "Overwrite existing configuration? (y/n)"
            if ($overwrite.ToLower() -ne "y" -and $overwrite.ToLower() -ne "yes") {
                Write-InstallLog "Keeping existing configuration" "INFO"
                return $true
            }
        }
    }
    
    # Validate JSON configuration
    try {
        $config = Get-Content "config.json" -Raw | ConvertFrom-Json
        Write-InstallLog "Configuration file validated ✓" "SUCCESS"
        
        # Create backup of existing config if it exists
        if (Test-Path "config.json.backup") {
            Remove-Item "config.json.backup" -Force
        }
        Copy-Item "config.json" "config.json.backup" -Force
        Write-InstallLog "Configuration backup created" "INFO"
        
        return $true
    }
    catch {
        Write-InstallLog "Configuration validation failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Git repository setup
function Initialize-GitRepository {
    Write-InstallLog "Initializing Git repository..." "PROGRESS"
    
    if (-not (Test-Path ".git")) {
        try {
            git init
            Write-InstallLog "Git repository initialized ✓" "SUCCESS"
        }
        catch {
            Write-InstallLog "Failed to initialize Git repository: $($_.Exception.Message)" "ERROR"
            return $false
        }
    } else {
        Write-InstallLog "Git repository already exists ✓" "SUCCESS"
    }
    
    # Check if remote exists
    try {
        $remotes = git remote
        if ($remotes -notcontains "origin") {
            # Load configuration to get remote URL
            $config = Get-Content "config.json" -Raw | ConvertFrom-Json
            $remoteUrl = $config.GitHub.RemoteURL
            
            if ($remoteUrl) {
                git remote add origin $remoteUrl
                Write-InstallLog "Git remote 'origin' added ✓" "SUCCESS"
            }
        } else {
            Write-InstallLog "Git remote 'origin' already exists ✓" "SUCCESS"
        }
    }
    catch {
        Write-InstallLog "Git remote setup failed: $($_.Exception.Message)" "WARNING"
    }
    
    return $true
}

# Create desktop shortcut
function New-DesktopShortcut {
    Write-InstallLog "Creating desktop shortcut..." "PROGRESS"
    
    try {
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("$([Environment]::GetFolderPath('Desktop'))\Green Commits Master.lnk")
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$(Join-Path $PWD 'GreenCommits-Master.ps1')`""
        $Shortcut.WorkingDirectory = $PWD
        $Shortcut.IconLocation = "powershell.exe,0"
        $Shortcut.Description = "Green Commits Master Control System"
        $Shortcut.Save()
        
        Write-InstallLog "Desktop shortcut created ✓" "SUCCESS"
        return $true
    }
    catch {
        Write-InstallLog "Failed to create desktop shortcut: $($_.Exception.Message)" "WARNING"
        return $false
    }
}

# Installation summary
function Show-InstallationSummary {
    Write-InstallLog "" "INFO"
    Write-InstallLog "═══════════════════════════════════════════════════════════════" "SUCCESS"
    Write-InstallLog "    GREEN COMMITS MASTER SYSTEM INSTALLATION COMPLETE" "SUCCESS"
    Write-InstallLog "═══════════════════════════════════════════════════════════════" "SUCCESS"
    Write-InstallLog "" "INFO"
    Write-InstallLog "Installation Details:" "INFO"
    Write-InstallLog "  Project: $($InstallConfig.ProjectName)" "INFO"
    Write-InstallLog "  Version: $($InstallConfig.Version)" "INFO"
    Write-InstallLog "  Location: $PWD" "INFO"
    Write-InstallLog "  Configuration: config.json" "INFO"
    Write-InstallLog "" "INFO"
    Write-InstallLog "Next Steps:" "INFO"
    Write-InstallLog "  1. Run: .\GreenCommits-Master.ps1" "INFO"
    Write-InstallLog "  2. Or use the desktop shortcut: 'Green Commits Master'" "INFO"
    Write-InstallLog "  3. Start with option [6] to configure your settings" "INFO"
    Write-InstallLog "  4. Then try option [2] for a test run" "INFO"
    Write-InstallLog "" "INFO"
    Write-InstallLog "For help: .\GreenCommits-Master.ps1 -Help" "INFO"
    Write-InstallLog "" "INFO"
}

# Main installation process
function Start-Installation {
    try {
        Write-InstallLog "Starting $($InstallConfig.ProjectName) v$($InstallConfig.Version) installation..." "INFO"
        Write-InstallLog "Installation directory: $PWD" "INFO"
        Write-InstallLog "" "INFO"
        
        # Step 1: System requirements
        if (-not (Test-InstallationRequirements)) {
            throw "System requirements check failed"
        }
        
        # Step 2: File integrity
        if (-not (Test-FileIntegrity)) {
            throw "File integrity check failed"
        }
        
        # Step 3: Directory structure
        if (-not (Initialize-DirectoryStructure)) {
            throw "Directory structure creation failed"
        }
        
        # Step 4: Configuration
        if (-not (Initialize-Configuration)) {
            throw "Configuration initialization failed"
        }
        
        # Step 5: Git repository
        if (-not (Initialize-GitRepository)) {
            throw "Git repository initialization failed"
        }
        
        # Step 6: Desktop shortcut
        New-DesktopShortcut | Out-Null
        
        # Step 7: Installation summary
        Show-InstallationSummary
        
        Write-InstallLog "Installation completed successfully!" "SUCCESS"
        
    }
    catch {
        Write-InstallLog "Installation failed: $($_.Exception.Message)" "ERROR"
        Write-InstallLog $_.ScriptStackTrace "ERROR"
        exit 1
    }
}

# Welcome message
if (-not $Quiet) {
    Clear-Host
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║           GREEN COMMITS MASTER SYSTEM INSTALLER             ║" -ForegroundColor Magenta
    Write-Host "║                        Version 3.0                          ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "This installer will set up the Green Commits Master System" -ForegroundColor Cyan
    Write-Host "for managing your GitHub contribution graph." -ForegroundColor Cyan
    Write-Host ""
    
    if (-not $Force) {
        $proceed = Read-Host "Proceed with installation? (y/n)"
        if ($proceed.ToLower() -ne "y" -and $proceed.ToLower() -ne "yes") {
            Write-InstallLog "Installation cancelled by user" "INFO"
            exit 0
        }
    }
    
    Write-Host ""
}

# Start installation
Start-Installation
