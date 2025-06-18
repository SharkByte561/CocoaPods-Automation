# Phase 7: Troubleshooting Common Issues

## Overview
This phase provides comprehensive troubleshooting guidance for common issues you may encounter with the automation system.

## Runner Issues

### Issue: Runner Won't Start
**Symptoms**: Service fails to start, runner appears offline in GitHub

**Diagnosis**:
```powershell
# Check service status
Get-Service -Name "actions.runner.*"

# Check runner logs
cd C:\actions-runner
Get-Content "_diag\Runner_*.log" | Select-Object -Last 50

# Check configuration
Get-Content ".runner" | ConvertFrom-Json
```

**Solutions**:
```powershell
# Restart the service
$serviceName = (Get-Service -Name "actions.runner.*").Name
Restart-Service -Name $serviceName

# If restart fails, reinstall service
cd C:\actions-runner
.\svc.sh uninstall
.\svc.sh install
.\svc.sh start

# Check Windows Event Logs
Get-EventLog -LogName Application -Source ActionsRunnerService -Newest 10
```

### Issue: Runner Connection Problems
**Symptoms**: Runner shows as offline, can't connect to GitHub

**Diagnosis**:
```powershell
# Test network connectivity
Test-NetConnection github.com -Port 443
Test-NetConnection api.github.com -Port 443

# Check proxy settings
netsh winhttp show proxy

# Verify DNS resolution
nslookup github.com
```

**Solutions**:
```powershell
# Configure Windows Firewall
New-NetFirewallRule -DisplayName "GitHub HTTPS Out" -Direction Outbound -Protocol TCP -RemotePort 443 -Action Allow

# If behind corporate firewall, configure proxy
# In runner directory, edit .env file:
# https_proxy=http://proxy.company.com:8080
# http_proxy=http://proxy.company.com:8080
```

### Issue: Runner Performance Problems
**Symptoms**: Slow workflow execution, timeouts

**Diagnosis**:
```powershell
# Check system resources
Get-Process | Where-Object {$_.ProcessName -like "*runner*"} | 
    Select-Object ProcessName, CPU, WorkingSet, PagedMemorySize

# Check disk space
Get-WmiObject -Class Win32_LogicalDisk | 
    Select-Object DeviceID, @{Name="Size(GB)";Expression={[math]::round($_.Size/1GB,2)}}, 
    @{Name="FreeSpace(GB)";Expression={[math]::round($_.FreeSpace/1GB,2)}}

# Check memory usage
Get-CimInstance Win32_OperatingSystem | 
    Select-Object @{Name="MemoryUsage(%)";Expression={[math]::round(((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize),2)}}
```

**Solutions**:
```powershell
# Clean up temporary files
Remove-Item $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue

# Increase timeout in workflow
# Edit .github/workflows/create-package.yml:
# timeout-minutes: 30  # Add this to job or step level

# Optimize runner machine
# - Add more RAM
# - Use SSD storage
# - Close unnecessary applications
```

## PowerShell Script Issues

### Issue: Execution Policy Errors
**Symptoms**: Scripts fail with "execution policy" errors

**Solutions**:
```powershell
# Check current policy
Get-ExecutionPolicy -List

# Fix execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

# For specific script issues
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Verify the fix
Get-ExecutionPolicy
```

### Issue: Module Import Errors
**Symptoms**: "Module not found" or "Command not found" errors

**Diagnosis**:
```powershell
# Check PowerShell version
$PSVersionTable

# List available modules
Get-Module -ListAvailable

# Check execution path
$env:PSModulePath -split ';'
```

**Solutions**:
```powershell
# Install missing modules
Install-Module -Name PowerShellGet -Force
Install-Module -Name PackageManagement -Force

# Update PowerShell if needed
winget install Microsoft.PowerShell

# Add module paths if needed
$env:PSModulePath += ";C:\Program Files\WindowsPowerShell\Modules"
```

### Issue: Chocolatey Command Failures
**Symptoms**: "choco command not found" or Chocolatey operations fail

**Diagnosis**:
```powershell
# Check if Chocolatey is installed
choco --version

# Check Chocolatey configuration
choco config list

# Check PATH environment variable
$env:PATH -split ';' | Where-Object { $_ -like "*chocolatey*" }
```

**Solutions**:
```powershell
# Reinstall Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Refresh environment variables
refreshenv

# Or manually update PATH
$env:PATH += ";C:\ProgramData\chocolatey\bin"

# Verify installation
choco --version
```

