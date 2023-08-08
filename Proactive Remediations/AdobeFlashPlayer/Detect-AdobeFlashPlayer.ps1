<#
    .SYNOPSIS
    Searches registry for Adobe Flash Player installations
#>

# Start Logging
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\$($MyInvocation.MyCommand.Name).log" -Append
Write-Output "Starting detection of Adobe Flash Player installations"

# Specify registry hives to search
Write-Output "Specify registry hives to search"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

$UninstallSearchFilter = {($_.GetValue('DisplayName') -like 'Adobe Flash Player*')}


try {
    foreach ($Path in $RegUninstallPaths){
        Get-ChildItem -Path $Path | Where-Object $UninstallSearchFilter | 
        ForEach-Object {
            Write-Output "Non Compliant: Adobe Flash Player found on device"
            Stop-Transcript
            Exit 1
        }
    }
    Write-Output "Compliant: Adobe Flash Player not found on device"
    Stop-Transcript
    Exit 0
}
catch {
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}