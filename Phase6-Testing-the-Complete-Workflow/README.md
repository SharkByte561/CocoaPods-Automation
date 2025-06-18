# Phase 6: Testing the Complete Workflow Instructions

## Overview
This phase provides comprehensive testing procedures to verify your automation system works correctly.

## Pre-Test Checklist

Verify the following before testing:
- [ ] All scripts are in the `scripts/` directory
- [ ] GitHub Actions workflow is in `.github/workflows/create-package.yml`
- [ ] Issue template is in `.github/ISSUE_TEMPLATE/package-request.yml`
- [ ] Self-hosted runner is online and idle
- [ ] `CHOCOLATEY_API_KEY` secret is configured
- [ ] Repository permissions allow Actions to run

## Test 1: Create a Simple Test Package

### Step 1: Create Test Issue
1. Go to https://github.com/SharkByte561/CocoaPods/issues
2. Click **New Issue**
3. Select **Chocolatey Package Request**
4. Fill out with test data:

```
Package Name: notepadplusplus-test
Version: 8.6.2
Download URL: https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.2/npp.8.6.2.Installer.x64.exe
Description: Notepad++ is a free source code editor and Notepad replacement that supports several languages
Installer Type: EXE (Silent install)
Silent Install Arguments: /S
```

### Step 2: Monitor Workflow Execution
1. After creating the issue, go to **Actions** tab
2. You should see a new workflow run starting
3. Click on the workflow to see detailed logs
4. Monitor each step for success/failure

### Expected Results:
- ✅ Issue parsing succeeds
- ✅ URL validation passes
- ✅ Package creation completes
- ✅ Package testing passes
- ✅ Artifacts are uploaded
- ✅ Issue gets updated with success status

## Test 2: Test with Different Installer Types

### MSI Installer Test
Create another issue with:
```
Package Name: 7zip-test
Version: 23.01
Download URL: https://www.7-zip.org/a/7z2301-x64.msi
Description: 7-Zip is a file archiver with a high compression ratio
Installer Type: MSI (Windows Installer)
Silent Install Arguments: /quiet
```

### ZIP/Portable Test
Create another issue with:
```
Package Name: sysinternals-test
Version: 2024.01
Download URL: https://download.sysinternals.com/files/SysinternalsSuite.zip
Description: Sysinternals utilities suite for Windows administration
Installer Type: ZIP (Portable)
Silent Install Arguments: (leave blank)
```

## Test 3: Error Handling Tests

### Invalid URL Test
Create an issue with an invalid download URL to test error handling:
```
Package Name: invalid-url-test
Version: 1.0.0
Download URL: https://invalid-url-that-does-not-exist.com/installer.exe
Description: Testing invalid URL handling
Installer Type: EXE (Silent install)
Silent Install Arguments: /S
```

Expected Result: Workflow should fail gracefully and update the issue with error information.

### Missing Information Test
Create an issue with incomplete information to test validation:
- Leave Package Name blank
- Verify workflow handles missing required fields

## Test 4: Local Testing (Optional)

Test scripts locally before running in GitHub Actions:

```powershell
# Navigate to your repository
cd CocoaPods

# Load the functions
. .\scripts\New-ChocolateyPackage.ps1
. .\scripts\Test-PackageInstallation.ps1

# Test package creation locally
$testParams = @{
    PackageName = "local-test"
    Version = "1.0.0"
    DownloadUrl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.2/npp.8.6.2.Installer.x64.exe"
    Description = "Local testing package"
    InstallerType = "EXE (Silent install)"
    SilentArgs = "/S"
    IssueNumber = 999
}

# Create package
$result = New-ChocolateyPackageFromIssue @testParams
Write-Host "Package creation result: $result"

# Test package structure
if ($result) {
    Test-PackageStructure -PackageName "local-test"
}
```

## Test 5: End-to-End Deployment Test

**Warning**: This will actually deploy to Chocolatey.org. Only do this if you want to publish a real package.

1. Create a legitimate package request
2. Ensure you're the repository owner (SharkByte561)
3. Monitor the deployment step in the workflow
4. Verify the package appears on Chocolatey.org

## Monitoring and Verification

### Check Workflow Logs
1. Go to Actions tab in your repository
2. Click on the workflow run
3. Expand each step to see detailed logs
4. Look for error messages or warnings

### Verify Artifacts
1. In the completed workflow, look for "Artifacts" section
2. Download the package artifacts
3. Inspect the generated .nupkg files
4. Verify package structure and content

### Check Issue Updates
1. Go back to the original issue
2. Verify the bot comment was added
3. Check that appropriate labels were applied
4. Confirm status information is accurate

## Common Issues and Solutions

### Issue: Workflow doesn't start
**Possible Causes**:
- Issue doesn't have `package-request` label
- Runner is offline
- Workflow file has syntax errors

**Solutions**:
```powershell
# Check runner status
cd C:\actions-runner
.\svc.sh status

# Validate workflow syntax
# Use GitHub's workflow validator or local tools
```

### Issue: Package creation fails
**Common Causes**:
- Invalid download URL
- Network connectivity issues
- Chocolatey not properly installed on runner

**Debugging**:
```powershell
# Test Chocolatey on runner
choco --version
choco config list

# Test URL accessibility
Invoke-WebRequest -Uri "YOUR_URL" -Method Head
```

### Issue: Permission errors
**Solutions**:
```powershell
# Check runner service permissions
Get-Service -Name "actions.runner.*"

# Verify PowerShell execution policy
Get-ExecutionPolicy -List

# Check file system permissions
Test-Path "C:\actions-runner" -PathType Container
```

### Issue: Secrets not accessible
**Solutions**:
1. Verify secret name exactly matches `CHOCOLATEY_API_KEY`
2. Check repository permissions
3. Ensure runner has network access to api.github.com

## Performance Testing

### Load Testing
Test with multiple simultaneous package requests:
1. Create 3-5 issues quickly
2. Monitor how the runner handles multiple jobs
3. Check for any conflicts or failures

### Large Package Testing
Test with larger installer files:
1. Use a package with 100+ MB installer
2. Monitor download times and timeouts
3. Verify checksum calculation performance

## Success Criteria

A successful test should demonstrate:
- ✅ Issues trigger workflows automatically
- ✅ Package creation completes without errors
- ✅ Generated packages have correct structure
- ✅ Package testing validates installation/uninstallation
- ✅ Artifacts are uploaded and accessible
- ✅ Issues are updated with status information
- ✅ Error handling works for invalid inputs
- ✅ Multiple installer types are supported

## Test Report Template

Document your test results:

```
## Test Results - [Date]

### Test 1: Basic EXE Package
- Status: ✅ Success / ❌ Failed
- Duration: X minutes
- Issues: None / [Description]

### Test 2: MSI Package
- Status: ✅ Success / ❌ Failed
- Duration: X minutes
- Issues: None / [Description]

### Test 3: Error Handling
- Status: ✅ Success / ❌ Failed
- Error properly caught: Yes / No
- Issue updated correctly: Yes / No

### Overall Assessment
- System ready for production: Yes / No
- Recommended next steps: [List any needed improvements]
```

## Next Steps After Testing

If all tests pass:
1. Proceed to Phase 7: Production deployment
2. Create documentation for users
3. Set up monitoring and maintenance procedures

If tests fail:
1. Review error logs carefully
2. Check configuration and permissions
3. Test individual components separately
4. Seek help in GitHub Issues or community forums

## Continuous Testing

Set up regular testing:
1. Weekly test packages to ensure system health
2. Monitor for GitHub Actions updates that might break compatibility
3. Test with new Chocolatey versions
4. Validate runner security and performance monthly
