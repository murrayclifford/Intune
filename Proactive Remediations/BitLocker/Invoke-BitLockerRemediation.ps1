<#
    .SYNOPSIS
    Checks current BitLocker configuration, enables or resumes BitLocker, and escrows recovery keys
    to Azure AD.

#>

Start-Transcript -Path "$Env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Invoke-BitLockerRemediation.log"

$BLinfo = Get-Bitlockervolume

Write-Host "Checking BitLocker status on $Env:ComputerName"

if($BLinfo.EncryptionPercentage -ne '100' -and $BLinfo.EncryptionPercentage -ne '0'){
    Write-Host "BitLocker encryption not complete. Resuming encryption."
    Resume-BitLocker -MountPoint "C:"
    $BLV = Get-BitLockerVolume -MountPoint "C:" | Select-Object *
    BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
    }

if($BLinfo.VolumeStatus -eq 'FullyEncrypted' -and $BLinfo.ProtectionStatus -eq 'Off'){
    Write-Host "BitLocker encryption complete, but not enabled. Resuming protection."
    Resume-BitLocker -MountPoint "C:"
    $BLV = Get-BitLockerVolume -MountPoint "C:" | Select-Object *
    BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
    }

if($BLinfo.EncryptionPercentage -eq '0'){
    Write-Host "BitLocker encryption not started. Enabling BitLocker."
    Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly -SkipHardwareTest -RecoveryPasswordProtector
    $BLV = Get-BitLockerVolume -MountPoint "C:" | Select-Object *
    BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
    }

if($BLinfo.EncryptionPercentage -eq '100'){
    Write-Host "BitLocker encryption complete, recovery keys cannot be found in Azure AD. Escrowing recovery keys to Azure AD."
    $BLV = Get-BitLockerVolume -MountPoint "C:" | Select-Object *
    BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
    }

Stop-Transcript