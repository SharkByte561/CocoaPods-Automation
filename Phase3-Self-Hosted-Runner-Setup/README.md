# Phase 3: Self-Hosted Runner Setup Instructions

## Overview
This phase sets up a self-hosted GitHub Actions runner on your Windows machine to execute the Chocolatey package creation workflows.

## Prerequisites
- Windows 10/11 or Windows Server 2019+
- Administrator privileges
- Internet connectivity
- GitHub repository access

## Step-by-Step Instructions

### Step 1: Get GitHub Registration Token
1. Go to your repository: https://github.com/SharkByte561/CocoaPods
2. Navigate to **Settings** → **Actions** → **Runners**
3. Click **New self-hosted runner**
4. Select **Windows** as the operating system
5. Copy the **token** from the configuration command (it starts with 'A')

### Step 2: Download Runner
```powershell
# Run as Administrator
.\01-download-runner.ps1
```

### Step 3: Configure Runner
```powershell
# Replace YOUR_TOKEN with the token from Step 1
.\02-configure-runner.ps1 -Token "YOUR_TOKEN"
```

### Step 4: Install as Service
```powershell
# Run as Administrator
.\03-install-service.ps1
```

### Step 5: Verify Installation
1. Check GitHub repository settings
2. Go to: https://github.com/SharkByte561/CocoaPods/settings/actions/runners
3. You should see your runner listed as "Idle"

## Script Details

### 01-download-runner.ps1
- Downloads the latest GitHub Actions runner
- Extracts to C:\actions-runner
- Verifies required files

### 02-configure-runner.ps1
**Parameters:**
- `-Token`: GitHub registration token (required)
- `-RunnerDirectory`: Installation directory (default: C:\actions-runner)
- `-RunnerName`: Runner name (default: windows-chocolatey)
- `-Labels`: Runner labels (default: self-hosted,windows,chocolatey)

### 03-install-service.ps1
- Installs runner as Windows service
- Starts the service
- Configures automatic startup
- Verifies service status

## Security Considerations

### Network Access
The runner needs outbound HTTPS access to:
- github.com (port 443)
- api.github.com (port 443)
- objects.githubusercontent.com (port 443)

### Service Account
By default, the service runs as SYSTEM. For enhanced security:

```powershell
# Create dedicated service account
$securePassword = ConvertTo-SecureString "ComplexPassword123!" -AsPlainText -Force
New-LocalUser -Name "GitHubRunner" -Password $securePassword -Description "GitHub Actions Runner"

# Configure service to use dedicated account
$serviceName = (Get-Service -Name "actions.runner.*").Name
sc.exe config $serviceName obj= ".\GitHubRunner" password= "ComplexPassword123!"
```

## Troubleshooting

### Runner Won't Start
```powershell
# Check service status
Get-Service -Name "actions.runner.*"

# Check runner logs
Get-Content "C:\actions-runner\_diag\Runner_*.log" | Select-Object -Last 50

# Restart service
Restart-Service -Name "actions.runner.*"
```

### Configuration Errors
- Verify the token is correct and not expired
- Ensure you have admin rights on the repository
- Check internet connectivity

### Permission Issues
- Run PowerShell as Administrator
- Verify execution policy allows script execution
- Check Windows Firewall settings

## Verification Commands

```powershell
# Check service status
Get-Service -Name "actions.runner.*"

# Check runner directory
Get-ChildItem "C:\actions-runner"

# Check runner configuration
Get-Content "C:\actions-runner\.runner" | ConvertFrom-Json
```

## Next Steps
After successful installation:
1. Proceed to Phase 4: Create Supporting Scripts
2. The runner should appear in your GitHub repository settings
3. Workflows will automatically use this runner when triggered

## Important Notes
- Keep the registration token secure and don't share it
- The runner will automatically update itself
- Monitor runner logs for any issues
- Ensure the machine stays online for workflows to execute
