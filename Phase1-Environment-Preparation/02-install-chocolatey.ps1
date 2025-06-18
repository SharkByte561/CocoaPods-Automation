# Phase 1: Environment Preparation - Chocolatey Installation
# Run this script as Administrator

Write-Host "=== Phase 1: Installing Chocolatey ===" -ForegroundColor Green

# Install Chocolatey
Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Verify installation
Write-Host "Verifying Chocolatey installation..." -ForegroundColor Yellow
choco --version

# Configure Chocolatey for automation
Write-Host "Configuring Chocolatey for automation..." -ForegroundColor Yellow
choco config set allowGlobalConfirmation true
choco config set allowEmptyChecksums true
choco config set allowEmptyChecksumsSecure true

# Install essential tools
Write-Host "Installing essential tools..." -ForegroundColor Yellow
choco install -y checksum nuget.commandline

Write-Host "✅ Chocolatey installation complete!" -ForegroundColor Green
