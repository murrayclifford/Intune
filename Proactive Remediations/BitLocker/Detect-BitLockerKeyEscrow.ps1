<#
    .SYNOPSIS
    Checks Event Logs for issues with escrow of BitLocker recovery keys to Azure AD

    Script sourced from: https://call4cloud.nl/2021/02/b-for-bitlocker/#part4

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
Start-Transcript -Path "$Env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Detect-BitLockerKeyEscrow.log"

try{
    $Result = Get-WinEvent -FilterHashTable @{LogName = "Microsoft-Windows-BitLocker/BitLocker Management"; StartTime = (Get-Date).Addseconds(-86400) } | Where-Object { ($_.id -eq 846) } | Format-Table message
    $ID = $Result | Measure-Object
    If ($ID.Count -lt 5) {
        Write-Output "Compliant: BitLocker backup to Azure AD succeeded"
        Stop-Transcript
        Exit 0
    }
    Else {
        Write-Output "Non-compliant: unable to confirm BitLocker key backup to Azure AD"
        Stop-Transcript
        Exit 1
    }
}
    
catch
{
    Write-Warning "BitLocker remediation failed"
    $errMsg = $_.exception.message
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}