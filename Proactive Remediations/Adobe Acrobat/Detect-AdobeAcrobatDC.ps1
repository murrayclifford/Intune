<#
    .SYNOPSIS
    Searches registry for Adobe Acrobat DC installations
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

# Editable variables
$App = "Visual Studio Code (User)"
$LogPath = "$($Env:ProgramData)\Microsoft\IntuneManagementExtension\Logs"
$LogName = "Detect-AdobeAcrobatDC"
$LogIntro = "INFO: Starting detection of $($App)"


# Start Logging
Start-Transcript -Path $LogPath\$LogName -Append
Write-Output $LogIntro

# Specify registry hives to search
Write-Output "Specify registry hives to search"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

$UninstallSearchFilter = {($_.GetValue('DisplayName') -like 'Adobe Acrobat') -or ($_.GetValue('DisplayName') -like 'Adobe Acrobat (64-bit)') -or ($_.GetValue('DisplayName') -like 'Adobe Acrobat DC') -or ($_.GetValue('DisplayName') -like 'Adobe Acrobat DC (64-bit)')}


try {
    foreach ($Path in $RegUninstallPaths){
        Get-ChildItem -Path $Path | Where-Object $UninstallSearchFilter | 
        ForEach-Object {
            Write-Output "INFO: Adobe Acrobat DC found on device"
            Stop-Transcript
            Write-Output "INFO: Adobe Acrobat DC found on device"
            Exit 0
        }
    }
    Write-Output "INFO: Adobe Acrobat DC not found on device"
    Stop-Transcript
    Write-Output "INFO: Adobe Acrobat DC not found on device"
    Exit 1
}
catch {
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}