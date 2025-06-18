# CocoaPods Chocolatey Package Automation

This repository provides automated Chocolatey package creation through GitHub Issues and Actions.

## 🚀 Quick Start

1. **Create a Package Request**: Open a new issue using the "Chocolatey Package Request" template
2. **Fill in Package Details**: Provide software name, version, download URL, and description
3. **Submit Issue**: The automation will automatically create and test the package
4. **Download Package**: Artifacts are available for download from the workflow run

## 📁 Repository Structure

```
├── .github/
│   ├── workflows/
│   │   └── create-package.yml          # Main automation workflow
│   └── ISSUE_TEMPLATE/
│       └── package-request.yml         # Package request form
├── scripts/
│   ├── New-ChocolateyPackage.ps1      # Package creation logic
│   ├── Test-PackageInstallation.ps1   # Package testing functions
│   └── Deploy-Package.ps1             # Deployment automation
├── templates/                          # Template files for package generation
├── packages/                           # Generated packages directory
└── README.md
```

## 🔧 How It Works

### Issue-Driven Workflow
1. **Issue Creation**: Users create GitHub Issues with package details
2. **Automatic Trigger**: GitHub Actions detects issues with `package-request` label
3. **Content Parsing**: Workflow extracts package information from issue content
4. **Package Generation**: PowerShell scripts create Chocolatey package structure
5. **Quality Testing**: Automated testing validates package installation/uninstallation
6. **Artifact Upload**: Generated packages are uploaded as workflow artifacts
7. **Issue Updates**: Original issue is updated with build status and package information

### Self-Hosted Runner
- Runs on Windows with Chocolatey installed
- Executes PowerShell scripts for package creation
- Tests packages in isolated environments
- Optionally deploys to Chocolatey.org

## 📋 Package Request Template

When creating an issue, provide:
- **Package Name**: Software name (no spaces, lowercase preferred)
- **Version**: Software version to package
- **Download URL**: Direct link to installer (.exe, .msi)
- **Description**: Brief description of the software
- **Installer Type**: EXE, MSI, or ZIP
- **Silent Arguments**: Command line arguments for silent installation

## 🛠️ Supported Installer Types

### EXE (Silent Install)
- NSIS installers: `/S`
- Inno Setup: `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-`
- InstallShield: `/s /v"/qn"`

### MSI (Windows Installer)
- Standard MSI: `/quiet /norestart`
- Custom MSI properties supported

### ZIP (Portable)
- Portable applications
- No installation required
- Files extracted to tools directory

## 🔒 Security Features

- **Checksum Validation**: SHA256 checksums for all downloads
- **URL Verification**: Download URLs tested before package creation
- **Isolated Testing**: Packages tested in clean environments
- **Safe Cleanup**: Temporary files securely removed

## 📊 Quality Assurance

### Automated Testing
- Package structure validation
- Installation testing
- Uninstallation verification
- Registry cleanup validation

### Error Handling
- Comprehensive error reporting
- Detailed logging for troubleshooting
- Graceful failure handling
- Issue updates with error information

## 🚀 Getting Started

### Prerequisites for Self-Hosted Runner
- Windows 10/11 or Windows Server 2019+
- PowerShell 5.1 or later
- Chocolatey installed
- GitHub Actions runner configured

### For Package Requesters
1. Navigate to the [Issues](../../issues) tab
2. Click "New Issue"
3. Select "Chocolatey Package Request" template
4. Fill in the required information
5. Submit the issue

## 📈 Package Statistics

- **Total Packages Created**: Check [Packages](./packages) directory
- **Success Rate**: View [Actions](../../actions) for build history
- **Average Build Time**: Approximately 5-10 minutes per package

## 🤝 Contributing

### Package Requests
- Use the issue template for consistent formatting
- Provide accurate download URLs
- Test silent installation arguments when possible

### Code Contributions
- Fork the repository
- Create feature branches
- Submit pull requests with detailed descriptions
- Follow PowerShell best practices

## 📞 Support

### Common Issues
- Check [Troubleshooting Guide](./docs/troubleshooting.md)
- Review [Actions logs](../../actions) for error details
- Search existing [Issues](../../issues) for solutions

### Getting Help
- Create an issue for bug reports
- Use discussions for questions
- Check documentation for setup guides

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Chocolatey Community for package management standards
- GitHub Actions for automation platform
- PowerShell community for scripting best practices

---

**Note**: This automation system is designed for legitimate software packaging. Please respect software licenses and distribution rights when creating packages.
