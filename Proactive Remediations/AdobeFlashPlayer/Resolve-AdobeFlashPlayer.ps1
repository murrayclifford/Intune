<#
    .SYNOPSIS
    Searches registry for Adobe Flash Player installations and uninstalls the application
#>

# Start Logging
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\$($MyInvocation.MyCommand.Name).log" -Append
Write-Output "Starting detection of Adobe Flash Player installations"

# Gather Adobe Flash Player installation information from registry

Write-Host "Identifying Java installations from registry"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Uninstall unwanted Adobe Flash Player installations

$UninstallSearchFilter = {($_.GetValue('DisplayName') -like 'Adobe Flash Player*')}

foreach ($Path in $RegUninstallPaths) {
    if (Test-Path $Path) {
        Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
        foreach {
        Write-Host "Found installation: $($_.PSChildName)"
        $Arguments = '/X' + $($_.PSChildName) + ' /qn /l*v C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-AdobeFlashPlayer' + $($_.PSChildName) +'.log'
        $Uninstall = Start-Process MSIexec.exe -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
        $ReturnCode = $Uninstall.ExitCode
        Write-Host "Return Code: $ReturnCode"
        }
    }
}

Stop-Transcript