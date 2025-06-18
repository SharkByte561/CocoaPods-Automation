function Test-ChocolateyPackage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageName
    )
    
    try {
        Write-Output "🧪 Testing package installation: $PackageName"
        
        # Normalize package name
        $normalizedPackageName = $PackageName.ToLower() -replace '\s+', ''
        
        # Find package file
        $packageFile = Get-ChildItem -Path ".\packages" -Filter "$normalizedPackageName*.nupkg" | Select-Object -First 1
        if (-not $packageFile) {
            throw "Package file not found for $normalizedPackageName"
        }
        
        Write-Output "📦 Found package: $($packageFile.Name)"
        
        # Create isolated test environment
        $testPath = "$env:TEMP\choco-test-$normalizedPackageName-$(Get-Random)"
        New-Item -ItemType Directory -Path $testPath -Force | Out-Null
        Write-Output "🔧 Created test environment: $testPath"
        
        try {
            # Copy package to test directory
            Copy-Item $packageFile.FullName -Destination $testPath
            Set-Location $testPath
            
            # Test package validation
            Write-Output "🔍 Validating package structure..."
            $validateOutput = choco pack --validate-only $packageFile.Name 2>&1
            Write-Output $validateOutput
            
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "⚠️ Package validation warnings detected"
            } else {
                Write-Output "✅ Package validation passed"
            }
            
            # Test installation from local package
            Write-Output "🚀 Testing package installation..."
            $installOutput = choco install $normalizedPackageName --source . --force --yes --debug --verbose 2>&1
            Write-Output $installOutput
            
            if ($LASTEXITCODE -eq 0) {
                Write-Output "✅ Package installation test passed"
                
                # Verify software is actually installed
                Write-Output "🔍 Verifying software installation..."
                $installed = Get-Package -Name "*$normalizedPackageName*" -ErrorAction SilentlyContinue
                if ($installed) {
                    Write-Output "✅ Software verified as installed: $($installed.Name)"
                } else {
                    Write-Warning "⚠️ Software not found in installed packages list"
                }
                
                # Test uninstallation
                Write-Output "🗑️ Testing package uninstallation..."
                $uninstallOutput = choco uninstall $normalizedPackageName --yes --force 2>&1
                Write-Output $uninstallOutput
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Output "✅ Package uninstallation test passed"
                    
                    # Verify software is uninstalled
                    $stillInstalled = Get-Package -Name "*$normalizedPackageName*" -ErrorAction SilentlyContinue
                    if (-not $stillInstalled) {
                        Write-Output "✅ Software verified as uninstalled"
                    } else {
                        Write-Warning "⚠️ Software may still be present after uninstallation"
                    }
                    
                    return $true
                } else {
                    Write-Error "❌ Package uninstallation test failed (Exit code: $LASTEXITCODE)"
                    return $false
                }
            } else {
                Write-Error "❌ Package installation test failed (Exit code: $LASTEXITCODE)"
                return $false
            }
        }
        finally {
            # Return to original location
            Set-Location $env:GITHUB_WORKSPACE
            
            # Cleanup test environment
            if (Test-Path $testPath) {
                Write-Output "🧹 Cleaning up test environment..."
                Remove-Item $testPath -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
    catch {
        Write-Error "❌ Error testing package: $_"
        return $false
    }
}

function Test-PackageStructure {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageName
    )
    
    try {
        Write-Output "🔍 Testing package structure for: $PackageName"
        
        $normalizedPackageName = $PackageName.ToLower() -replace '\s+', ''
        $packagePath = ".\packages\$normalizedPackageName"
        
        # Check if package directory exists
        if (-not (Test-Path $packagePath)) {
            throw "Package directory not found: $packagePath"
        }
        
        # Check for required files
        $requiredFiles = @(
            "$packagePath\$normalizedPackageName.nuspec",
            "$packagePath\tools\chocolateyinstall.ps1"
        )
        
        foreach ($file in $requiredFiles) {
            if (-not (Test-Path $file)) {
                throw "Required file missing: $file"
            } else {
                Write-Output "✅ Found: $(Split-Path $file -Leaf)"
            }
        }
        
        # Validate nuspec content
        Write-Output "🔍 Validating .nuspec content..."
        $nuspecContent = Get-Content "$packagePath\$normalizedPackageName.nuspec" -Raw
        
        $requiredElements = @('id', 'version', 'title', 'authors', 'description')
        foreach ($element in $requiredElements) {
            if ($nuspecContent -notmatch "<$element>.*</$element>") {
                throw "Missing required element in .nuspec: $element"
            } else {
                Write-Output "✅ Found .nuspec element: $element"
            }
        }
        
        # Validate install script
        Write-Output "🔍 Validating install script..."
        $installScript = Get-Content "$packagePath\tools\chocolateyinstall.ps1" -Raw
        
        $requiredPatterns = @(
            'Install-ChocolateyPackage',
            '\$packageArgs',
            'checksum',
            'url'
        )
        
        foreach ($pattern in $requiredPatterns) {
            if ($installScript -notmatch $pattern) {
                throw "Missing required pattern in install script: $pattern"
            } else {
                Write-Output "✅ Found install script pattern: $pattern"
            }
        }
        
        Write-Output "✅ Package structure validation passed"
        return $true
    }
    catch {
        Write-Error "❌ Package structure validation failed: $_"
        return $false
    }
}

function Test-DownloadUrl {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Url
    )
    
    try {
        Write-Output "🔍 Testing download URL: $Url"
        
        # Test URL accessibility
        $response = Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing -TimeoutSec 30
        
        Write-Output "✅ URL is accessible"
        Write-Output "Status Code: $($response.StatusCode)"
        Write-Output "Content Type: $($response.Headers['Content-Type'])"
        
        if ($response.Headers['Content-Length']) {
            $sizeInMB = [math]::Round([int64]$response.Headers['Content-Length'] / 1MB, 2)
            Write-Output "Content Length: $sizeInMB MB"
        }
        
        return $true
    }
    catch {
        Write-Error "❌ URL test failed: $_"
        return $false
    }
}