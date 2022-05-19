<#
    .SYNOPSIS
    Attempts to escrow BitLocker recovery keys to Azure AD

    Script sourced from: https://call4cloud.nl/2021/02/b-for-bitlocker/#part4

#>

Start-Transcript -Path "$Env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Invoke-BitLockerKeyEscrow.log"

$BLV = Get-BitLockerVolume -MountPoint "C:" | select *
Write-Host "Attempt to escrow BitLocker recovery keys to Azure AD"
BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId

Stop-Transcript