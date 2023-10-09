<#
    .SYNOPSIS
    Uninstalls Silverlight installations
#>

# Check if PowerShell is running as a 32-bit process and restart as a 64-bit process
if (!([System.Environment]::Is64BitProcess)) {
    if ([System.Environment]::Is64BitOperatingSystem) {
        Write-Output "Relaunching process as 64-bit process"
        $Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$($MyInvocation.MyCommand.Definition)`""
        $ProcessPath = $(Join-Path -Path $Env:SystemRoot -ChildPath "\Sysnative\WindowsPowerShell\v1.0\powershell.exe")
        $params = @{
            FilePath     = $ProcessPath
            ArgumentList = $Arguments
            Wait         = $True
            WindowStyle  = "Hidden"
        }
        Start-Process @params
        exit 0
    }
}

# Start Logging
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Resolve-Silverlight.log" -Append
Write-Output "Starting uninsatllation of Silverlight installations"

# Set search criteria  for Silverlight MSI installations
Write-Host "Identifying Silverlight installations from registry"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

$UninstallSearchFilter = {($_.GetValue('DisplayName') -like 'Microsoft Silverlight*')}

try{

    # Uninstall any Silverlight MSI installations
    foreach ($Path in $RegUninstallPaths) {
        if (Test-Path $Path) {
            Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
            foreach {
            Write-Host "Found installation: $($_.PSChildName)"
            $Arguments = '/X' + $($_.PSChildName) + ' /qn /l*v C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-3CX' + $($_.PSChildName) +'.log'
            $Uninstall = Start-Process MSIexec.exe -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
            $ReturnCode = $Uninstall.ExitCode
            Write-Host "Return Code: $ReturnCode"          
            }
        }
    }
}
catch{
    Write-Output "ERROR: Failed to uninstall Microsoft Silverlight"
    Stop-Transcript
    Write-Output "ERROR: Failed to uninstall Microsoft Silverlight"
}

Stop-Transcript
Write-Output "Successfully uninstalled Microsoft Silverlight"