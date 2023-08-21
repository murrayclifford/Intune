<#
    .SYNOPSIS
    Detects if specific Azure Information Protection installations are found on a device
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Detect-AIPRegistryKeys.log" -Append
Write-Output "Starting detection of Azure Information Protection registry keys"

Try{
    if((test-path "HKLM:\SOFTWARE\Classes\Installer\Products\801F4F7D893B2F94DA6718701439F915\") -OR 
       (test-path "HKLM:\SOFTWARE\Classes\Installer\Products\F65F5622BBD212E4F8C97DC3E24B918B\") -OR 
       (test-path "HKLM:\SOFTWARE\Classes\Installer\Products\E707FFF70B301B142A32FB2AC6E548C2\") -OR 
       (test-path "HKLM:\SOFTWARE\Classes\Installer\Products\8261127BDB542A340871CDA3100962A0\")){
        Write-Output "Non-Compliant: Found Azure Information Protection registry keys on device. Run remediation script"
        Exit 1
    }
    else{ 
        Write-Output "Compliant: Azure Information Protection registry keys not found on device"       
        Exit 0
    }
}
Catch{
    Write-Warning "Azure Information Protection registry key detection failed"
    $errMsg = $_.exception.message
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}