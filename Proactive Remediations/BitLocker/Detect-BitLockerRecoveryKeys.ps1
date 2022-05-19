<#
    .SYNOPSIS
    Checks Event Logs for issues with escrow of BitLocker recovery keys to Azure AD

    Script sourced from: https://call4cloud.nl/2021/02/b-for-bitlocker/#part4

#>

Start-Transcript -Path "$Env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Detect-BitLockerRecoveryKeys.log"

Try {
    $Result = Get-WinEvent -FilterHashTable @{LogName = "Microsoft-Windows-BitLocker/BitLocker Management"; StartTime = (Get-Date).Addseconds(-86400) } | Where-Object { ($_.id -eq 846) } | Format-Table message
    $ID = $Result | Measure-Object
    If ($ID.Count -lt 5) {
        Write-Output "Bitlocker backup to azure add succeeded"
        Exit 0
    }
    Else {
        Write-Output $result
        Exit 1
    }
}
    
catch
{
    Write-Warning "Value Missing"
    Exit 1
}

Stop-Transcript