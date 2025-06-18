# Phase 2: Repository Configuration Instructions

## Overview
This phase sets up the GitHub repository with the necessary configuration files for the automation workflow.

## Files to Copy

### 1. Issue Template (`package-request.yml`)
- Copy to: `.github/ISSUE_TEMPLATE/package-request.yml`
- Purpose: Creates a structured form for users to request new packages

### 2. GitHub Actions Workflow (`create-package.yml`)
- Copy to: `.github/workflows/create-package.yml`
- Purpose: Main automation workflow that processes package requests

## Step-by-Step Instructions

### Method 1: Using the Copy Script (Recommended)
1. Copy all files from this Phase 2 folder to your repository root
2. Run the copy script:
```powershell
.\copy-files.ps1
```

### Method 2: Manual Copy
1. Navigate to your CocoaPods repository directory
2. Copy `package-request.yml` to `.github/ISSUE_TEMPLATE/package-request.yml`
3. Copy `create-package.yml` to `.github/workflows/create-package.yml`

## What These Files Do

### Issue Template (`package-request.yml`)
- Creates a user-friendly form for package requests
- Collects necessary information:
  - Package name
  - Version
  - Download URL
  - Description
  - Installer type
  - Silent install arguments
- Automatically applies the `package-request` label

### Workflow (`create-package.yml`)
- Triggers when issues are created with `package-request` label
- Runs on self-hosted runner with Windows and Chocolatey
- Parses issue content to extract package details
- Validates download URLs
- Generates Chocolatey packages
- Tests package installation
- Uploads artifacts
- Updates issues with results
- Optionally deploys to Chocolatey.org

## Directory Structure After This Phase
```
your-repo/
├── .github/
│   ├── workflows/
│   │   └── create-package.yml
│   └── ISSUE_TEMPLATE/
│       └── package-request.yml
├── scripts/              (created, ready for Phase 4)
├── templates/            (created, ready for Phase 4)
├── packages/             (created, for generated packages)
└── ...
```

## Verification
After copying files, verify the structure:
```powershell
Get-ChildItem -Recurse .github
```

You should see both the workflow and issue template files.

## Next Steps
1. Commit and push changes to GitHub
2. Proceed to Phase 3: Self-Hosted Runner Setup

## Git Commands
```bash
git add .
git commit -m "Add GitHub Actions automation for Chocolatey packages"
git push origin main
```
