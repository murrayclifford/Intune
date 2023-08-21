<#
    .SYNOPSIS
    Removes Mitel Client Component Pack registry keys from target devices
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Resolve-MitelClientComponentKeys.log"
Write-Output "Starting removal of Mitel Client Component Pack registry keys from device"

# Define registry keys
$MitelPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1c2068e9-1fc3-4a37-a67e-d1fdd6a332e0}"

Try{
    if(Test-Path $MitelPath){
        Write-Output "Removing $MitelPath"
        Get-Item $MitelPath | Remove-Item -Force -Recurse -Confirm:$False
        }
    Stop-Transcript
    Exit 0
}
Catch{
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}