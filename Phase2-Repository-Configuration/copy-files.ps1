# Phase 2: Repository Configuration - Copy Files Script
# Run this script from your CocoaPods repository root directory

Write-Host "=== Phase 2: Repository Configuration ===" -ForegroundColor Green

# Verify we're in the right directory
if (-not (Test-Path ".git")) {
    Write-Error "This script must be run from the root of your Git repository"
    exit 1
}

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow

# Create directory structure if it doesn't exist
Write-Host "Creating directory structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path ".github\workflows" -Force | Out-Null
New-Item -ItemType Directory -Path ".github\ISSUE_TEMPLATE" -Force | Out-Null
New-Item -ItemType Directory -Path "scripts" -Force | Out-Null
New-Item -ItemType Directory -Path "templates" -Force | Out-Null
New-Item -ItemType Directory -Path "packages" -Force | Out-Null

# Copy issue template
Write-Host "Copying issue template..." -ForegroundColor Yellow
$issueTemplatePath = ".github\ISSUE_TEMPLATE\package-request.yml"
$issueTemplateSource = "package-request.yml"  # From Phase 2 folder

if (Test-Path $issueTemplateSource) {
    Copy-Item $issueTemplateSource $issueTemplatePath -Force
    Write-Host "✅ Issue template copied to $issueTemplatePath" -ForegroundColor Green
} else {
    Write-Warning "⚠️ Issue template source not found: $issueTemplateSource"
}

# Copy workflow
Write-Host "Copying workflow..." -ForegroundColor Yellow
$workflowPath = ".github\workflows\create-package.yml"
$workflowSource = "create-package.yml"  # From Phase 2 folder

if (Test-Path $workflowSource) {
    Copy-Item $workflowSource $workflowPath -Force
    Write-Host "✅ Workflow copied to $workflowPath" -ForegroundColor Green
} else {
    Write-Warning "⚠️ Workflow source not found: $workflowSource"
}

# Create placeholder README files
Write-Host "Creating placeholder files..." -ForegroundColor Yellow

# Create packages README
@"
# Packages Directory

This directory will contain generated Chocolatey packages.

Packages are automatically created by the GitHub Actions workflow when issues are submitted with the 'package-request' label.

## Structure
Each package will be created in its own subdirectory:
```
packages/
├── package-name-1/
│   ├── package-name-1.nuspec
│   └── tools/
│       ├── chocolateyinstall.ps1
│       └── chocolateyuninstall.ps1
├── package-name-1.1.0.0.nupkg
└── ...
```
"@ | Set-Content "packages\README.md" -Encoding UTF8

# Create templates README
@"
# Templates Directory

This directory contains template files used for package generation.

## Files
- `package.nuspec.template` - Template for package specification files
- `chocolateyinstall.ps1.template` - Template for installation scripts
- `chocolateyuninstall.ps1.template` - Template for uninstallation scripts

These templates are used by the PowerShell scripts to generate consistent package structures.
"@ | Set-Content "templates\README.md" -Encoding UTF8

Write-Host "✅ Repository configuration complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review the copied files" -ForegroundColor White
Write-Host "2. Commit and push changes to GitHub" -ForegroundColor White
Write-Host "3. Proceed to Phase 3: Self-Hosted Runner Setup" -ForegroundColor White
