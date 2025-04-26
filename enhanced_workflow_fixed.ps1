# Enhanced GitHub Workflow Script
# This script handles both simple commits and full GitHub workflow (PRs, issues, code reviews)

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

# Create issues directory if it doesn't exist
$issuesDir = "$repoPath\issues"
if (-not (Test-Path $issuesDir)) {
    New-Item -ItemType Directory -Path $issuesDir | Out-Null
    Write-Host "Created issues directory"
}

# Create pull-requests directory if it doesn't exist
$prDir = "$repoPath\pull-requests"
if (-not (Test-Path $prDir)) {
    New-Item -ItemType Directory -Path $prDir | Out-Null
    Write-Host "Created pull-requests directory"
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

# Function to create a new branch with changes
function Create-Branch {
    param(
        [string]$BranchName
    )
    
    # Create and checkout a new branch
    git checkout -b $BranchName
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create branch $BranchName"
    }
    
    Write-Log "Created and checked out branch: $BranchName"
}

# Function to create an issue
function Create-Issue {
    param(
        [string]$Title,
        [string]$Body
    )
    
    $issueId = Get-Random -Minimum 100 -Maximum 999
    $timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
    $issueFile = "$issuesDir\issue-$issueId-$timestamp.md"
    
    @"
# Issue: $Title

**Created:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Status:** Open
**ID:** $issueId

## Description

$Body

## Tasks

- [ ] Implement solution
- [ ] Test changes
- [ ] Review code
- [ ] Merge changes
"@ | Out-File -FilePath $issueFile -Encoding utf8
    
    Write-Log "Created issue #$issueId - $Title"
    return $issueId
}

# Function to create a pull request
function Create-PullRequest {
    param(
        [string]$Title,
        [string]$Body,
        [string]$BranchName,
        [int]$IssueId
    )
    
    $prId = Get-Random -Minimum 100 -Maximum 999
    $timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
    $prFile = "$prDir\pr-$prId-$timestamp.md"
    
    @"
# Pull Request: $Title

**Created:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Status:** Open
**PR ID:** $prId
**Branch:** $BranchName
**Related Issue:** #$IssueId

## Description

$Body

## Changes

- Modified code snippets
- Updated documentation
- Fixed issues

## Review Status

- [ ] Code review completed
- [ ] Tests passing
- [ ] Ready to merge
"@ | Out-File -FilePath $prFile -Encoding utf8
    
    Write-Log "Created pull request #$prId - $Title"
    return $prId
}

# Function to perform a code review
function Perform-CodeReview {
    param(
        [int]$PrId,
        [string]$Reviewer,
        [string]$Comments
    )
    
    # Find the PR file
    $prFiles = Get-ChildItem -Path $prDir -Filter "pr-$PrId-*.md" -ErrorAction SilentlyContinue
    
    if ($prFiles.Count -eq 0) {
        Write-Log "Pull request #$PrId not found"
        return
    }
    
    $prFile = $prFiles[0].FullName
    $prContent = Get-Content -Path $prFile -Raw
    
    # Add review comments
    $reviewSection = @"

## Code Review by $Reviewer

**Reviewed:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

$Comments

**Verdict:** Approved ✅
"@
    
    $updatedContent = $prContent + $reviewSection
    $updatedContent = $updatedContent -replace "- \[ \] Code review completed", "- [x] Code review completed"
    $updatedContent = $updatedContent -replace "- \[ \] Ready to merge", "- [x] Ready to merge"
    
    $updatedContent | Out-File -FilePath $prFile -Encoding utf8 -Force
    
    Write-Log "Added code review to PR #$PrId by $Reviewer"
}

