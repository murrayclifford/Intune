<#
    .SYNOPSIS
    Checks the target system for Meraki Systems Manager Agent installations

#>

Start-Transcript -Path "$Env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Remove-MerakiAgent.log"

# Gather Adobe Flash Player installation information from registry
Write-Output "Identifying Meraki Systems Manager Agent installations from registry"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Uninstall Meraki Systems Manager Agent
$UninstallSearchFilter = {($_.GetValue('DisplayName') -like '*Meraki Systems Manager Agent*')}

foreach ($Path in $RegUninstallPaths) {
    if (Test-Path $Path) {
        Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
        ForEach-Object {
        Write-Output "Found installation: $($_.PSChildName)"
        $Arguments = '/X' + $($_.PSChildName) + ' /qn /l*v C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Remove-MerakiAgent' + $($_.PSChildName) +'.log'
        $Uninstall = Start-Process MSIexec.exe -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
        $ReturnCode = $Uninstall.ExitCode
        Write-Output "Return Code: $ReturnCode"
        }
    }
}

Stop-Transcript