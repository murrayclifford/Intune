<#
    .SYNOPSIS
    Searches registry for Zoom installations that match the specified version
#>

# Start Logging
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Detect-OrphanedZoomInstalls.log" -Append
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
            Write-Output "Non Compliant: Found Zoom registry keys"
            Exit 1
    }
}

Write-Output "Compliant: Zoom registry keys not found"
Exit 0

Stop-Transcript