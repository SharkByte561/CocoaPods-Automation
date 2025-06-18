# Phase 1: Environment Preparation - PowerShell Setup
# Run this script as Administrator

Write-Host "=== Phase 1: PowerShell Environment Setup ===" -ForegroundColor Green

# Step 1: Configure PowerShell Execution Policy
Write-Host "Configuring PowerShell execution policy..." -ForegroundColor Yellow
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

# Verify PowerShell version
Write-Host "PowerShell Version:" -ForegroundColor Yellow
$PSVersionTable.PSVersion

# Verify execution policy
Write-Host "Current Execution Policies:" -ForegroundColor Yellow
Get-ExecutionPolicy -List

Write-Host "✅ PowerShell configuration complete!" -ForegroundColor Green
