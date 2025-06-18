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

## Generated Files

### .nuspec File
Contains package metadata including:
- Package ID and version
- Description and tags
- Author information
- Dependencies

### tools/chocolateyinstall.ps1
Installation script that:
- Downloads the installer
- Validates checksums
- Performs silent installation
- Handles error conditions

### tools/chocolateyuninstall.ps1
Uninstallation script that:
- Locates installed software
- Performs silent uninstallation
- Cleans up registry entries

## Package Naming
- Package names are normalized to lowercase
- Spaces are removed
- Special characters are handled appropriately
