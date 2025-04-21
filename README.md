# Green Commits

A simple automation to keep your GitHub contribution graph active.

This repository contains a PowerShell script that automatically makes commits on randomly selected days throughout the year, creating a natural-looking activity pattern on your GitHub profile.

## Features

- Automatically commits on 280 random days out of 365
- Creates a natural-looking contribution pattern
- Runs silently in the background via Windows Task Scheduler
- Completely private repository (your activity still counts toward your contribution graph)

## How It Works

The script generates a schedule of 280 random days and saves it to a file. Each day, when the scheduled task runs, the script checks if the current day is in the schedule. If it is, it makes a simple commit and pushes it to GitHub.

## Setup

You can set up this automation in just a few minutes using the provided scripts:

### Automatic Setup

1. Clone this repository to your local machine
2. Run `setup_github.ps1` to connect to GitHub (requires Git to be configured)
3. Run `setup_task.ps1` with administrator privileges to set up the Windows Task Scheduler task

```powershell
# Clone the repository (if you haven't already)
git clone https://github.com/smilytush/green-commits.git
cd green-commits

# Connect to GitHub
.\setup_github.ps1

# Set up the scheduled task (run as administrator)
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File .\setup_task.ps1" -Verb RunAs
```

### Manual Setup

If you prefer to set things up manually:

1. Clone this repository
2. Run `green_commit.ps1` manually once to generate the commit schedule
3. Create a GitHub repository named "green-commits"
4. Connect your local repository to GitHub:

   ```bash
   git remote add origin https://github.com/smilytush/green-commits.git
   git push -u origin master
   ```

5. Set up a daily scheduled task following the instructions in `task_scheduler_setup.md`

## Customization

You can customize this automation by:

1. **Changing the number of commit days**: Edit `green_commit.ps1` and change the `$daysToPick` variable
2. **Changing the commit message**: Edit the commit message in `green_commit.ps1`
3. **Changing the scheduled time**: Edit the trigger time in `setup_task.ps1` or modify the task in Task Scheduler

## GitHub Profile Stats

To showcase your GitHub activity on your profile, add these to your GitHub profile README:

```markdown
![GitHub Stats](https://github-readme-stats.vercel.app/api?username=smilytush&show_icons=true&count_private=true&theme=radical)
[![GitHub Streak](https://streak-stats.demolab.com/?user=smilytush&theme=radical)](https://git.io/streak-stats)
```
