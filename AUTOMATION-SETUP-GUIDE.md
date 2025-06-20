# 🤖 Green Commits Daily Automation Setup Guide

## Quick Setup Instructions

### Method 1: Using Batch File (Recommended)

1. **Test the batch file first:**
   ```cmd
   cd J:\green-commits
   run-daily-commits.bat
   ```

2. **Setup Windows Task Scheduler:**
   - Press `Win + R`, type `taskschd.msc`, press Enter
   - Click "Create Basic Task..." in the right panel
   - Name: `Green Commits Daily`
   - Description: `Automated daily GitHub commits`
   - Trigger: `Daily`
   - Start time: `9:00 AM` (or your preferred time)
   - Action: `Start a program`
   - Program: `J:\green-commits\run-daily-commits.bat`
   - Click "Finish"

3. **Configure advanced settings:**
   - Right-click the task → Properties
   - General tab: Check "Run whether user is logged on or not"
   - Triggers tab: Edit trigger → Check "Random delay up to: 8 hours"
   - Settings tab: 
     - Check "Allow task to be run on demand"
     - Check "Run task as soon as possible after a scheduled start is missed"
     - Check "If the task fails, restart every: 15 minutes"
     - Set "Attempt to restart up to: 3 times"

### Method 2: Using PowerShell Script Directly

1. **Setup Task Scheduler with PowerShell:**
   - Program: `powershell.exe`
   - Arguments: `-ExecutionPolicy Bypass -WindowStyle Hidden -File "J:\green-commits\GreenCommits-Simple.ps1" -Mode Daily`
   - Start in: `J:\green-commits`

### Method 3: Manual Daily Execution

If you prefer manual control, simply run this command daily:
```powershell
cd J:\green-commits
.\GreenCommits-Simple.ps1 -Mode Daily
```

## Verification

### Check if automation is working:

1. **View recent commits:**
   ```cmd
   cd J:\green-commits
   git log --oneline -10
   ```

2. **Check automation log:**
   ```cmd
   type daily-automation.log
   ```

3. **View GitHub contribution graph:**
   - Open: https://github.com/smilytush
   - Check for daily green squares

### Task Scheduler Verification:

1. Open Task Scheduler (`taskschd.msc`)
2. Find "Green Commits Daily" task
3. Check "Last Run Time" and "Next Run Time"
4. Right-click → "Run" to test immediately

## Troubleshooting

### Common Issues:

1. **Task not running:**
   - Check if user has permissions
   - Verify file paths are correct
   - Ensure PowerShell execution policy allows scripts

2. **No commits being created:**
   - Test manually: `.\GreenCommits-Simple.ps1 -Mode Daily`
   - Check Git configuration
   - Verify GitHub token is valid

3. **Permission errors:**
   - Run Task Scheduler as Administrator
   - Set task to "Run with highest privileges"

### Manual Testing:

```powershell
# Test the simple script
.\GreenCommits-Simple.ps1 -Mode Test

# Test daily mode
.\GreenCommits-Simple.ps1 -Mode Daily

# Check Git status
git status
git log --oneline -5
```

## Automation Features

### What the automation does:
- Creates 1-3 commits per day (randomized)
- Uses different programming languages (Python, Solidity, TypeScript)
- Generates realistic commit messages
- Pushes commits to GitHub automatically
- Runs at random times within an 8-hour window

### Timing:
- Base time: 9:00 AM daily
- Random delay: Up to 8 hours (so commits happen between 9 AM - 5 PM)
- Weekend commits: Reduced frequency for realism

### Safety features:
- Automatic retry on failure (up to 3 times)
- Logs all executions
- Hidden window execution (no interruption)
- Respects GitHub API rate limits

## Advanced Configuration

### Customize commit frequency:
Edit `GreenCommits-Simple.ps1` line 134:
```powershell
$commitCount = Get-Random -Minimum 1 -Maximum 4  # Change max to 2, 3, 5, etc.
```

### Change timing:
Modify the Task Scheduler trigger time and random delay as needed.

### Add more languages:
Edit the `$languages` array in `GreenCommits-Simple.ps1`:
```powershell
$languages = @("python", "solidity", "typescript", "javascript", "java", "cpp")
```

## Success Indicators

✅ **Daily automation is working if:**
- New commits appear daily on GitHub
- Contribution graph shows consistent green squares
- `git log` shows recent automated commits
- `daily-automation.log` shows successful executions

✅ **GitHub profile shows:**
- Consistent daily activity
- Realistic commit patterns
- Multiple programming languages
- Professional commit messages

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Test components manually
3. Verify all file paths and permissions
4. Ensure GitHub token is valid and has proper permissions
