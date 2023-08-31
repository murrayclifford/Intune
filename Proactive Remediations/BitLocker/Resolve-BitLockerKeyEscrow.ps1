<#
    .SYNOPSIS
    Attempts to escrow BitLocker recovery keys to Azure AD

    Script sourced from: https://call4cloud.nl/2021/02/b-for-bitlocker/#part4

    Updates:
    - Incorporate method to check BitLocker keys programatically, or confirm process has started on device
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
Start-Transcript -Path "$Env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Invoke-BitLockerKeyEscrow.log"

try{
    $BitLockerInfo = Get-BitLockerVolume -MountPoint "C:" | select *
    Write-Output "Attempt to escrow BitLocker recovery keys to Azure AD for $($env:ComputerName)"
    
    # Check if BitLocker recovery key has been created, if not, create one
    if($BitLockerInfo.KeyProtector[1].KeyProtectorId -eq $null){
            Write-Output "No BitLocker recovery password found on device. Adding BitLocker recovery key"
            Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector
            Write-Output "Checking BitLocker recovery key"
            $BitLockerInfo = Get-BitLockerVolume -MountPoint "C:" | Select *
            if($BitLockerInfo.KeyProtector[1].KeyProtectorId -eq $null){
                    Write-Output "BitLocker recovery password created, attempting to escrow BitLocker"
                    BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BitLockerKey.KeyProtector[1].KeyProtectorId
                    Write-Output "BitLocker recovery key escrow to Azure AD for $Env:ComputerName"
            }
            else{
                Write-Output "BitLocker key protector missing. Check configured BitLocker key protectors on $Env:ComputerName"
                Stop-Transcript
                Exit
            }
    }
    else{
        # Escrow BitLocker key to AAD if present on device
        Write-Output "BitLocker recovery key found on device, attempting to escrow to AAD"
        BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BitLockerKey.KeyProtector[1].KeyProtectorId
    }
}
catch{
    Write-Warning "BitLocker remediation failed"
    $errMsg = $_.exception.message
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}

Stop-Transcript