## Workflow Issues

### Issue: Workflow Doesn't Trigger
**Symptoms**: Issues created but no workflow runs

**Diagnosis**:
1. Check if issue has `package-request` label
2. Verify workflow file syntax
3. Check repository Actions permissions

**Solutions**:
```yaml
# Verify workflow trigger in .github/workflows/create-package.yml
on:
  issues:
    types: [opened, labeled]  # Ensure this matches your needs

# Check workflow file syntax at:
# https://github.com/YOUR_REPO/actions/workflows/create-package.yml
```

### Issue: Issue Parsing Fails
**Symptoms**: Workflow runs but can't extract package information

**Diagnosis**:
Check workflow logs for parsing errors in the "Parse Issue Content" step.

**Solutions**:
```javascript
// Debug the parsing regex in workflow
console.log('Issue body:', body);
console.log('Name match:', nameMatch);
console.log('Version match:', versionMatch);

// Update regex patterns if needed
const nameMatch = body.match(/### Package Name\s*\n\s*(.+)/i);
```

### Issue: Package Creation Fails
**Symptoms**: Workflow fails at package generation step

**Common Causes & Solutions**:

**Invalid Download URL**:
```powershell
# Test URL manually
Invoke-WebRequest -Uri "YOUR_URL" -Method Head -UseBasicParsing
```

**Checksum Calculation Fails**:
```powershell
# Debug checksum calculation
$tempFile = "$env:TEMP\test-download.exe"
Invoke-WebRequest -Uri "YOUR_URL" -OutFile $tempFile -UseBasicParsing
$checksum = (Get-FileHash -Path $tempFile -Algorithm SHA256).Hash
Write-Host "Checksum: $checksum"
```

**Chocolatey Pack Errors**:
```powershell
# Test package creation manually
cd packages\your-package
choco pack --debug --verbose

# Check .nuspec syntax
[xml]$nuspec = Get-Content "your-package.nuspec"
$nuspec  # Should parse without errors
```

## Secret and Permission Issues

### Issue: Secrets Not Accessible
**Symptoms**: "Secret not found" or deployment fails

**Diagnosis**:
1. Check secret exists in repository settings
2. Verify secret name exactly matches `CHOCOLATEY_API_KEY`
3. Check repository permissions

**Solutions**:
1. Re-add the secret with exact name
2. Verify runner has network access to push.chocolatey.org
3. Test API key manually:

```powershell
# Test API key manually
$env:CHOCOLATEY_API_KEY = "your-key-here"
choco apikey --key $env:CHOCOLATEY_API_KEY --source https://push.chocolatey.org/
choco search your-package --source https://push.chocolatey.org/ --user
```

### Issue: Permission Denied Errors
**Symptoms**: File system or registry access denied

**Solutions**:
```powershell
# Run runner service as administrator
sc.exe config "actions.runner.service" obj= "NT AUTHORITY\SYSTEM" type=own
Restart-Service -Name "actions.runner.*"

# Check folder permissions
icacls "C:\actions-runner"
icacls "C:\GitHub\CocoaPods"

# Grant permissions if needed
icacls "C:\GitHub\CocoaPods" /grant "Everyone:(OI)(CI)F" /T
```

## Package Testing Issues

### Issue: Package Installation Tests Fail
**Symptoms**: Generated packages fail during testing phase

**Common Causes & Solutions**:

**Silent Arguments Incorrect**:
```powershell
# Test silent installation manually
Start-Process "installer.exe" -ArgumentList "/S" -Wait -NoNewWindow

# Common silent arguments:
# NSIS: /S
# Inno Setup: /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
# MSI: /quiet /norestart
# InstallShield: /s /v"/qn"
```

**Antivirus Interference**:
```powershell
# Add exclusions for:
# - C:\actions-runner\
# - C:\ProgramData\chocolatey\
# - Your package test directories

# Check Windows Defender exclusions
Get-MpPreference | Select-Object ExclusionPath
```

**Insufficient Privileges**:
```powershell
# Ensure runner service runs with admin privileges
sc.exe qc "actions.runner.service"

# Should show: SERVICE_START_NAME: NT AUTHORITY\SYSTEM
```

## Network and Connectivity Issues

### Issue: Download Failures
**Symptoms**: Cannot download installer files

