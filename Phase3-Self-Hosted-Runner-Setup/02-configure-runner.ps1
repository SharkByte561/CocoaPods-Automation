# Phase 3: Self-Hosted Runner Setup - Configuration Script
# Run this script as Administrator

param(
    [Parameter(Mandatory=$true)]
    [string]$Token,
    
    [Parameter(Mandatory=$false)]
    [string]$RunnerDirectory = "C:\actions-runner",
    
    [Parameter(Mandatory=$false)]
    [string]$RunnerName = "windows-chocolatey",
    
    [Parameter(Mandatory=$false)]
    [string]$Labels = "self-hosted,windows,chocolatey"
)

Write-Host "=== Phase 3: GitHub Actions Runner Configuration ===" -ForegroundColor Green

# Verify we're in the runner directory
if (-not (Test-Path $RunnerDirectory)) {
    Write-Error "Runner directory not found: $RunnerDirectory"
    Write-Host "Please run 01-download-runner.ps1 first"
    exit 1
}

Set-Location $RunnerDirectory

# Verify runner files exist
if (-not (Test-Path "config.cmd")) {
    Write-Error "Runner not found. Please run 01-download-runner.ps1 first"
    exit 1
}

Write-Host "Configuring runner with the following settings:" -ForegroundColor Yellow
Write-Host "Repository: https://github.com/SharkByte561/CocoaPods" -ForegroundColor Cyan
Write-Host "Runner Name: $RunnerName" -ForegroundColor Cyan
Write-Host "Labels: $Labels" -ForegroundColor Cyan

# Configure the runner
Write-Host "Running configuration..." -ForegroundColor Yellow
try {
    $configArgs = @(
        "--url", "https://github.com/SharkByte561/CocoaPods",
        "--token", $Token,
        "--name", $RunnerName,
        "--labels", $Labels,
        "--work", "_work",
        "--unattended",
        "--replace"
    )
    
    & .\config.cmd @configArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Runner configuration complete!" -ForegroundColor Green
    } else {
        Write-Error "❌ Runner configuration failed with exit code: $LASTEXITCODE"
        exit 1
    }
}
catch {
    Write-Error "Error configuring runner: $_"
    exit 1
}

Write-Host "✅ Runner configuration complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Install runner as Windows service" -ForegroundColor White
Write-Host "2. Start the service" -ForegroundColor White
Write-Host "3. Verify runner appears in GitHub" -ForegroundColor White
