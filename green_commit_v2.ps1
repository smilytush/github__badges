# Path to the repository
$repoPath = "J:\green-commits"
Set-Location $repoPath

# Path to schedule file
$scheduleFile = "$repoPath\commit_schedule.txt"

# Path to log file
$logFile = "$repoPath\script_log.txt"

# Path to last run file
$lastRunFile = "$repoPath\last_run.txt"

# Path to code snippets directory
$snippetsDir = "$repoPath\snippets"

# Create snippets directory if it doesn't exist
if (-not (Test-Path $snippetsDir)) {
    New-Item -ItemType Directory -Path $snippetsDir | Out-Null
    Write-Host "Created snippets directory"
}

# Function to log messages
function Write-Log {
    param(
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] $Message" | Out-File -Append -Encoding utf8 $logFile
    Write-Host $Message
}

# Function to update code snippets with random changes
function Update-CodeSnippets {
    # Create Python snippet if it doesn't exist or update it
    $pythonFile = "$snippetsDir\example.py"
    if (-not (Test-Path $pythonFile)) {
        @"
# Simple Python example
class DataProcessor:
    def __init__(self, data):
        self.data = data
        self.processed = False
    
    def process(self):
        # Process the data
        result = [x * 2 for x in self.data if x > 0]
        self.processed = True
        return result

def main():
    # Sample data
    data = [1, 5, -3, 10, 8, 0, -5]
    processor = DataProcessor(data)
    result = processor.process()
    print(f"Processed data: {result}")

if __name__ == "__main__":
    main()
"@ | Out-File -FilePath $pythonFile -Encoding utf8
    } else {
        # Add a comment with timestamp
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "# Updated on $timestamp - Session: $runSession" | Out-File -Append -FilePath $pythonFile -Encoding utf8
    }

    # Create Solidity snippet if it doesn't exist or update it
    $solidityFile = "$snippetsDir\SimpleContract.sol"
    if (-not (Test-Path $solidityFile)) {
        @"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    uint256 private value;
    address public owner;
    
    event ValueChanged(uint256 newValue);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }
    
    function setValue(uint256 _value) public onlyOwner {
        value = _value;
        emit ValueChanged(_value);
    }
    
    function getValue() public view returns (uint256) {
        return value;
    }
}
"@ | Out-File -FilePath $solidityFile -Encoding utf8
    } else {
        # Add a comment with timestamp
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "// Updated on $timestamp - Session: $runSession" | Out-File -Append -FilePath $solidityFile -Encoding utf8
    }

    # Create TypeScript snippet if it doesn't exist or update it
    $typescriptFile = "$snippetsDir\app.ts"
    if (-not (Test-Path $typescriptFile)) {
        @"
interface User {
    id: number;
    name: string;
    email: string;
    isActive: boolean;
}

class UserManager {
    private users: User[] = [];
    
    constructor(initialUsers: User[] = []) {
        this.users = initialUsers;
    }
    
    addUser(user: User): void {
        this.users.push(user);
        console.log(`User ${user.name} added successfully`);
    }
    
    getActiveUsers(): User[] {
        return this.users.filter(user => user.isActive);
    }
    
    getUserById(id: number): User | undefined {
        return this.users.find(user => user.id === id);
    }
}

// Example usage
const manager = new UserManager();
manager.addUser({ id: 1, name: 'John Doe', email: 'john@example.com', isActive: true });
const activeUsers = manager.getActiveUsers();
console.log(activeUsers);
"@ | Out-File -FilePath $typescriptFile -Encoding utf8
    } else {
        # Add a comment with timestamp
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "// Updated on $timestamp - Session: $runSession" | Out-File -Append -FilePath $typescriptFile -Encoding utf8
    }
    
    Write-Log "Updated code snippets in Python, Solidity, and TypeScript"
}

# Generate 280 random commit days if not already created
if (-not (Test-Path $scheduleFile)) {
    $today = Get-Date
    $daysToPick = 280
    $totalDays = 365

    $dates = 1..$totalDays | ForEach-Object { $today.AddDays($_).ToString("yyyy-MM-dd") }
    $selectedDates = $dates | Get-Random -Count $daysToPick
    $selectedDates | Sort-Object | Set-Content $scheduleFile
    Write-Log "Created commit schedule with $daysToPick days"
}

# Get today's date
$todayStr = (Get-Date).ToString("yyyy-MM-dd")

# Check if script has already run in this session
$currentHour = (Get-Date).Hour
$runSession = if ($currentHour -lt 12) { "morning" } else { "afternoon" }

$hasRunThisSession = $false
if (Test-Path $lastRunFile) {
    $lastRun = Get-Content $lastRunFile
    $lastRunParts = $lastRun -split "::"
    
    if ($lastRunParts.Count -eq 2) {
        $lastRunDate = $lastRunParts[0]
        $lastRunSession = $lastRunParts[1]
        
        if ($lastRunDate -eq $todayStr -and $lastRunSession -eq $runSession) {
            $hasRunThisSession = $true
            Write-Log "Script has already run in the $runSession session today. Skipping execution."
        }
    }
}

# If script hasn't run in this session, proceed with checks
if (-not $hasRunThisSession) {
    # Check if today is in the selected commit dates
    $commitDays = Get-Content $scheduleFile
    if ($commitDays -contains $todayStr) {
        Write-Log "Today ($todayStr) is a commit day. Making a commit for $runSession session..."

        try {
            # Get current branch name
            $currentBranch = (git rev-parse --abbrev-ref HEAD) 2>&1
            if ($LASTEXITCODE -ne 0) {
                $currentBranch = "main" # Default to main if command fails
            }
            Write-Log "Current branch: $currentBranch"
            
            # Pull latest changes first
            git pull origin $currentBranch
            Write-Log "Pulled latest changes from remote"
            
            # Update code snippets with random changes
            Update-CodeSnippets
            
            # Create or update the activity log
            "Update ($runSession): $(Get-Date)" | Out-File -Append -Encoding utf8 "$repoPath\activity.log"

            # Configure git user (already done globally, but included for completeness)
            git config user.name "smilytush"
            git config user.email "tushar161@hotmail.com"

            # Commit and push
            git add .
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to stage files"
            }
            
            git commit -m "Auto commit on $todayStr ($runSession session)"
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to commit changes"
            }
            
            # Check if remote exists
            $remoteExists = git remote | Where-Object { $_ -eq "origin" }
            if (-not $remoteExists) {
                Write-Log "Remote 'origin' not found. Skipping push."
            }
            else {
                git push origin $currentBranch
                if ($LASTEXITCODE -ne 0) {
                    throw "Failed to push to remote"
                }
                Write-Log "Commit successfully made and pushed to $currentBranch!"
                
                # Record that the script has run in this session
                "$todayStr::$runSession" | Out-File -FilePath $lastRunFile -Encoding utf8 -Force
            }
        }
        catch {
            Write-Log "Error: $_"
        }
    }
    else {
        Write-Log "Today ($todayStr) is not scheduled for a commit."
        
        # Record that the script has run in this session even if no commit was made
        "$todayStr::$runSession" | Out-File -FilePath $lastRunFile -Encoding utf8 -Force
    }
}
