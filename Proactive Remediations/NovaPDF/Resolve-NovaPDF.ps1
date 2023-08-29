<#
    .SYNOPSIS
    Uninstalls Nova PDF OEM installations
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Resolve-NovePDF.log" -Append
Write-Output "Starting uninsatllation Nova PDF OEM installations"

# Set uninstall variables for Nova PDF OEM
$UninstallBinary = "$env:SystemDrive\Program Files\Softland\novaPDF OEM 7\unins000.exe"

# Begin uninstall process
try{
    if(Test-Path $UninstallBinary){
        Write-Output "Found Nova PDF OEM uninstall binary on $env:ComputerName"
        Start-Process $UninstallBinary -ArgumentList "/SILENT" -Wait
        Write-Output "Removal of Nova PDF OEM complete"
    }
}
catch{
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}

Stop-Transcript