# Function to merge a pull request
function Merge-PullRequest {
    param(
        [int]$PrId,
        [string]$BranchName
    )
    
    # Find the PR file
    $prFiles = Get-ChildItem -Path $prDir -Filter "pr-$PrId-*.md" -ErrorAction SilentlyContinue
    
    if ($prFiles.Count -eq 0) {
        Write-Log "Pull request #$PrId not found"
        return
    }
    
    $prFile = $prFiles[0].FullName
    $prContent = Get-Content -Path $prFile -Raw
    
    # Update PR status
    $updatedContent = $prContent -replace "**Status:** Open", "**Status:** Merged"
    
    $mergeSection = @"

## Merge Information

**Merged:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Merged by:** System
**Merge commit:** $(git rev-parse --short HEAD)
"@
    
    $updatedContent = $updatedContent + $mergeSection
    $updatedContent | Out-File -FilePath $prFile -Encoding utf8 -Force
    
    # Checkout main branch and merge
    git checkout main
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to checkout main branch"
    }
    
    git merge $BranchName --no-ff -m "Merge pull request #$PrId from $BranchName"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to merge branch $BranchName"
    }
    
    Write-Log "Merged pull request #$prId from branch $BranchName"
}

# Function to close an issue
function Close-Issue {
    param(
        [int]$IssueId,
        [int]$PrId
    )
    
    # Find the issue file
    $issueFiles = Get-ChildItem -Path $issuesDir -Filter "issue-$IssueId-*.md" -ErrorAction SilentlyContinue
    
    if ($issueFiles.Count -eq 0) {
        Write-Log "Issue #$IssueId not found"
        return
    }
    
    $issueFile = $issueFiles[0].FullName
    $issueContent = Get-Content -Path $issueFile -Raw
    
    # Update issue status
    $updatedContent = $issueContent -replace "**Status:** Open", "**Status:** Closed"
    
    $closedSection = @"

## Resolution

**Closed:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Resolved by:** PR #$PrId
**Status:** Fixed ✅
"@
    
    $updatedContent = $updatedContent -replace "- \[ \] Implement solution", "- [x] Implement solution"
    $updatedContent = $updatedContent -replace "- \[ \] Test changes", "- [x] Test changes"
    $updatedContent = $updatedContent -replace "- \[ \] Review code", "- [x] Review code"
    $updatedContent = $updatedContent -replace "- \[ \] Merge changes", "- [x] Merge changes"
    
    $updatedContent = $updatedContent + $closedSection
    $updatedContent | Out-File -FilePath $issueFile -Encoding utf8 -Force
    
    Write-Log "Closed issue #$IssueId, resolved by PR #$PrId"
}

