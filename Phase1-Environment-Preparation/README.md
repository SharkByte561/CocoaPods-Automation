# Phase 1: Environment Preparation Instructions

## Prerequisites
- Windows 10/11 or Windows Server 2019+ (64-bit)
- Administrator privileges
- Internet connection

## Step-by-Step Instructions

### Step 1: Run PowerShell as Administrator
1. Right-click on PowerShell
2. Select "Run as Administrator"

### Step 2: Execute Scripts in Order
Run each script in the following order:

```powershell
# 1. Setup PowerShell execution policy
.\01-setup-powershell.ps1

# 2. Install Chocolatey
.\02-install-chocolatey.ps1

# 3. Install Git
.\03-install-git.ps1

# 4. Setup repository structure
.\04-setup-repository.ps1
```

### Step 3: Verify Installation
After running all scripts, verify everything is working:

```powershell
# Check PowerShell version
$PSVersionTable.PSVersion

# Check Chocolatey
choco --version

# Check Git
git --version
```

## What These Scripts Do

1. **01-setup-powershell.ps1**: Configures PowerShell execution policy to allow script execution
2. **02-install-chocolatey.ps1**: Installs Chocolatey package manager and essential tools
3. **03-install-git.ps1**: Installs Git if not already present
4. **04-setup-repository.ps1**: Clones your repository and creates the required folder structure

## Troubleshooting

### If you get execution policy errors:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
```

### If Chocolatey installation fails:
1. Check your internet connection
2. Try running the script again
3. Manually install from https://chocolatey.org/install

### If Git installation fails:
1. Download Git manually from https://git-scm.com/
2. Install using the installer
3. Restart PowerShell

## Next Steps
After completing Phase 1, proceed to Phase 2: Repository Configuration
