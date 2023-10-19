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

# Script Variables
$LogName = "Resolve-BitLockerEncryption_WinPro.log"
$LogIntro = "Starting remediation of BitLocker encryption on $Env:ComputerName"

# Start Logging
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\$LogName.log" -Append
Write-Output $LogIntro

try{
    # Check BitLocker status on device and remediate
    $BitLockerInfo = Get-BitLockerVolume

    # Check if BitLocker has already been enabled
    if($BitLokerInfo.EncryptionPercentage -eq '100'){
    	$BitLockerKey = (Get-BitLockerVolume -MountPoint $Env:SystemDrive).KeyProtector
    	$RecoveryKey = $BitLockerKey.RecoveryPassword
        BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BitLockerKey.KeyProtector[1].KeyProtectorId	
    	Write-Output "Detected: BitLocker enabled on $Env:ComputerName. BitLocker recovery key $RecoveryKey"
        Stop-Transcript
        Write-Output "Detected: BitLocker enabled on $Env:ComputerName. BitLocker recovery key $RecoveryKey"
   	    Exit 0
    }

    # Check if BitLocker is partially encrypted and restart encryption process, usually indicative of paused or interrupted process
    if($BitLockerInfo.EncryptionPercentage -ne '100' -and $BitLockerInfo.EncryptionPercentage -ne '0'){
        Write-Output "Detected: drive not fully encrypted with BitLocker. Attempting to resume encryption process"
        Resume-BitLocker -MountPoint $Env:SystemDrive
        $BitLockerVolume = Get-BitLockerVolume -MountPoint $Env:SystemDrive | select *
        BackupToAAD-BitLockerKeyProtector -MountPoint $Env:SystemDrive -KeyProtectorId $BitLockerVolume.KeyProtector[1].KeyProtectorId
        Write-Output "BitLocker encryption configured on $Env:SystemDrive for $Env:ComputerName"
        Stop-Transcript
        Write-Output "BitLocker encryption configured on $Env:SystemDrive for $Env:ComputerName"
        Exit 0
    }

    # Check whether BitLocker encryption is enabled, but protection is turned off
    if($BitLockerInfo.VolumeStatus -eq 'FullyEncrypted' -and $BitLockerInfo.ProtectionStatus -eq 'Off'){    
        Write-Output "Detected: BitLocker disk encryption not enabled for $Env:ComputerName"
        Resume-BitLocker -MountPoint "C:"
        $BitLockerVolume = Get-BitLockerVolume -MountPoint $Env:SystemDrive | select *
        BackupToAAD-BitLockerKeyProtector -MountPoint $Env:SystemDrive -KeyProtectorId $BitLockerVolume.KeyProtector[1].KeyProtectorId
        Write-Output "BitLocker encryption configured on $Env:SystemDrive for $Env:ComputerName"
        Stop-Transcript
        Write-Output "BitLocker encryption configured on $Env:SystemDrive for $Env:ComputerName"
        Exit 0
    }

    # Check if BitLocker encryption enabled for device

    if ($BitLockerInfo.EncryptionPercentage -eq '0'){
        Write-Output "Info: BitLocker encryption not enabled for $Env:ComputerSystem, attempting to enable"

        # Check TPM status on device
        $TpmStatus = Get-Tpm

        # If TPM is not owned, take ownership
        if ($TpmStatus.TpmOwnedOwned -eq 'false'){
            Write-Output "Warn: TPM not initialised on $Env:ComputerSystem, initialising"
            Initialize-Tpm
            if ((Get-Tpm).TpmOwned -eq 'true'){
                Write-Output "Info: TPM has been initialised"
            }
            else{
                Write-Output "Err: TPM has not been initialised, BitLocker cannot be enabled, exiting"
                Stop-Transcript
                Write-Output "Err: TPM has not been initialised, BitLocker cannot be enabled, exiting"
                Exit 2000
            }
        }

        # Check registry for orphaned FVE keys and remove
        $RegKey = "HKLM:\Software\Policies\Microsoft\FVE"
        Write-Output "Info: Checking for existing BitLocker registry keys on $Env:ComputerName"
        if(Test-Path $RegKey){
            Write-Output "Info: Found existing BitLocker registry keys on $Env:ComputerName, removing"
            Remove-Item -Path $RegKey -Recurse
        }
        else{
            Write-Output "Info: No existing BitLocker registry keys found on $Env:ComputerName"
        }

        # Check for BitLocker RecoveryPassword Key Protector and create if missing
        Write-Output "Info: Check for presence of RecoveryPassword BitLocker Key Protector"
        Get-BitLockerVolume | ForEach-Object {
            $RecoveryPassword = $_.KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword"}
            if ($RecoveryPassword.Count -eq 0 ){
                Write-Output "Info: RecoveryPassword BitLocker Key Protector not found on $Env:ComputerSystem, attempting to create"
                Add-BitLockerKeyProtector -MountPoint $Env:SystemDrive -RecoveryPasswordProtector -ErrorAction "Stop" | Out-Null
            }
        }
        Write-Output "Info: Attempting to escrow BitLocker RecoveryPassword to AAD"
        BackupToAAD-BitLockerKeyProtector -MountPoint $Env:SystemDrive -KeyProtectorId $BitLockerVolume.KeyProtector[1].KeyProtectorId
        Write-Output "Info: BitLocker enabled for $Env:ComputerSystem"
        Stop-Transcript
        Write-Output "BitLocker encryption enabled for $Env:ComputerName"
        Exit 0
    }
}
catch{
    Write-Warning "BitLocker remediation failed"
    $errMsg = $_.exception.message
    Write-Output $errMsg
    Stop-Transcript
    Write-Output $errMsg
    Exit 2000
}