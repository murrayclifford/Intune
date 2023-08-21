<#
    .SYNOPSIS
    Checks various configurations of Microsoft Defender to determine security status and resolves issues:
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Resolve-DefenderStatus.log" -Append
Write-Output "Starting detection and remediation of Microsoft Defender status"

try{

    # Check if Windows Firewall is enabled for all profiles (Domain, Private, Public)
    Write-Output "STATUS: Checking Windows Firewall status on $($Env:ComputerName)"
    $FirewallProfiles = Get-NetFirewallProfile
    foreach($FirewallProfile in $FirewallProfiles){
        Write-Output "STATUS: Checking status of $($FirewallProfile.Name) firewall profile"
        if($FirewallProfile.Enabled -eq "False"){
            Write-Output "STATUS: $($FirewallProfile.Name) firewall profile is disabled and will be enabled"
            Set-NetFirewallProfile -Profile $FirewallProfile.Name -Enabled True
        }
        else{
            Write-Output "STATUS: $($FirewallProfile.Name) firewall profile is already enabled"
        }
    }

    # Check if Microsoft Defender Antivirus Service is running
    Write-Output "STATUS: Checking status of Microsoft Defender Antivirus Service"
    $DefenderService = Get-Service -Name WinDefend
    if($DefenderService.Status -eq "Stopped"){
        Write-Output "STATUS: $($DefenderService.Name) is stopped and will be started"
        Start-Service -Name WinDefend
    }
    else{
        Write-Output "STATUS: $($DefenderService.Name) is already running"        
    }

    # Check if Real Time Protection is enabled in Microsoft Defender
    Write-Output "STATUS: Checking the status of Microsoft Defender Real Time Protection"
    $DefenderConfig = Get-MpComputerStatus
    if($DefenderConfig.RealTimeProtectionEnabled -eq $False){
        Write-Output "STATUS: Real Time Protection is not enabled and will be enabled"
        Set-MpPreference -DisableRealtimeMonitoring $false
    }
    else{
        Write-Output "STATUS: Real Time Protection is already enabled"
    }

    # Check Microsoft Defender Antivirus signature age (assumed greater than 2 days is out of date)
    Write-Output "STATUS: Checking Microsoft Defender Antivirus security intelligence definitions age"
    if($DefenderConfig.AntivirusSignatureAge -ge "3"){
        Write-Output "STATUS: Microsoft Defender Antivirus security intelligence definitions are out of date and will be updated"
        Update-MpSignature
    }
    else{
        Write-Output "STATUS: Microsoft Defender Antivirus security intelligence definitions are up to date"
    }

}

catch{
    Write-Warning "Microsoft Defernder remediation failed"
    $errMsg = $_.exception.message
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}