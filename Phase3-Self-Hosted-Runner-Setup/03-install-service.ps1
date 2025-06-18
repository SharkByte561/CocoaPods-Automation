# Phase 3: Self-Hosted Runner Setup - Service Installation Script
# Run this script as Administrator

param(
    [Parameter(Mandatory=$false)]
    [string]$RunnerDirectory = "C:\actions-runner"
)

Write-Host "=== Phase 3: GitHub Actions Runner Service Installation ===" -ForegroundColor Green

# Verify we're in the runner directory
if (-not (Test-Path $RunnerDirectory)) {
    Write-Error "Runner directory not found: $RunnerDirectory"
    exit 1
}

Set-Location $RunnerDirectory

# Verify runner is configured
if (-not (Test-Path ".runner")) {
    Write-Error "Runner not configured. Please run 02-configure-runner.ps1 first"
    exit 1
}

# Install as Windows service
Write-Host "Installing runner as Windows service..." -ForegroundColor Yellow
try {
    & .\svc.sh install
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Service installation complete!" -ForegroundColor Green
    } else {
        Write-Error "❌ Service installation failed with exit code: $LASTEXITCODE"
        exit 1
    }
}
catch {
    Write-Error "Error installing service: $_"
    exit 1
}

# Start the service
Write-Host "Starting runner service..." -ForegroundColor Yellow
try {
    & .\svc.sh start
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Service started successfully!" -ForegroundColor Green
    } else {
        Write-Error "❌ Service start failed with exit code: $LASTEXITCODE"
        exit 1
    }
}
catch {
    Write-Error "Error starting service: $_"
    exit 1
}

# Check service status
Write-Host "Checking service status..." -ForegroundColor Yellow
& .\svc.sh status

# Verify Windows service
Write-Host "Verifying Windows service..." -ForegroundColor Yellow
$service = Get-Service -Name "actions.runner.*" -ErrorAction SilentlyContinue
if ($service) {
    Write-Host "✅ Windows service found: $($service.Name)" -ForegroundColor Green
    Write-Host "Service Status: $($service.Status)" -ForegroundColor Cyan
    Write-Host "Service Start Type: $($service.StartType)" -ForegroundColor Cyan
} else {
    Write-Warning "⚠️ Windows service not found"
}

# Configure service for automatic startup
Write-Host "Configuring service for automatic startup..." -ForegroundColor Yellow
$serviceName = (Get-Service -Name "actions.runner.*").Name
if ($serviceName) {
    Set-Service -Name $serviceName -StartupType Automatic
    Write-Host "✅ Service configured for automatic startup" -ForegroundColor Green
}

Write-Host "✅ Runner service installation complete!" -ForegroundColor Green
Write-Host "Verification:" -ForegroundColor Cyan
Write-Host "1. Check GitHub repository settings for the new runner" -ForegroundColor White
Write-Host "2. Go to: https://github.com/SharkByte561/CocoaPods/settings/actions/runners" -ForegroundColor White
Write-Host "3. You should see your runner listed as 'Idle'" -ForegroundColor White