# Function to perform a complete GitHub workflow
function Perform-GitHubWorkflow {
    param(
        [string]$Session
    )
    
    # Generate a feature name
    $featureTypes = @("feature", "enhancement", "bugfix", "improvement", "optimization")
    $featureAreas = @("user-interface", "authentication", "data-processing", "security", "performance")
    $featureType = $featureTypes | Get-Random
    $featureArea = $featureAreas | Get-Random
    $featureId = Get-Random -Minimum 100 -Maximum 999
    $featureName = "$featureType/$featureArea-$featureId"
    
    # Create a branch
    $branchName = "feature/$featureId-$featureArea"
    Create-Branch -BranchName $branchName
    
    # Create an issue
    $issueTitle = "Implement $featureType for $featureArea"
    $issueBody = @"
We need to implement a new $featureType to improve $featureArea functionality.

## Requirements
- Add new code to handle $featureArea processing
- Update documentation
- Ensure backward compatibility
- Add tests for the new functionality
"@
    $issueId = Create-Issue -Title $issueTitle -Body $issueBody
    
    # Update code snippets
    Update-CodeSnippets
    
    # Add feature-specific code to snippets
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    @"
# Added for feature: $featureName
# Branch: $branchName
# Issue: #$issueId
# Date: $timestamp

def enhanced_feature():
    """
    This function implements the $featureType for $featureArea.
    """
    print(f"Implementing $featureType for $featureArea")
    return True
"@ | Out-File -Append -FilePath "$snippetsDir\example.py" -Encoding utf8

    @"
// Added for feature: $featureName
// Branch: $branchName
// Issue: #$issueId
// Date: $timestamp

contract FeatureImplementation {
    // This contract implements the $featureType for $featureArea
    string public featureName = "$featureName";
    uint256 public featureId = $featureId;
    
    function isImplemented() public pure returns (bool) {
        return true;
    }
}
"@ | Out-File -Append -FilePath "$snippetsDir\SimpleContract.sol" -Encoding utf8

    @"
// Added for feature: $featureName
// Branch: $branchName
// Issue: #$issueId
// Date: $timestamp

// This class implements the $featureType for $featureArea
class FeatureImplementation {
    private featureName: string = "$featureName";
    private featureId: number = $featureId;
    
    isImplemented(): boolean {
        console.log(`Implementing ${this.featureName}`);
        return true;
    }
}

const feature = new FeatureImplementation();
console.log(`Feature implemented: ${feature.isImplemented()}`);
"@ | Out-File -Append -FilePath "$snippetsDir\app.ts" -Encoding utf8
    
    # Commit changes
    git add .
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to stage files"
    }
    
    git commit -m "Implement $featureName (#$issueId)"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to commit changes"
    }
    
    Write-Log "Committed changes for $featureName"
    
    # Push branch
    git push -u origin $branchName
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push branch $branchName"
    }
    
    Write-Log "Pushed branch $branchName to remote"
    
    # Create a pull request
    $prTitle = "Implement $featureType for $featureArea"
    $prBody = @"
This PR implements a new $featureType to improve $featureArea functionality.

## Changes
- Added new code to handle $featureArea processing
- Updated documentation
- Ensured backward compatibility

Fixes #$issueId
"@
    $prId = Create-PullRequest -Title $prTitle -Body $prBody -BranchName $branchName -IssueId $issueId
    
    # Perform code review
    $reviewers = @("Alice", "Bob", "Charlie", "David", "Eva")
    $reviewer = $reviewers | Get-Random
    $reviewComments = @"
I've reviewed the changes and they look good. The implementation is clean and follows our coding standards.

A few minor suggestions:
- Consider adding more comments to explain the complex logic
- The variable names could be more descriptive
- Make sure all edge cases are handled

Overall, great work!
"@
    Perform-CodeReview -PrId $prId -Reviewer $reviewer -Comments $reviewComments
    
    # Merge pull request
    Merge-PullRequest -PrId $prId -BranchName $branchName
    
    # Close issue
    Close-Issue -IssueId $issueId -PrId $prId
    
    # Update activity log
    "GitHub Workflow ($Session): Implemented $featureName, PR #$prId, Issue #$issueId - $(Get-Date)" | Out-File -Append -Encoding utf8 "$repoPath\activity.log"
    
    Write-Log "Completed GitHub workflow for $featureName ($Session session)"
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

# Override session if set in environment variable
if ($env:WORKFLOW_SESSION) {
    $runSession = $env:WORKFLOW_SESSION
    Write-Log "Session overridden by environment variable: $runSession"
}

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
        Write-Log "Today ($todayStr) is a commit day. Running workflow for $runSession session..."

        try {
            # Determine workflow type for this session
            $workflowType = if ($runSession -eq "morning") { "standard" } else { "advanced" }
            
            if ($workflowType -eq "standard") {
                # Morning session: Simple commit workflow
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
                "Simple Commit ($runSession): $(Get-Date)" | Out-File -Append -Encoding utf8 "$repoPath\activity.log"

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
                }
            } else {
                # Afternoon session: Full GitHub workflow (PR, issues, code review)
                Perform-GitHubWorkflow -Session $runSession
            }
            
            # Record that the script has run in this session
            "$todayStr::$runSession" | Out-File -FilePath $lastRunFile -Encoding utf8 -Force
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
