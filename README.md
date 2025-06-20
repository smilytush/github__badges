# GitHub Workflow Automation (Natural Pattern)

A comprehensive automation system to keep your GitHub profile active with realistic development activities using a natural random pattern.

This repository contains PowerShell scripts that automatically generate commits, issues, pull requests, and code reviews on randomly selected days throughout the year, creating a natural-looking activity pattern on your GitHub profile with strategically placed dark green contributions.

## Features

- **Natural Random Pattern**: Creates a completely natural-looking contribution graph
- **Runs Whenever Machine is On**: Automatically runs at startup, logon, and scheduled times
- **Multi-Machine Support**: Easy setup on multiple computers with automatic configuration
- **Dark Green Focus**: Creates dark green contributions (level 4-5) twice per week on random days
- **3-Level Intensity System**: Uses only medium to dark green levels (3-5) for better visual impact
- **Increased Coverage**: Automatically runs on 300 random days out of 365
- **Twice Daily Activities**:
  - **Morning**: Simple commits with code changes
  - **Afternoon**: Full GitHub workflow (issues, PRs, code reviews)
- **Weekend Contributions**: Includes weekend days in the random pattern
- **Multi-Language Updates**: Updates code in Python, Solidity, and TypeScript
- **Interactive Dashboard**: Monitor your progress with visual statistics
- **Comprehensive Tools**: Visualize and manage your GitHub workflow

## How It Works

The system generates a natural random schedule of 300 days and saves it to a file. The automation runs:

1. **When Your Computer Starts**:
   - Automatically runs when your machine boots up
   - Checks if today is a scheduled day and runs the appropriate workflow

2. **When You Log In**:
   - Runs when you log into your Windows account
   - Performs the afternoon workflow with full GitHub activities

3. **Morning Session (9:00 AM)**:
   - Pulls the latest changes from GitHub
   - Updates code snippets in Python, Solidity, and TypeScript
   - Makes multiple commits based on the day's intensity level (2-5)
   - Pushes changes to GitHub

4. **Afternoon Session (3:00 PM)**:
   - Creates a new branch for a feature
   - Creates an issue describing the feature
   - Updates code snippets with feature-specific code
   - Creates a pull request referencing the issue
   - Performs a code review on the pull request
   - Merges the pull request and closes the issue
   - Pushes all changes to GitHub

## Setup

You can set up this automation in just a few minutes using the provided scripts:

### On Your Primary Machine

1. Clone this repository to your local machine
2. Run `green_github.bat` to open the menu
3. Select option 4 to optimize for a natural random pattern
4. Select option 8 to set up all automation tasks (startup, logon, and scheduled)

```powershell
# Clone the repository
git clone https://github.com/smilytush/green-commits.git
cd green-commits

# Run the menu
.\green_github.bat
```

### On Additional Machines

1. On your primary machine, select option 9 from the menu
2. Copy the `setup_new_machine.ps1` script to your additional machine
3. Run the script with administrator privileges
4. Follow the prompts to complete the setup

## Optimization Options

The system offers multiple optimization strategies:

1. **Natural Random Pattern (Option 4)**: Creates a completely natural-looking pattern with random intensity levels and two dark green days per week on random days (including weekends)

2. **Dark Green Focus (Option 5)**: Creates a pattern with dark green contributions twice per week on specific days (Tuesday and Thursday)

3. **3-Level System**: Both options use only 3 intensity levels (3-5), removing the lightest green (level 1) for a more impactful contribution graph

## Tools and Utilities

This repository includes several tools to help you manage and monitor your GitHub workflow:

- **green_github.bat**: Easy-to-use menu interface for all tools
- **enhanced_dashboard.ps1**: Generates an HTML dashboard with visual statistics
- **green_workflow_4levels.ps1**: The main script that handles all GitHub activities
- **green_menu_fixed.ps1**: The menu interface for managing the workflow
- **green_optimizer_natural.ps1**: Creates a natural random pattern
- **setup_new_machine.ps1**: Sets up the system on additional machines

## Dashboard

The dashboard provides a comprehensive view of your GitHub workflow activities:

- Total activities performed with intensity distribution
- Issues created and closed
- Pull requests created and merged
- Code reviews performed
- Upcoming scheduled days with intensity levels
- Code snippets being updated
- Task Scheduler status for all automation tasks

## Automation Tasks

The system sets up multiple automation tasks to ensure your GitHub activity continues regardless of your schedule:

1. **Startup Task**: Runs when your computer starts up (morning session)
2. **Logon Task**: Runs when you log into Windows (afternoon session)
3. **Daily Morning Task**: Runs at 9:00 AM every day
4. **Daily Afternoon Task**: Runs at 3:00 PM every day

## Important Notes

- The system runs automatically whenever your machine is on
- All activities are performed in a private repository, but they still count toward your public GitHub contribution graph
- The system is designed to create a natural-looking activity pattern
- Dark green contributions (levels 4-5) appear twice per week on random days
- The system works across multiple machines with easy setup

## GitHub Profile Stats

To showcase your enhanced GitHub activity on your profile, add these to your GitHub profile README:

```markdown
![GitHub Stats](https://github-readme-stats.vercel.app/api?username=smilytush&show_icons=true&count_private=true&theme=radical)
[![GitHub Streak](https://streak-stats.demolab.com/?user=smilytush&theme=radical)](https://git.io/streak-stats)
```
