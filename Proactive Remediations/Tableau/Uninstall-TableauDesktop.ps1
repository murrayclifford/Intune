# Start Logging
Start-Transcript -Path C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-TableauDesktop.log
Write-Host "Starting Tableau Desktop removal process"

# Gather Tableau Desktop installation information from registry

Write-Host "Identifying Tableau Desktop installations from registry"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Uninstall unwanted Tableau Desktop installations

$UninstallSearchFilter = {($_.GetValue('DisplayName') -like '*Tableau*') -and ($VersionsToKeep -notcontains $_.GetValue('DisplayName'))}

foreach ($Path in $RegUninstallPaths) {
    if (Test-Path $Path) {
        Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
        foreach {
        Write-Host "Found installation: $($_.PSChildName)"
        $Arguments = '/X' + $($_.PSChildName) + ' /qn /l*v C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-TableauDesktop' + $($_.PSChildName) +'.log'
        $Uninstall = Start-Process MSIexec.exe -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
        $ReturnCode = $Uninstall.ExitCode
        Write-Host "Return Code: $ReturnCode"
        }
    }
}

Stop-Transcript