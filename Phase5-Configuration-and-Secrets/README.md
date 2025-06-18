# Phase 5: Configuration and Secrets Instructions

## Overview
This phase configures GitHub repository secrets and settings required for the automation workflow.

## Required Secrets

### 1. Chocolatey API Key
The most important secret needed for package deployment.

**Steps to obtain and configure:**

1. **Get Chocolatey API Key**:
   - Go to https://chocolatey.org/account
   - Sign in or create an account
   - Navigate to "API Keys" section
   - Generate a new API key
   - Copy the key (it looks like: `oy2p4c...`)

2. **Add to GitHub Secrets**:
   - Go to your repository: https://github.com/SharkByte561/CocoaPods
   - Navigate to **Settings** → **Secrets and variables** → **Actions**
   - Click **New repository secret**
   - **Name**: `CHOCOLATEY_API_KEY`
   - **Value**: Your Chocolatey API key
   - Click **Add secret**

## Repository Settings

### 1. Actions Permissions
Ensure GitHub Actions can execute workflows:

1. Go to **Settings** → **Actions** → **General**
2. Under "Actions permissions":
   - Select "Allow all actions and reusable workflows"
   - Or "Allow select actions and reusable workflows" (if you prefer more control)
3. Under "Workflow permissions":
   - Select "Read and write permissions"
   - Check "Allow GitHub Actions to create and approve pull requests"

### 2. Self-Hosted Runner Configuration
Verify your runner appears in the settings:

1. Go to **Settings** → **Actions** → **Runners**
2. You should see your "windows-chocolatey" runner listed
3. Status should be "Idle" (green)

## Environment Variables (Optional)

For local testing, you may want to set environment variables:

```powershell
# Set Chocolatey API key for local testing
$env:CHOCOLATEY_API_KEY = "your-api-key-here"

# Verify it's set
$env:CHOCOLATEY_API_KEY
```

## Testing Configuration

### Test 1: Verify Secrets
Create a simple workflow to test secret access:

```yaml
name: Test Secrets
on: workflow_dispatch

jobs:
  test:
    runs-on: [self-hosted, windows, chocolatey]
    steps:
      - name: Test Secret Access
        shell: pwsh
        env:
          CHOCOLATEY_API_KEY: ${{ secrets.CHOCOLATEY_API_KEY }}
        run: |
          if ($env:CHOCOLATEY_API_KEY) {
            Write-Host "✅ Secret is configured"
            Write-Host "Key length: $($env:CHOCOLATEY_API_KEY.Length) characters"
          } else {
            Write-Host "❌ Secret not found"
          }
```

### Test 2: Verify Runner Labels
Ensure your runner has the correct labels:

1. Check runner configuration:
   ```powershell
   cd C:\actions-runner
   Get-Content .runner | ConvertFrom-Json | Select-Object name, labels
   ```

2. Expected labels: `["self-hosted", "Windows", "X64", "chocolatey"]`

## Security Best Practices

### 1. Secret Management
- Never log or expose secrets in workflow outputs
- Use secrets only in environment variables
- Rotate API keys regularly
- Limit secret access to necessary workflows only

### 2. Runner Security
- Run runner service with minimal required permissions
- Keep runner machine updated
- Monitor runner logs for suspicious activity
- Use dedicated machine for runner if possible

### 3. Repository Security
- Enable branch protection rules
- Require reviews for workflow changes
- Use environment protection rules for deployment
- Monitor repository access and permissions

## Verification Steps

### 1. Check Repository Secrets
```powershell
# This won't show the actual secret values, but confirms they exist
# Go to: Settings → Secrets and variables → Actions
# You should see: CHOCOLATEY_API_KEY
```

### 2. Test Runner Connection
```powershell
cd C:\actions-runner
.\run.cmd --once
# Should connect successfully and show "Listening for Jobs"
```

### 3. Test Workflow Trigger
- Create a test issue with the package request template
- Verify the workflow starts automatically
- Check that it can access secrets and execute on your runner

## Common Issues and Solutions

### Issue: "Secret not found"
**Solution**: 
- Verify secret name matches exactly: `CHOCOLATEY_API_KEY`
- Check repository permissions
- Ensure you're adding to repository secrets, not environment secrets

### Issue: "Runner not found"
**Solution**:
- Verify runner is online and idle
- Check runner labels match workflow requirements
- Restart runner service if needed

### Issue: "Permission denied"
**Solution**:
- Check Actions permissions in repository settings
- Verify runner service has necessary permissions
- Ensure GITHUB_TOKEN has sufficient permissions

## Next Steps
After completing this phase:
1. Proceed to Phase 6: Testing the Complete Workflow
2. Create a test package request to verify everything works
3. Monitor the first workflow execution for any issues

## Additional Configuration (Optional)

### Environment-Specific Secrets
For different deployment targets:
- `CHOCOLATEY_API_KEY_PROD`: Production API key
- `CHOCOLATEY_API_KEY_TEST`: Test repository API key

### Notification Settings
Configure notifications for workflow failures:
- Email notifications
- Slack webhooks
- Discord notifications

### Advanced Workflow Features
- Manual approval for deployment
- Package validation rules
- Automated testing in multiple environments
