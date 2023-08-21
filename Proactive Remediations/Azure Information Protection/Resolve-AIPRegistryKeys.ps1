<#
    .SYNOPSIS
    Searches registry for Azure Information Protection registry keys
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Resolve-AIPRegistryKeys.log"
Write-Output "Starting detection of Azure Information Protection registry keys"

# Define registry keys
$Reg1 = "HKLM:\SOFTWARE\Classes\Installer\Products\801F4F7D893B2F94DA6718701439F915\"
$Reg2 = "HKLM:\SOFTWARE\Classes\Installer\Products\F65F5622BBD212E4F8C97DC3E24B918B\"
$Reg3 = "HKLM:\SOFTWARE\Classes\Installer\Products\E707FFF70B301B142A32FB2AC6E548C2\"
$Reg4 = "HKLM:\SOFTWARE\Classes\Installer\Products\8261127BDB542A340871CDA3100962A0\"

Try{
    if(Test-Path $Reg1){
        Write-Output "Removing $Reg1"
        Get-Item $Reg1 | Remove-Item -Force -Recurse -Confirm:$False
        }
    if(Test-Path $Reg2){
        Write-Output "Removing $Reg2"
        Get-Item $Reg2 | Remove-Item -Force -Recurse -Confirm:$False
        }
    if(Test-Path $Reg3){
        Write-Output "Removing $Reg3"
        Get-Item $Reg3 | Remove-Item -Force -Recurse -Confirm:$False
        }
    if(Test-Path $Reg4){
        Write-Output "Removing $Reg4"
        Get-Item $Reg4 | Remove-Item -Force -Recurse -Confirm:$False
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