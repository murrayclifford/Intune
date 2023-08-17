<#
    .SYNOPSIS
    Detects current version of Office installed
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Detect-OfficeUpdates.log" -Append
Write-Output "Starting detection of Office version"

# Specify registry hives to search
Write-Output "Specify registry hives to search"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

$UninstallSearchFilter = {($_.GetValue('DisplayName') -like 'Microsoft 365 Apps for enterprise*')}

try {
    Write-Output "Checking for Office update level"
    foreach ($Path in $RegUninstallPaths){
        Get-ChildItem -Path $Path | Where-Object $UninstallSearchFilter | 
        ForEach-Object {
            Write-Output "Non Compliant: Microsoft 365 requires update"
            Stop-Transcript
            Exit 1
        }
    }
    Write-Output "Compliant: Microsoft 365 does not require an update"
    Exit 0
}
catch {
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}