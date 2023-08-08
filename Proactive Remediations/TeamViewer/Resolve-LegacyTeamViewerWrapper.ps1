<#
    .SYNOPSIS
    Searches registry for TeamViewer MSI Wrapper installations and uninstalls any found
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\$($MyInvocation.MyCommand.Name).log"
Write-Output "Starting detection of legacy TeamViewer MSI Wrapper installations"

# Specify registry hives to search
Write-Output "Specify registry hives to search"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

$UninstallSearchFilter = {($_.GetValue('DisplayName') -like 'TeamViewer *(MSI Wrapper)')}

# Loop through the specified paths and filter results based on search criteria. Uninstall any instances of the application that are found
foreach ($Path in $RegUninstallPaths) {
    if (Test-Path $Path) {
        Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
        foreach {
        Write-Host "Found installation: $($_.PSChildName)"
        $Arguments = '/X' + $($_.PSChildName) + ' /qn /l*v C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-TeamViewerMSIWrapper' + $($_.PSChildName) +'.log'
        $Uninstall = Start-Process MSIexec.exe -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
        $ReturnCode = $Uninstall.ExitCode
        Write-Host "Return Code: $ReturnCode"
        }
    }
}

Stop-Transcript