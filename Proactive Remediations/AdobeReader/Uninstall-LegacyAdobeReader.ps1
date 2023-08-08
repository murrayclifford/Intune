<#
        .SYNOPSIS
        Script performs a search across the registry on the local device for the defined applications
#>

# Start Logging
Start-Transcript -Path $Env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-LegacyAdobeReader.log
Write-Output "Starting legacy Adobe Reader removal process"

# Define registry uninstall paths to be searched

Write-Output "Identifying legacy Adobe Reader installations from registry"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Search defined registry uninstall locations and uninstall any Adobe Reader installations

$UninstallSearchFilter = {($_.GetValue('DisplayName') -like 'Adobe Reader%') -OR ($_.GetValue('DisplayName') -like 'Adobe Reader X%') -OR ($_.GetValue('DisplayName') -like 'Adobe Reader XI%')}

foreach ($Path in $RegUninstallPaths) {
    if (Test-Path $Path) {
        Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
        ForEach-Object {
        Write-Host "Found installation: $($_.PSChildName)"
        $Arguments = '/X' + $($_.PSChildName) + ' /qn /l*v C:\Windows\CCM\Logs\Uninstall-LegacyAdobeReader' + $($_.PSChildName) +'.log'
        $Uninstall = Start-Process MSIexec.exe -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
        $ReturnCode = $Uninstall.ExitCode
        Write-Host "Return Code: $ReturnCode"
        }
    }
}

Stop-Transcript