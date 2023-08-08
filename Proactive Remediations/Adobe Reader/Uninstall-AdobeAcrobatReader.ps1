<#
        .SYNOPSIS
        Checks the registry of the local device for any registry keys which match the application DisplayName value and have
        a DisplayVersion value lower than specified.

        Script performs a basic remove item to clean-up these registry keys that have been missed by the application
        uninstall process.
#>

# Start Logging
Start-Transcript -Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Remove-AdobeAcrobatReaderKeys.log"

# Define paths to query for orphaned registry keys
$RegUninstallPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Define search criteria for identifying the target application
$UninstallSearchFilter = {($_.GetValue('DisplayName') -like 'Adobe Acrobat Reader*') -and (($_.GetValue('DisplayVersion') -lt '22.001.20085'))}

# Loop through the specified paths and filter results based on search criteria. Delete any keys tha have been found.
foreach ($Path in $RegUninstallPaths){
        Get-ChildItem -Path $Path | Where-Object $UninstallSearchFilter | 
        foreach {
            Write-Host "Found orphaned Adobe Acrobat Reader registry keys"
            Remove-Item -Path $Path\$($_.PSChildName) -Force -Verbose
            Write-Host "Removed orphaned Adobe Acrobat Reader registry keys"
    }
}

Stop-Transcript