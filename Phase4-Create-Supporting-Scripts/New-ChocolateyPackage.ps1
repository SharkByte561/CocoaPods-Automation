function New-ChocolateyPackageFromIssue {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageName,
        
        [Parameter(Mandatory=$true)]
        [string]$Version,
        
        [Parameter(Mandatory=$true)]
        [string]$DownloadUrl,
        
        [Parameter(Mandatory=$true)]
        [string]$Description,
        
        [Parameter(Mandatory=$false)]
        [string]$InstallerType = "EXE (Silent install)",
        
        [Parameter(Mandatory=$false)]
        [string]$SilentArgs = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-",
        
        [Parameter(Mandatory=$true)]
        [int]$IssueNumber
    )
    
    try {
        Write-Output "Creating Chocolatey package: $PackageName v$Version"
        
        # Normalize package name (lowercase, no spaces)
        $normalizedPackageName = $PackageName.ToLower() -replace '\s+', ''
        
        # Create package directory structure
        $packagePath = ".\packages\$normalizedPackageName"
        $toolsPath = "$packagePath\tools"
        
        New-Item -ItemType Directory -Path $packagePath -Force | Out-Null
        New-Item -ItemType Directory -Path $toolsPath -Force | Out-Null
        
        Write-Output "Package directory created: $packagePath"
        
        # Download and calculate checksums
        Write-Output "Downloading package file for checksum calculation..."
        $tempFile = "$env:TEMP\$normalizedPackageName-temp-$(Get-Random).exe"
        
        try {
            Invoke-WebRequest -Uri $DownloadUrl -OutFile $tempFile -UseBasicParsing -TimeoutSec 300
            $checksum = (Get-FileHash -Path $tempFile -Algorithm SHA256).Hash
            $fileSize = (Get-Item $tempFile).Length
            Write-Output "✅ Checksum calculated: $checksum"
            Write-Output "📦 File size: $([math]::Round($fileSize / 1MB, 2)) MB"
        }
        catch {
            throw "Failed to download file for checksum: $_"
        }
        finally {
            if (Test-Path $tempFile) {
                Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
            }
        }
        
        # Determine file type and silent args
        $fileType = "EXE"
        $actualSilentArgs = $SilentArgs
        
        if ($InstallerType -like "*MSI*") {
            $fileType = "MSI"
            $actualSilentArgs = "/quiet /norestart"
        }
        elseif ($InstallerType -like "*ZIP*") {
            $fileType = "ZIP"
            $actualSilentArgs = ""
        }
        
        # Generate .nuspec file
        $nuspecContent = Generate-NuspecFile -PackageName $normalizedPackageName -Version $Version -Description $Description -IssueNumber $IssueNumber
        $nuspecPath = "$packagePath\$normalizedPackageName.nuspec"
        Set-Content -Path $nuspecPath -Value $nuspecContent -Encoding UTF8
        Write-Output "✅ .nuspec file created"
        
        # Generate install script
        $installScript = Generate-InstallScript -PackageName $normalizedPackageName -DownloadUrl $DownloadUrl -Checksum $checksum -FileType $fileType -SilentArgs $actualSilentArgs
        $installScriptPath = "$toolsPath\chocolateyinstall.ps1"
        Set-Content -Path $installScriptPath -Value $installScript -Encoding UTF8BOM
        Write-Output "✅ Install script created"
        
        # Generate uninstall script if needed
        if ($fileType -eq "EXE") {
            $uninstallScript = Generate-UninstallScript -PackageName $normalizedPackageName
            $uninstallScriptPath = "$toolsPath\chocolateyuninstall.ps1"
            Set-Content -Path $uninstallScriptPath -Value $uninstallScript -Encoding UTF8BOM
            Write-Output "✅ Uninstall script created"
        }
        
        # Build package
        $originalLocation = Get-Location
        try {
            Set-Location $packagePath
            Write-Output "🔨 Building Chocolatey package..."
            
            $packOutput = choco pack --output-directory ".." 2>&1
            Write-Output $packOutput
            
            if ($LASTEXITCODE -eq 0) {
                Write-Output "✅ Package created successfully: $normalizedPackageName v$Version"
                
                # Verify package file exists
                $packageFile = Get-ChildItem -Path ".." -Filter "$normalizedPackageName*.nupkg" | Select-Object -First 1
                if ($packageFile) {
                    Write-Output "📦 Package file: $($packageFile.FullName)"
                    Write-Output "📊 Package size: $([math]::Round($packageFile.Length / 1KB, 2)) KB"
                }
                
                return $true
            } else {
                Write-Error "❌ Package creation failed with exit code: $LASTEXITCODE"
                Write-Error $packOutput
                return $false
            }
        }
        finally {
            Set-Location $originalLocation
        }
    }
    catch {
        Write-Error "❌ Error creating package: $_"
        return $false
    }
}

