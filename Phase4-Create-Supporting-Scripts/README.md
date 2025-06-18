# Phase 4: Create Supporting Scripts Instructions

## Overview
This phase creates the PowerShell scripts that handle package creation, testing, and deployment.

## Scripts Included

### 1. New-ChocolateyPackage.ps1
**Purpose**: Creates Chocolatey packages from GitHub issue data
**Key Functions**:
- `New-ChocolateyPackageFromIssue`: Main package creation function
- `Generate-NuspecFile`: Creates package specification files
- `Generate-InstallScript`: Creates installation scripts
- `Generate-UninstallScript`: Creates uninstallation scripts

### 2. Test-PackageInstallation.ps1
**Purpose**: Tests package installation and validation
**Key Functions**:
- `Test-ChocolateyPackage`: Full installation/uninstallation test
- `Test-PackageStructure`: Validates package file structure
- `Test-DownloadUrl`: Verifies download URL accessibility

### 3. Deploy-Package.ps1
**Purpose**: Deploys packages to Chocolatey repository
**Key Functions**:
- `Deploy-ChocolateyPackage`: Pushes packages to Chocolatey.org
- `Test-ChocolateyAPIKey`: Validates API key configuration
- `Get-PackageUploadStatus`: Checks package availability

## Step-by-Step Instructions

### Method 1: Using the Copy Script (Recommended)
1. Copy all files from this Phase 4 folder to your repository root
2. Run the copy script:
```powershell
.\copy-scripts.ps1
```

### Method 2: Manual Copy
1. Navigate to your CocoaPods repository directory
2. Create `scripts` directory if it doesn't exist
3. Copy each PowerShell script to the `scripts` folder

## Script Details

### New-ChocolateyPackage.ps1
This script handles the core package creation logic:

**Input Parameters**:
- `PackageName`: Name of the package
- `Version`: Package version
- `DownloadUrl`: URL to download the installer
- `Description`: Package description
- `InstallerType`: Type of installer (EXE, MSI, ZIP)
- `SilentArgs`: Silent installation arguments
- `IssueNumber`: GitHub issue number for tracking

**Process**:
1. Normalizes package name (lowercase, no spaces)
2. Downloads installer to calculate SHA256 checksum
3. Generates .nuspec package specification
4. Creates installation and uninstallation scripts
5. Builds the Chocolatey package (.nupkg file)

### Test-PackageInstallation.ps1
This script validates package quality and functionality:

**Test Functions**:
- **Package Structure**: Validates required files exist
- **Content Validation**: Checks .nuspec and script content
- **Installation Test**: Tests actual package installation
- **Uninstallation Test**: Verifies clean removal
- **URL Accessibility**: Confirms download links work

### Deploy-Package.ps1
This script handles publishing to Chocolatey.org:

**Deployment Process**:
1. Configures Chocolatey API key
2. Tests API key validity
3. Pushes package to repository
4. Waits for package indexing
5. Verifies package availability

## Testing Scripts Locally

You can test the scripts manually before using them in the workflow:

```powershell
# Load the functions
. .\scripts\New-ChocolateyPackage.ps1
. .\scripts\Test-PackageInstallation.ps1

# Test package creation
$testParams = @{
    PackageName = "test-app"
    Version = "1.0.0"
    DownloadUrl = "https://example.com/installer.exe"
    Description = "Test application"
    InstallerType = "EXE (Silent install)"
    SilentArgs = "/S"
    IssueNumber = 1
}

New-ChocolateyPackageFromIssue @testParams

# Test the created package
Test-ChocolateyPackage -PackageName "test-app"
```

## Directory Structure After This Phase
```
your-repo/
├── .github/
│   ├── workflows/
│   │   └── create-package.yml
│   └── ISSUE_TEMPLATE/
│       └── package-request.yml
├── scripts/
│   ├── New-ChocolateyPackage.ps1        ✅ NEW
│   ├── Test-PackageInstallation.ps1     ✅ NEW
│   └── Deploy-Package.ps1               ✅ NEW
├── templates/
├── packages/
└── ...
```

## Error Handling

The scripts include comprehensive error handling:
- Download failures (network issues, invalid URLs)
- Package creation errors (invalid metadata, missing files)
- Installation test failures (silent args, compatibility)
- Deployment issues (API key problems, validation errors)

## Security Features

- Checksum validation for downloaded files
- Safe temporary file handling
- Isolated test environments
- Secure API key management

## Next Steps
1. Test script loading and basic functionality
2. Proceed to Phase 5: Configuration and Secrets
3. Set up Chocolatey API key for deployment

## Git Commands
```bash
git add scripts/
git commit -m "Add PowerShell scripts for package automation"
git push origin main
```
