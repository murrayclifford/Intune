<#
    .SYNOPSIS
    Checks whether BitLocker encryption is enabled for a device
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Detect-BitLockerEncryption.log" -Append
Write-Output "Starting detection of BitLocker encryption for Windows installations"

try{
    $BitLockerKey = (Get-BitLockerVolume -MountPoint $Env:SystemDrive).KeyProtector
    $RecoveryKey = $BitLockerKey.RecoveryPassword
    if($RecoveryKey -ne $null){
        Write-Output "Compliant: BitLocker recovery key available $Recoverykey "
        Stop-Transcript
        Exit 0
    }
    else{
        Write-Output "Non-compliant: No BitLocker recovery key available, BitLocker not enabled, starting remediation"
        Stop-Transcript
        Exit 1
    }
}
catch{
    Write-Warning "BitLocker detection failed"
    $errMsg = $_.exception.message
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}