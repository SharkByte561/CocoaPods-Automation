# Phase 3: Self-Hosted Runner Setup - Download Script
# Run this script as Administrator

param(
    [Parameter(Mandatory=$false)]
    [string]$RunnerDirectory = "C:\actions-runner"
)

Write-Host "=== Phase 3: GitHub Actions Runner Download ===" -ForegroundColor Green

# Create runner directory
Write-Host "Creating runner directory: $RunnerDirectory" -ForegroundColor Yellow
New-Item -Path $RunnerDirectory -ItemType Directory -Force | Out-Null
Set-Location $RunnerDirectory

# Get latest runner version from GitHub API
Write-Host "Getting latest runner version..." -ForegroundColor Yellow
try {
    $apiResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/actions/runner/releases/latest"
    $latestVersion = $apiResponse.tag_name
    $downloadUrl = ($apiResponse.assets | Where-Object { $_.name -like "*win-x64*.zip" }).browser_download_url
    
    Write-Host "Latest version: $latestVersion" -ForegroundColor Cyan
    Write-Host "Download URL: $downloadUrl" -ForegroundColor Cyan
}
catch {
    Write-Warning "Could not get latest version, using fallback"
    $latestVersion = "v2.311.0"
    $downloadUrl = "https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-win-x64-2.311.0.zip"
}

# Download runner
Write-Host "Downloading GitHub Actions Runner..." -ForegroundColor Yellow
$zipFile = "actions-runner.zip"
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -UseBasicParsing
    Write-Host "✅ Download complete" -ForegroundColor Green
}
catch {
    Write-Error "Failed to download runner: $_"
    exit 1
}

# Extract runner
Write-Host "Extracting runner..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $zipFile -DestinationPath "." -Force
    Remove-Item $zipFile -Force
    Write-Host "✅ Extraction complete" -ForegroundColor Green
}
catch {
    Write-Error "Failed to extract runner: $_"
    exit 1
}

# Verify extraction
Write-Host "Verifying extraction..." -ForegroundColor Yellow
$requiredFiles = @("config.cmd", "run.cmd", "svc.sh")
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ Found: $file" -ForegroundColor Green
    } else {
        Write-Error "❌ Missing: $file"
    }
}

Write-Host "✅ Runner download and extraction complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Get registration token from GitHub" -ForegroundColor White
Write-Host "2. Run configuration script" -ForegroundColor White
Write-Host "3. Install as Windows service" -ForegroundColor White
