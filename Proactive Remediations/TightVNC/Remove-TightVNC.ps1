<#
    .SYNOPSIS
    Uninstalls any TightVNC applications on the target device
#>

# Start script logging
Start-Transcript -Path C:\Windows\CCM\Logs\Remove-TightVNC.log
Write-Output "Starting removal of Tight VNC application on device"

# Gather TightVNC installation information from registry
Write-Host "Identifying TightVNC installations from registry"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Uninstall TightVNC from the device
$UninstallSearchFilter = {($_.GetValue('DisplayName') -like '*VNC*')}

foreach ($Path in $RegUninstallPaths) {
    if (Test-Path $Path) {
        Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
        ForEach-Object {
        Write-Host "Found installation: $($_.PSChildName)"
        $Arguments = '/X' + $($_.PSChildName) + ' /qn /l*v C:\Windows\CCM\Logs\Uninstall-TightVNC' + $($_.PSChildName) +'.log'
        $Uninstall = Start-Process MSIexec.exe -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
        $ReturnCode = $Uninstall.ExitCode
        Write-Host "Return Code: $ReturnCode"
        }
    }
}