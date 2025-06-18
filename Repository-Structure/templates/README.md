# Templates Directory

This directory contains template files used for package generation.

## Files
- `package.nuspec.template` - Template for package specification files
- `chocolateyinstall.ps1.template` - Template for installation scripts
- `chocolateyuninstall.ps1.template` - Template for uninstallation scripts

These templates are used by the PowerShell scripts to generate consistent package structures.

## Usage
Templates are processed by the `New-ChocolateyPackage.ps1` script which:
1. Replaces placeholder variables with actual values
2. Generates package-specific content
3. Creates properly formatted Chocolatey packages

## Template Variables
Common variables used in templates:
- `$PackageName` - Normalized package name
- `$Version` - Package version
- `$Description` - Package description
- `$DownloadUrl` - Installer download URL
- `$Checksum` - SHA256 checksum
- `$SilentArgs` - Silent installation arguments
- `$IssueNumber` - GitHub issue number

## Future Enhancements
Templates can be extended to support:
- Custom license handling
- Dependency management
- Multiple installer types
- Advanced configuration options