function Generate-NuspecFile {
    param(
        [string]$PackageName,
        [string]$Version,
        [string]$Description,
        [int]$IssueNumber
    )
    
    $sanitizedDescription = $Description -replace '"', '&quot;' -replace '<', '&lt;' -replace '>', '&gt;'
    $currentYear = (Get-Date).Year
    
    $template = @"
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd">
  <metadata>
    <id>$PackageName</id>
    <version>$Version</version>
    <title>$($PackageName -replace '-', ' ' | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) })</title>
    <authors>Automated Package Creator</authors>
    <owners>SharkByte561</owners>
    <description>$sanitizedDescription

This package was automatically created from GitHub Issue #$IssueNumber.
    </description>
    <summary>$($sanitizedDescription.Substring(0, [Math]::Min(150, $sanitizedDescription.Length)))</summary>
    <tags>automated github-actions chocolatey $PackageName</tags>
    <packageSourceUrl>https://github.com/SharkByte561/CocoaPods/issues/$IssueNumber</packageSourceUrl>
    <projectUrl>https://github.com/SharkByte561/CocoaPods</projectUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <copyright>© $currentYear Automated Package Creator</copyright>
  </metadata>
  <files>
    <file src="tools\**" target="tools" />
  </files>
</package>
"@
    
    return $template
}

function Generate-InstallScript {
    param(
        [string]$PackageName,
        [string]$DownloadUrl,
        [string]$Checksum,
        [string]$FileType,
        [string]$SilentArgs
    )
    
    $template = @"
`$ErrorActionPreference = 'Stop'
`$packageName = '$PackageName'
`$toolsDir = "`$(Split-Path -parent `$MyInvocation.MyCommand.Definition)"
`$url = '$DownloadUrl'

Write-Host "Installing `$packageName..." -ForegroundColor Green

`$packageArgs = @{
  packageName   = `$packageName
  fileType      = '$FileType'
  url           = `$url
  silentArgs    = '$SilentArgs'
  validExitCodes= @(0, 3010, 1641)
  softwareName  = '$PackageName*'
  checksum      = '$Checksum'
  checksumType  = 'sha256'
}

# Log installation details
Write-Host "Package: `$(`$packageArgs.packageName)" -ForegroundColor Yellow
Write-Host "URL: `$(`$packageArgs.url)" -ForegroundColor Yellow
Write-Host "File Type: `$(`$packageArgs.fileType)" -ForegroundColor Yellow
Write-Host "Silent Args: `$(`$packageArgs.silentArgs)" -ForegroundColor Yellow

try {
    Install-ChocolateyPackage @packageArgs
    Write-Host "`$packageName has been installed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Installation failed: `$_" -ForegroundColor Red
    throw
}
"@
    
    return $template
}

function Generate-UninstallScript {
    param(
        [string]$PackageName
    )
    
    $template = @"
`$ErrorActionPreference = 'Stop'
`$packageName = '$PackageName'
`$softwareName = '$PackageName*'

Write-Host "Uninstalling `$packageName..." -ForegroundColor Green

`$uninstalled = `$false

# Try to find the uninstaller in the registry
[array]`$key = Get-UninstallRegistryKey -SoftwareName `$softwareName

if (`$key.Count -eq 1) {
    `$key | ForEach-Object {
        `$packageArgs = @{
            packageName    = `$packageName
            fileType       = 'EXE'
            silentArgs     = "`$(`$_.PSChildName) /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-"
            file           = "`$(`$_.UninstallString)"
            validExitCodes = @(0, 3010, 1605, 1614, 1641)
        }
        
        if (`$_.UninstallString -match 'msiexec') {
            `$packageArgs.fileType = 'MSI'
            `$packageArgs.silentArgs = "`$(`$_.PSChildName) /quiet /norestart"
        }
        
        Uninstall-ChocolateyPackage @packageArgs
        `$uninstalled = `$true
    }
} elseif (`$key.Count -eq 0) {
    Write-Warning "`$packageName has already been uninstalled by other means."
    `$uninstalled = `$true
} elseif (`$key.Count -gt 1) {
    Write-Warning "Multiple entries found for `$packageName. Please uninstall manually."
}

if (`$uninstalled) {
    Write-Host "`$packageName has been uninstalled successfully!" -ForegroundColor Green
} else {
    throw "Could not uninstall `$packageName"
}
"@
    
    return $template
}