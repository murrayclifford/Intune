<#
    .SYNOPSIS
    Searches registry for Zoom installations that match the specified version and removes orphaned registry keys
#>

# Start Logging
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\$($MyInvocation.MyCommand.Name).log"
Write-Output "Starting detection of orphaned Zoom installations"

# Specify registry hives to search
Write-Output "Specify registry hives to search"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

$UninstallSearchFilter = {($_.GetValue('DisplayName') -like 'Zoom*') -and (($_.GetValue('DisplayVersion') -le '5.9.2581'))}

# Loop through the specified paths and filter results based on search criteria. Delete any keys tha have been found.
foreach ($Path in $RegUninstallPaths){
    Get-ChildItem -Path $Path | Where-Object $UninstallSearchFilter | 
    ForEach-Object {
        Write-Output "Found orphaned Zoom registry keys"
        Remove-Item -Path $Path\$($_.PSChildName) -Force -Verbose
        Write-Output "Removed orphaned Zoom registry keys"
    }
}

Stop-Transcript