**Diagnosis**:
```powershell
# Test connectivity
Test-NetConnection github.com -Port 443
Test-NetConnection chocolatey.org -Port 443

# Test with different methods
Invoke-WebRequest -Uri "YOUR_URL" -Method Head -UseBasicParsing
Invoke-RestMethod -Uri "YOUR_URL" -Method Head

# Check proxy settings
netsh winhttp show proxy
```

**Solutions**:
```powershell
# Configure proxy if needed
netsh winhttp set proxy proxy.company.com:8080

# Set TLS version
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Add certificate handling
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
```

## Debugging Tools and Commands

### Comprehensive System Check
```powershell
# System health check script
function Test-AutomationSystem {
    Write-Host "=== System Health Check ===" -ForegroundColor Green
    
    # PowerShell version
    Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
    
    # Execution policy
    Write-Host "Execution Policy: $(Get-ExecutionPolicy)" -ForegroundColor Yellow
    
    # Chocolatey status
    try {
        $chocoVersion = choco --version
        Write-Host "Chocolatey Version: $chocoVersion" -ForegroundColor Green
    } catch {
        Write-Host "Chocolatey: Not installed or not in PATH" -ForegroundColor Red
    }
    
    # Runner status
    $runnerService = Get-Service -Name "actions.runner.*" -ErrorAction SilentlyContinue
    if ($runnerService) {
        Write-Host "Runner Service: $($runnerService.Status)" -ForegroundColor Green
    } else {
        Write-Host "Runner Service: Not found" -ForegroundColor Red
    }
    
    # Disk space
    $disk = Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DeviceID -eq "C:"}
    $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    Write-Host "Free Disk Space: $freeGB GB" -ForegroundColor Yellow
    
    # Network connectivity
    try {
        Test-NetConnection github.com -Port 443 -InformationLevel Quiet
        Write-Host "GitHub Connectivity: OK" -ForegroundColor Green
    } catch {
        Write-Host "GitHub Connectivity: Failed" -ForegroundColor Red
    }
}

# Run the health check
Test-AutomationSystem
```

### Log Collection Script
```powershell
# Collect all relevant logs
function Collect-TroubleshootingLogs {
    $logDir = "C:\Troubleshooting-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -ItemType Directory -Path $logDir -Force
    
    # Runner logs
    if (Test-Path "C:\actions-runner\_diag") {
        Copy-Item "C:\actions-runner\_diag\*" $logDir -Recurse
    }
    
    # System info
    Get-ComputerInfo | Out-File "$logDir\system-info.txt"
    Get-Service | Out-File "$logDir\services.txt"
    Get-Process | Out-File "$logDir\processes.txt"
    
    # Environment variables
    Get-ChildItem Env: | Out-File "$logDir\environment.txt"
    
    # Network configuration
    ipconfig /all | Out-File "$logDir\network-config.txt"
    
    Write-Host "Logs collected in: $logDir"
}
```

## Getting Help

### GitHub Community
- Create issues in your repository for specific problems
- Check GitHub Actions community discussions
- Search existing issues for similar problems

### Chocolatey Community
- Chocolatey Community Chat: https://ch0.co/community
- Documentation: https://docs.chocolatey.org/
- Package guidelines: https://docs.chocolatey.org/en-us/community-repository/moderation/package-validator/rules/

### PowerShell Community
- PowerShell GitHub repository
- PowerShell community forums
- Stack Overflow with [powershell] tag

## Maintenance Tasks

### Regular Maintenance
```powershell
# Weekly maintenance script
function Invoke-WeeklyMaintenance {
    Write-Host "=== Weekly Maintenance ===" -ForegroundColor Green
    
    # Clean temporary files
    Remove-Item $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
    
    # Update Chocolatey
    choco upgrade chocolatey
    
    # Check for runner updates
    cd C:\actions-runner
    .\run.cmd --check
    
    # Clean old package artifacts
    Get-ChildItem "C:\GitHub\CocoaPods\packages" -Name "*.nupkg" | 
        Where-Object {(Get-Item $_).LastWriteTime -lt (Get-Date).AddDays(-30)} |
        Remove-Item -Force
    
    # Restart runner service
    Restart-Service -Name "actions.runner.*"
    
    Write-Host "Maintenance complete" -ForegroundColor Green
}
```

This troubleshooting guide should help you resolve most common issues with the automation system. Always check the logs first, and don't hesitate to reach out to the community for help with complex problems.
