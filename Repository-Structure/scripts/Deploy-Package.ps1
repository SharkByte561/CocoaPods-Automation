function Deploy-ChocolateyPackage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageName,
        
        [Parameter(Mandatory=$false)]
        [string]$Source = "https://push.chocolatey.org/"
    )
    
    try {
        Write-Output "🚀 Deploying package: $PackageName"
        
        # Normalize package name
        $normalizedPackageName = $PackageName.ToLower() -replace '\s+', ''
        
        # Find package file
        $packageFile = Get-ChildItem -Path ".\packages" -Filter "$normalizedPackageName*.nupkg" | Select-Object -First 1
        if (-not $packageFile) {
            throw "Package file not found for deployment: $normalizedPackageName"
        }
        
        Write-Output "📦 Found package file: $($packageFile.Name)"
        Write-Output "📊 Package size: $([math]::Round($packageFile.Length / 1KB, 2)) KB"
        
        # Check if API key is configured
        if (-not $env:CHOCOLATEY_API_KEY) {
            throw "Chocolatey API key not configured. Please set CHOCOLATEY_API_KEY environment variable."
        }
        
        # Configure API key
        Write-Output "🔑 Configuring Chocolatey API key..."
        $keyOutput = choco apikey --key $env:CHOCOLATEY_API_KEY --source $Source 2>&1
        Write-Output $keyOutput
        
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to configure API key (Exit code: $LASTEXITCODE)"
        }
        
        # Test API key validity
        Write-Output "🔍 Testing API key validity..."
        $testOutput = choco search $normalizedPackageName --source $Source --exact --limit-output 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "⚠️ API key test failed, but continuing with deployment..."
        }
        
        # Push package
        Write-Output "📤 Pushing package to Chocolatey repository..."
        $pushOutput = choco push $packageFile.FullName --source $Source --timeout 300 2>&1
        Write-Output $pushOutput
        
        if ($LASTEXITCODE -eq 0) {
            Write-Output "✅ Package deployed successfully to Chocolatey repository"
            Write-Output "🌐 Package will be available at: https://chocolatey.org/packages/$normalizedPackageName"
            Write-Output "📋 Installation command: choco install $normalizedPackageName"
            
            # Wait for package to be indexed
            Write-Output "⏳ Waiting for package to be indexed (this may take a few minutes)..."
            Start-Sleep -Seconds 30
            
            # Verify package is available
            $verifyAttempts = 0
            $maxAttempts = 10
            $packageFound = $false
            
            while ($verifyAttempts -lt $maxAttempts -and -not $packageFound) {
                Write-Output "🔍 Verification attempt $($verifyAttempts + 1)/$maxAttempts..."
                $searchResult = choco search $normalizedPackageName --source https://chocolatey.org/api/v2/ --exact --limit-output 2>&1
                
                if ($searchResult -match $normalizedPackageName) {
                    Write-Output "✅ Package verified as available on Chocolatey.org"
                    $packageFound = $true
                } else {
                    Write-Output "⏳ Package not yet indexed, waiting 30 seconds..."
                    Start-Sleep -Seconds 30
                    $verifyAttempts++
                }
            }
            
            if (-not $packageFound) {
                Write-Warning "⚠️ Package deployed but not yet visible in search. It may take up to 30 minutes to be indexed."
            }
            
            return $true
        } else {
            Write-Error "❌ Package deployment failed with exit code: $LASTEXITCODE"
            
            # Parse error messages for common issues
            if ($pushOutput -match "already exists") {
                Write-Error "💡 This version already exists. Consider incrementing the version number."
            } elseif ($pushOutput -match "unauthorized") {
                Write-Error "💡 Authorization failed. Check your API key configuration."
            } elseif ($pushOutput -match "validation") {
                Write-Error "💡 Package validation failed. Review package content and try again."
            }
            
            return $false
        }
    }
    catch {
        Write-Error "❌ Error deploying package: $_"
        return $false
    }
}

function Test-ChocolateyAPIKey {
    param(
        [Parameter(Mandatory=$false)]
        [string]$Source = "https://push.chocolatey.org/"
    )
    
    try {
        Write-Output "🔑 Testing Chocolatey API key..."
        
        if (-not $env:CHOCOLATEY_API_KEY) {
            throw "Chocolatey API key not configured"
        }
        
        # Test by attempting to list user packages
        $testOutput = choco search --source $Source --user --limit-output 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Output "✅ API key is valid"
            return $true
        } else {
            Write-Error "❌ API key test failed: $testOutput"
            return $false
        }
    }
    catch {
        Write-Error "❌ Error testing API key: $_"
        return $false
    }
}

function Get-PackageUploadStatus {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageName,
        
        [Parameter(Mandatory=$true)]
        [string]$Version
    )
    
    try {
        $normalizedPackageName = $PackageName.ToLower() -replace '\s+', ''
        
        Write-Output "🔍 Checking upload status for $normalizedPackageName v$Version..."
        
        # Search for the specific package version
        $searchResult = choco search $normalizedPackageName --version $Version --source https://chocolatey.org/api/v2/ --exact --limit-output 2>&1
        
        if ($searchResult -match "$normalizedPackageName\|$Version") {
            Write-Output "✅ Package $normalizedPackageName v$Version is available"
            return @{
                Available = $true
                Url = "https://chocolatey.org/packages/$normalizedPackageName/$Version"
            }
        } else {
            Write-Output "⏳ Package $normalizedPackageName v$Version is not yet available"
            return @{
                Available = $false
                Url = $null
            }
        }
    }
    catch {
        Write-Error "❌ Error checking package status: $_"
        return @{
            Available = $false
            Url = $null
        }
    }
}