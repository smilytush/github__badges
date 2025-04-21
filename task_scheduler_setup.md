# Setting Up Windows Task Scheduler for Green Commits

This guide will help you set up a daily scheduled task to run the `green_commit.ps1` script automatically.

## Step-by-Step Instructions

1. **Open Task Scheduler**:
   - Press `Win + R` to open the Run dialog
   - Type `taskschd.msc` and press Enter

2. **Create a Basic Task**:
   - In the right panel, click on "Create Basic Task..."
   - Name: `GitHub Green Commit`
   - Description: `Automatically makes commits to keep GitHub profile active`
   - Click "Next"

3. **Set the Trigger**:
   - Select "Daily" and click "Next"
   - Start date: Today's date
   - Time: Choose a time when your computer is likely to be on (e.g., 10:00 AM)
   - Click "Next"

4. **Set the Action**:
   - Select "Start a program" and click "Next"
   - Program/script: `powershell.exe`
   - Add arguments: `-ExecutionPolicy Bypass -File "J:\green-commits\green_commit.ps1"`
   - Click "Next"

5. **Review and Finish**:
   - Review your settings and click "Finish"

6. **Modify Task Properties** (for better reliability):
   - Find your new task in the Task Scheduler Library
   - Right-click on it and select "Properties"
   - On the "General" tab:
     - Check "Run with highest privileges"
     - Select "Run whether user is logged on or not" (requires your Windows password)
   - On the "Conditions" tab:
     - Uncheck "Start the task only if the computer is on AC power"
     - Check "Wake the computer to run this task" (optional)
   - On the "Settings" tab:
     - Check "Run task as soon as possible after a scheduled start is missed"
     - Set "If the task fails, restart every:" to 5 minutes, for 3 restart attempts
   - Click "OK" to save changes

## Verification

After setting up the task, you can verify it works by:

1. Right-clicking on the task and selecting "Run"
2. Checking the `activity.log` file to see if a new entry was added (if today is a scheduled commit day)
3. Checking your GitHub profile to see if the commit appears

## Troubleshooting

If the task doesn't run as expected:

1. Check the Task Scheduler history for any error messages
2. Make sure the paths in the script are correct
3. Ensure your Git credentials are properly configured
4. Try running the script manually to see if there are any errors
