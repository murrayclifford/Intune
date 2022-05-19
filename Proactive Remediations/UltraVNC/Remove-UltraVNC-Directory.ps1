<#
    .SYNOPSIS
    Deletes all legacy and orphaned UltraVNC binaries from target devices
#>

# Start Logging
Start-Transcript -Path C:\ProgramData\IntuneManagementExtension\Logs\Remove-UltraVNC.log
Write-Host "Starting removal of legacy and orphaned UltraVNC application binaries and installation directory"

$AppPath = "C:\Program Files (x86)\Meraki"

Remove-Item $AppPath -Recurse

Stop-Transcript