# Start Logging
Start-Transcript -Path C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-AdobeFlashPlayer.log
Write-Host "Starting Adobe Flash Player removal process"

# Gather Adobe Flash Player installation information from registry

Write-Host "Identifying Java installations from registry"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Define version of Adobe Flash Player to keep if necessary

#$VersionsToKeep = @('Adobe Flash Player 32 PPAPI')
#Write-Host "$VersionsToKeep has been whitelisted and will not be uninstalled."

# Uninstall unwanted Adobe Flash Player installations

$UninstallSearchFilter = {($_.GetValue('DisplayName') -like '*Adobe Flash Player*') -and ($VersionsToKeep -notcontains $_.GetValue('DisplayName'))}

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