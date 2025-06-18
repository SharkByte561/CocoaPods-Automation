# Phase 1: Environment Preparation - Git Installation
# Run this script as Administrator

Write-Host "=== Phase 1: Installing Git ===" -ForegroundColor Green

# Check if Git is already installed
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue
if ($gitInstalled) {
    Write-Host "Git is already installed: $(git --version)" -ForegroundColor Green
} else {
    Write-Host "Installing Git using winget..." -ForegroundColor Yellow
    winget install --id Git.Git -e --source winget
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    # Verify installation
    Write-Host "Verifying Git installation..." -ForegroundColor Yellow
    git --version
}

Write-Host "✅ Git installation complete!" -ForegroundColor Green
