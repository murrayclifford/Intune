<#
    .SYNOPSIS
    Searches registry for UltraVNC binaries
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Resolve-UltraVNC.log" -Append
Write-Output "Starting detection of UltraVNC binaries"

# Specify UltraVNC binary location
$Path = "C:\Program Files (x86)\Meraki\PCC Agent 3.0.2\winvnc.exe"

try {
    if(Test-Path $Path){
        Write-Output "Non Compliant: UltraVNC binaries found on device. Removing"
        Remove-Item -Path $Path -Force
    }
}
catch {
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}

Stop-Transcript