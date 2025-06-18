# Phase 1: Environment Preparation - Repository Setup
# Run this script in your desired working directory

param(
    [Parameter(Mandatory=$false)]
    [string]$WorkingDirectory = "C:\GitHub"
)

Write-Host "=== Phase 1: Repository Setup ===" -ForegroundColor Green

# Create working directory if it doesn't exist
if (-not (Test-Path $WorkingDirectory)) {
    Write-Host "Creating working directory: $WorkingDirectory" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $WorkingDirectory -Force
}

# Navigate to working directory
Set-Location $WorkingDirectory
Write-Host "Working in directory: $(Get-Location)" -ForegroundColor Yellow

# Clone the repository
Write-Host "Cloning CocoaPods repository..." -ForegroundColor Yellow
git clone https://github.com/SharkByte561/CocoaPods.git
Set-Location "CocoaPods"

# Create required directory structure
Write-Host "Creating directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path ".github\workflows" -Force
New-Item -ItemType Directory -Path ".github\ISSUE_TEMPLATE" -Force
New-Item -ItemType Directory -Path "scripts" -Force
New-Item -ItemType Directory -Path "templates" -Force
New-Item -ItemType Directory -Path "packages" -Force

Write-Host "✅ Repository setup complete!" -ForegroundColor Green
Write-Host "Repository location: $(Get-Location)" -ForegroundColor Cyan
