<#
    .SYNOPSIS
    Checks the target system for TightVNC application binaries
#>

# Start script logging
Start-Transcript -Path C:\Windows\CCM\Logs\Detect-TightVNC.log
Write-Output "Starting detection of Tight VNC application on device"

# Check system for TightVNC installations
$WMIApps = Get-WmiObject Win32_Product -filter "Name LIKE '%VNC%'"

if ($wmiapps.count -eq 0){
    }
else{
    Write-host "Installed"
    }

Stop-Transcript