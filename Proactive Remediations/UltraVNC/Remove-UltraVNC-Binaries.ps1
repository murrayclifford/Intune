<#
    .SYNOPSIS
    Deletes all legacy and orphaned UltraVNC binaries from target devices
#>

# Start Logging
Start-Transcript -Path C:\ProgramData\IntuneManagementExtension\Logs\Remove-UltraVNC.log
Write-Host "Starting removal of legacy and orphaned UltraVNC application binaries"

$AppPath = "C:\Program Files (x86)\Meraki\PCC Agent 3.0.2\winvnc.exe"

Remove-Item $AppPath -Recurse

Stop-Transcript