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

1. Clone this repository
2. Run the PowerShell script manually once to generate the commit schedule
3. Set up a daily scheduled task to run the script automatically

