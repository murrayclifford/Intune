<#
    .SYNOPSIS
    Checks various configurations of Microsoft Defender to determine security status:
        - Windows Firewall configuration
        - Microsoft Defender Antivirus service
        - Real Time Protection
        - Microsoft Defender Antivirus security intelligence updates out of date

    .VERSION HISTORY
    v1.00 - Inital script development
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Detect-DefenderStatus.log" -Append
Write-Output "Starting detection of Microsoft Defender status"

try{

    # Check if Windows Firewall is enabled for all profiles (Domain, Private, Public)
    Write-Output "STATUS: Checking Windows Firewall status on $($Env:ComputerName)"
    $FirewallProfiles = Get-NetFirewallProfile
    foreach($FirewallProfile in $FirewallProfiles){
        Write-Output "STATUS: Checking status of $($FirewallProfile.Name) firewall profile"
        if($FirewallProfile.Enabled -eq "True"){
            Write-Output "STATUS: $($FirewallProfile.Name) firewall profile is enabled"
            $FirewallStatus = "Compliant"
        }
        else{
            Write-Output "ERROR: $($FirewallProfile.Name) firewall profile is not enabled"
            $FirewallStatus = "Non-compliant"
        }
    }

    # Check if Microsoft Defender Antivirus Service is running
    Write-Output "STATUS: Checking status of Microsoft Defender Antivirus Service"
    $DefenderService = Get-Service -Name WinDefend
    if($DefenderService.Status -eq "Running"){
        Write-Output "STATUS: $($DefenderService.Name) is running"
        $DefenderService = "Compliant"
    }
    else{
        Write-Output "ERROR: $($DefenderService.Name) is not running"
        $DefenderService = "Non-compliant"
        
    }

    # Check if Real Time Protection is enabled in Microsoft Defender
    Write-Output "STATUS: Checking the status of Microsoft Defender Real Time Protection"
    $DefenderConfig = Get-MpComputerStatus
    if($DefenderConfig.RealTimeProtectionEnabled -eq $True){
        Write-Output "STATUS: Real Time Protection is enabled"
        $RealTimeProtectionStatus = "Compliant"
    }
    else{
        Write-Output "ERROR: Real Time Protection is not enabled"
        $RealTimeProtectionStatus = "Non-compliant"
    }

    # Check Microsoft Defender Antivirus signature age (assumed greater than 2 days is out of date)
    Write-Output "STATUS: Checking Microsoft Defender Antivirus security intelligence definitions age"
    if($DefenderConfig.AntivirusSignatureAge -le "2"){
        Write-Output "STATUS: Microsoft Defender Antivirus security intelligence definitions are up to date"
        $DefenderUpdateStatus = "Compliant"
    }
    else{
        Write-Output "ERROR: Microsoft Defender Antivirus security intelligence definitions are out of date"
        $DefenderUpdateStatus = "Non-compliant"
    }

    # Determine overall compliance state based on status checks performed
    if(($FirewallStatus -eq "Compliant") -and ($DefenderService -eq "Compliant") -and ($RealTimeProtectionStatus -eq "Compliant") -and ($DefenderUpdateStatus -eq "Compliant")){
        Write-Output "STATUS: Microsoft Defender configuration is compliant for $($Env:ComputerName)"
        Exit 0
        Stop-Transcript
    }
    else{
        Write-Output "ERROR: Microsoft Defender configuration is non-compliant for $($Env:ComputerName)"
        Exit 1
        Stop-Transcript
    }

}

catch{
    Write-Warning "BitLocker detection failed"
    $errMsg = $_.exception.message
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}