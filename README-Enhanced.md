# 🌟 Green Commits Master System v3.0

**The Ultimate GitHub Contribution Graph Enhancement System**

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-10%2B-green.svg)](https://www.microsoft.com/windows)
[![GitHub](https://img.shields.io/badge/GitHub-API%20v4-black.svg)](https://docs.github.com/en/graphql)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 🚀 Overview

The Green Commits Master System is a comprehensive, enterprise-grade solution for managing and enhancing your GitHub contribution graph. Built upon the proven foundation of the existing working system, it adds advanced features while preserving 100% compatibility with all existing functionality.

### ✨ Key Features

- **🎯 Proven Backdating System**: Successfully creates commits from November 1, 2022 to present
- **🔧 Unified Control Interface**: Single master script with interactive menu system
- **⚙️ Advanced Configuration**: JSON-based configuration with validation and backup
- **🤖 Daily Automation**: Windows Task Scheduler integration for consistent contributions
- **🏆 Badge Achievement System**: Automated strategies for earning GitHub profile badges
- **📊 Real-time Monitoring**: Contribution graph status and performance metrics
- **🛡️ Robust Error Handling**: Comprehensive error recovery and retry mechanisms
- **🧹 Project Maintenance**: Automated cleanup and optimization tools

## 📋 System Requirements

- **Operating System**: Windows 10 or higher
- **PowerShell**: Version 5.1 or higher
- **Git**: Latest version installed and configured
- **Internet**: Stable connection to GitHub API
- **Disk Space**: Minimum 1GB free space
- **GitHub**: Valid personal access token with repository permissions

## 🛠️ Quick Installation

### Method 1: Automated Installation (Recommended)

```powershell
# Clone or download the project
cd J:\green-commits

# Run the installer
.\install.ps1
```

### Method 2: Manual Setup

```powershell
# Ensure all required files are present
# - GreenCommits-Master.ps1
# - enhanced_historical_system_v2.ps1
# - config.json
# - install.ps1

# Run the master control system
.\GreenCommits-Master.ps1
```

## 🎮 Usage Guide

### Interactive Mode (Recommended)

```powershell
.\GreenCommits-Master.ps1
```

This launches the interactive menu with the following options:

1. **Full Historical Backfill** - Creates 779 days of commits (Nov 2022-present)
2. **Test Mode** - Creates 5 sample commits for verification
3. **Custom Date Range** - User-specified dates and intensity levels
4. **Daily Automation** - Setup Windows Task Scheduler integration
5. **Badge Achievement** - Automated GitHub badge earning strategies
6. **Configuration** - System settings and validation
7. **Status Viewer** - Current contribution graph analysis
8. **Project Cleanup** - Maintenance and optimization tools

### Command Line Mode

```powershell
# Quick test run
.\GreenCommits-Master.ps1 -Mode Test

# Full historical backfill with auto-confirmation
.\GreenCommits-Master.ps1 -Mode Full -AutoConfirm

# Custom date range
.\GreenCommits-Master.ps1 -Mode Custom -StartDate "2024-01-01" -EndDate "2024-12-31" -Intensity 4

# Daily automation setup
.\GreenCommits-Master.ps1 -Mode Daily

# Configuration management
.\GreenCommits-Master.ps1 -Mode Config

# View contribution status
.\GreenCommits-Master.ps1 -Mode Status
```

### Advanced Options

```powershell
# Dry run (preview without executing)
.\GreenCommits-Master.ps1 -Mode Full -DryRun

# Force execution (skip confirmations)
.\GreenCommits-Master.ps1 -Mode Full -Force

# Help and documentation
.\GreenCommits-Master.ps1 -Help
```

## ⚙️ Configuration

The system uses a comprehensive JSON configuration file (`config.json`) with the following sections:

### GitHub Settings
```json
{
  "GitHub": {
    "Username": "your-username",
    "Email": "your-email@example.com",
    "Token": "your-github-token",
    "Repository": "github-commits",
    "RemoteURL": "https://github.com/username/repo.git"
  }
}
```

### System Settings
```json
{
  "System": {
    "Coverage": 0.82,
    "MaxCommitsPerDay": 50,
    "IntensityLevels": [3, 4, 5],
    "SupportedLanguages": ["python", "solidity", "typescript"]
  }
}
```

### Automation Settings
```json
{
  "Automation": {
    "DailyCommits": {
      "Enabled": false,
      "MinCommits": 1,
      "MaxCommits": 3,
      "TimeWindow": ["09:00", "17:00"]
    }
  }
}
```

## 🏆 GitHub Badge Achievement System

The system includes automated strategies for earning GitHub profile badges:

### Available Badges
- **Arctic Code Vault Contributor** - Contribute to popular repositories
- **Mars 2020 Helicopter Contributor** - Contribute to NASA projects  
- **Pull Shark** - Create and merge pull requests
- **YOLO** - Merge without review (use carefully)
- **Quickdraw** - Close issues/PRs rapidly
- **Pair Extraordinaire** - Co-author commits
- **Public Sponsor** - Sponsor open source projects

### Badge Configuration
```powershell
# Enable badge system
.\GreenCommits-Master.ps1 -Mode Badges

# Configure specific badge strategies in config.json
```

## 🤖 Daily Automation

Set up automated daily contributions using Windows Task Scheduler:

```powershell
# Setup daily automation
.\GreenCommits-Master.ps1 -Mode Daily

# Manual task creation
schtasks /create /tn "GreenCommits-Daily" /xml TaskScheduler-Template.xml
```

### Automation Features
- **Randomized Timing** - Commits at random times within specified windows
- **Weekend Reduction** - Reduced activity on weekends for realism
- **Holiday Awareness** - Automatic reduction during holidays
- **Failure Recovery** - Automatic retry on failures

## 📊 Monitoring and Analytics

### Real-time Status
```powershell
# View contribution graph status
.\GreenCommits-Master.ps1 -Mode Status
```

### Performance Metrics
- API rate limit usage
- Commit success rates
- Error frequencies
- System health indicators

### Logging
- **Master Log**: `GreenCommits-Master.log`
- **System Log**: `enhanced_historical_system_v2.log`
- **Error Log**: Detailed error tracking and recovery
- **Audit Log**: Security and access tracking

## 🛡️ Security Features

### Token Management
- Secure token storage options
- Token validation and refresh
- Access control and audit logging

### Safe Operation
- Dry-run mode for testing
- Rollback functionality
- Backup and restore capabilities
- Rate limit respect and exponential backoff

## 🧹 Maintenance and Cleanup

### Automated Cleanup
```powershell
# Run project cleanup
.\GreenCommits-Master.ps1 -Mode Cleanup
```

### Manual Maintenance
- Log rotation (30-day retention)
- Temporary file cleanup
- Git repository optimization
- Configuration backup

## 🔧 Troubleshooting

### Common Issues

**Issue**: "GitHub token authentication failed"
```powershell
# Solution: Update token in configuration
.\GreenCommits-Master.ps1 -Mode Config
# Select option 1 to edit GitHub settings
```

**Issue**: "Git is not installed or not in PATH"
```powershell
# Solution: Install Git and add to PATH
# Download from: https://git-scm.com/download/win
```

**Issue**: "System validation failed"
```powershell
# Solution: Run with skip validation
.\install.ps1 -SkipValidation
```

### Debug Mode
```powershell
# Enable detailed logging
$env:DEBUG = "true"
.\GreenCommits-Master.ps1 -Mode Test
```

### Support
- Check logs in the `logs/` directory
- Review configuration in `config.json`
- Use `-Help` parameter for command reference
- Run system validation: `.\GreenCommits-Master.ps1 -Mode Config` → Option 3

## 📈 Performance Optimization

### Recommended Settings
- **Batch Size**: 10 commits per batch
- **Rate Limiting**: Respect GitHub API limits
- **Parallel Processing**: Enable for large operations
- **Memory Management**: Automatic cleanup and optimization

### Scaling
- Multi-repository support
- Distributed processing
- Cloud integration capabilities
- Enterprise deployment options

## 🔄 Migration from Previous Versions

The system automatically preserves all existing functionality:

1. **Existing Scripts**: All previous scripts remain functional
2. **Configuration**: Automatic migration to new config format
3. **Data**: Existing commits and history preserved
4. **Settings**: Previous settings imported automatically

## 📝 Changelog

### Version 3.0 (Current)
- ✅ Unified master control system
- ✅ JSON-based configuration
- ✅ Daily automation with Task Scheduler
- ✅ GitHub badge achievement system
- ✅ Advanced monitoring and analytics
- ✅ Project cleanup and maintenance tools
- ✅ Enhanced error handling and recovery
- ✅ Comprehensive documentation

### Version 2.0 (Previous)
- ✅ Enhanced historical backdating system
- ✅ Improved commit generation
- ✅ Better error handling
- ✅ Multiple language support

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests for any improvements.

## ⚠️ Disclaimer

This tool is for educational and personal use only. Users are responsible for complying with GitHub's Terms of Service and applicable laws. Use responsibly and ethically.

---

**Made with ❤️ for the GitHub community**
