# Phase 4: Create Supporting Scripts - Copy Scripts
# Run this script from your CocoaPods repository root directory

Write-Host "=== Phase 4: Create Supporting Scripts ===" -ForegroundColor Green

# Verify we're in the right directory
if (-not (Test-Path ".git")) {
    Write-Error "This script must be run from the root of your Git repository"
    exit 1
}

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow

# Create scripts directory if it doesn't exist
Write-Host "Creating scripts directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "scripts" -Force | Out-Null

# Define script files to copy
$scriptFiles = @(
    @{ Source = "New-ChocolateyPackage.ps1"; Destination = "scripts\New-ChocolateyPackage.ps1" },
    @{ Source = "Test-PackageInstallation.ps1"; Destination = "scripts\Test-PackageInstallation.ps1" },
    @{ Source = "Deploy-Package.ps1"; Destination = "scripts\Deploy-Package.ps1" }
)

# Copy each script file
foreach ($script in $scriptFiles) {
    Write-Host "Copying $($script.Source)..." -ForegroundColor Yellow
    
    if (Test-Path $script.Source) {
        Copy-Item $script.Source $script.Destination -Force
        Write-Host "✅ Copied to $($script.Destination)" -ForegroundColor Green
    } else {
        Write-Warning "⚠️ Source file not found: $($script.Source)"
    }
}

# Test that scripts can be loaded
Write-Host "Testing script loading..." -ForegroundColor Yellow

try {
    # Test New-ChocolateyPackage.ps1
    . .\scripts\New-ChocolateyPackage.ps1
    if (Get-Command New-ChocolateyPackageFromIssue -ErrorAction SilentlyContinue) {
        Write-Host "✅ New-ChocolateyPackage.ps1 loads successfully" -ForegroundColor Green
    } else {
        Write-Warning "⚠️ New-ChocolateyPackage.ps1 function not found"
    }
    
    # Test Test-PackageInstallation.ps1
    . .\scripts\Test-PackageInstallation.ps1
    if (Get-Command Test-ChocolateyPackage -ErrorAction SilentlyContinue) {
        Write-Host "✅ Test-PackageInstallation.ps1 loads successfully" -ForegroundColor Green
    } else {
        Write-Warning "⚠️ Test-PackageInstallation.ps1 function not found"
    }
    
    # Test Deploy-Package.ps1
    . .\scripts\Deploy-Package.ps1
    if (Get-Command Deploy-ChocolateyPackage -ErrorAction SilentlyContinue) {
        Write-Host "✅ Deploy-Package.ps1 loads successfully" -ForegroundColor Green
    } else {
        Write-Warning "⚠️ Deploy-Package.ps1 function not found"
    }
}
catch {
    Write-Error "❌ Error testing script loading: $_"
}

Write-Host "✅ Supporting scripts setup complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review the copied script files" -ForegroundColor White
Write-Host "2. Test the scripts locally if desired" -ForegroundColor White
Write-Host "3. Proceed to Phase 5: Configuration and Secrets" -ForegroundColor White
