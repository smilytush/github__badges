# GitHub Workflow Automation

A comprehensive automation system to keep your GitHub profile active with realistic development activities.

This repository contains PowerShell scripts that automatically generate commits, issues, pull requests, and code reviews on randomly selected days throughout the year, creating a natural-looking activity pattern on your GitHub profile.

## Features

- Automatically runs on 280 random days out of 365
- Creates a natural-looking contribution pattern with varied activities
- Runs twice daily via Windows Task Scheduler:
  - **Morning**: Simple commits with code changes
  - **Afternoon**: Full GitHub workflow (issues, PRs, code reviews)
- Updates code in multiple languages (Python, Solidity, TypeScript)
- Completely private repository (your activity still counts toward your contribution graph)
- Interactive dashboard to monitor your progress
- Tools to visualize and manage your GitHub workflow

## How It Works

The system generates a schedule of 280 random days and saves it to a file. Each day, when the scheduled tasks run:

1. **Morning Session (9:00 AM)**:
   - Pulls the latest changes from GitHub
   - Updates code snippets in Python, Solidity, and TypeScript
   - Makes a simple commit and pushes it to GitHub

2. **Afternoon Session (3:00 PM)**:
   - Creates a new branch for a feature
   - Creates an issue describing the feature
   - Updates code snippets with feature-specific code
   - Creates a pull request referencing the issue
   - Performs a code review on the pull request
   - Merges the pull request
   - Closes the issue
   - Pushes all changes to GitHub

## Setup

You can set up this automation in just a few minutes using the provided scripts:

### Automatic Setup

1. Clone this repository to your local machine
2. Run `github_workflow.bat` to open the menu
3. Select option 7 to set up the Task Scheduler tasks

```powershell
# Clone the repository (if you haven't already)
git clone https://github.com/smilytush/green-commits.git
cd green-commits

# Run the menu
.\github_workflow.bat
```

## Tools and Utilities

This repository includes several tools to help you manage and monitor your GitHub workflow:

- **github_workflow.bat**: Easy-to-use menu interface for all tools
- **enhanced_dashboard.ps1**: Generates an HTML dashboard with visual statistics
- **enhanced_workflow.ps1**: The main script that handles all GitHub activities
- **enhanced_menu.ps1**: The menu interface for managing the workflow

To use these tools, simply run `github_workflow.bat` and select the desired option from the menu.

## Dashboard

The dashboard provides a comprehensive view of your GitHub workflow activities:

- Total activities performed
- Issues created and closed
- Pull requests created and merged
- Code reviews performed
- Upcoming scheduled days
- Code snippets being updated
- Task Scheduler status

## Customization

You can customize this automation by:

1. **Changing the number of activity days**: Edit `enhanced_workflow.ps1` and change the `$daysToPick` variable
2. **Modifying the code snippets**: Edit the code snippet templates in `enhanced_workflow.ps1`
3. **Changing the scheduled times**: Edit the trigger times in `setup_task_enhanced.ps1`

## GitHub Profile Stats

To showcase your GitHub activity on your profile, add these to your GitHub profile README:

```markdown
![GitHub Stats](https://github-readme-stats.vercel.app/api?username=smilytush&show_icons=true&count_private=true&theme=radical)
[![GitHub Streak](https://streak-stats.demolab.com/?user=smilytush&theme=radical)](https://git.io/streak-stats)
```

## Important Notes

- This automation is designed to run on your local machine
- The Task Scheduler tasks will only run when your computer is powered on
- All activities are performed in a private repository, but they still count toward your public GitHub contribution graph
- The system is designed to create a natural-looking activity pattern, not to spam your GitHub profile
