<#
    .SYNOPSIS
    Uninstalls CutePDF Writer 2.7 installations

    .NOTES
    - CutePDF Writer 2.7 does not support silent uninstallation. Current method includes removing binaries and registry keys
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Resolve-CutePDFWriter.log" -Append
Write-Output "Starting uninsatllation CutePDF Writer 2.7 installations"

# Specify CutePDF Writer installation directory and registry keys
$InstallDir = "$env:SystemDrive\Program Files (x86)\Acro Software\CutePDF Writer"
$InstallReg = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\CutePDF Writer Installation"

try{
    # Remove CutePDF Writer installation binaries
    if(Test-Path $InstallDir){
        Write-Output "CutePDF Writer found on $env:ComputerName. Beginning removal"
        Get-ChildItem -Path $InstallDir -Recurse | Remove-Item -Force
        Write-Output "CutePDF Writer binaries removed. Cleaning installation folders"
        Remove-Item -Path "$env:ComputerSystem\Program Files (x86)\Acro Software" -Recurse
    }
    # Remove CutePDF Writer registry keys
    Write-Output "Removing CutePDF Writer installation registry keys"
    Get-Item $InstallReg | Remove-Item -Force
    Write-Output "CutePDF Writer registry keys removed"
}
catch{
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}

Stop-Transcript