# Start Logging
Start-Transcript -Path C:\Windows\CCM\Logs\Remove-JavaRuntime.log
Write-Host "Starting Java Runtime Environment removal process"

# Gather Java RE installation information from registry

Write-Host "Identifying Java installations from registry"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)