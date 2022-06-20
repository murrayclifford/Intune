# Start Logging
Start-Transcript -Path C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-AdobeAcrobatDC.log
Write-Host "Starting Adobe Acrobat DC removal process"

# Stop all Adobe services
Get-Service -DisplayName Adobe* | Stop-Service -Force

# Stop all running Adobe processes
Get-Process -Name Acrobat | Stop-Process -Force
Get-Process -Name AcroCEF | Stop-Process -Force
Get-Process -Name Acrodist | Stop-Process -Force
Get-Process -Name Acrotray | Stop-Process -Force
Get-Process -Name "adobe_licensing_wf_acro" | Stop-Process -Force
Get-Process -Name "adobe_licensing_wf_helper_acro" | Stop-Process -Force

# Gather Adobe Acrobat DC installation information from registry

Write-Host "Identifying Adobe Acrobat DC installations from registry"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Uninstall unwanted Adobe Acrobat DC installations
$UninstallSearchFilter = {($_.GetValue('DisplayName') -like '*Adobe Acrobat DC*')}

foreach ($Path in $RegUninstallPaths) {
    if (Test-Path $Path) {
        Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
        ForEach-Object {
            Write-Host "Found installation: $($_.PSChildName)"
            $Arguments = '/X' + $($_.PSChildName) + ' /qb /l*v C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-AdobeAcrobatDC' + $($_.PSChildName) +'.log'
            $Uninstall = Start-Process MSIexec.exe -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
            $ReturnCode = $Uninstall.ExitCode
            Write-Host "Return Code: $ReturnCode"
        }
    }
}

Stop-Transcript