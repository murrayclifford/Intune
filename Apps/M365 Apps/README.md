# M365 Apps for Enterprise

Application package for the Microsoft 365 Apps for Enterprise suite (x64) created with the PowerShell Application Deployment Toolkit. The package does not include a local cache of installation binaries and will instead download the latest installation source binaries from the Microsoft CDN. 

As a pre-installation step the package will check if any 32-bit or 64-bit MSI installations of Office 2013/2016 exist on the device and will run the appropriate Microsoft OffScrub scripts to remove these installtions. 

Information for the PowerShell App Deployment Toolkit can be found here: [PSAppDeployToolkit](https://psappdeploytoolkit.com/)
)
Information for Microsoft's OffScrub scripts can be found here: [Office IT Pro Deployment Scripts](https://github.com/OfficeDev/Office-IT-Pro-Deployment-Scripts/tree/master/Office-ProPlus-Deployment/Remove-PreviousOfficeInstalls 