<#
    .SYNOPSIS
    Uninstalls Tableau Desktop and dependencies
#>

Start-Transcript -Path C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-TableauDesktop_Script.log
Write-Host "Starting Tableau Desktop removal process"

# Check Program Data for cached Tableau installation binaries
$UninstallPath = Get-ChildItem -Path "C:\ProgramData\Package Cache\*" -Include "Tableau*.exe" -Recurse -ErrorAction SilentlyContinue

if($UninstallPath.Exists){
    Write-Output "Found $($UninstallPath.FullName), now attempting to uninstall"
    $Uninstall = Start-Process -FilePath $UninstallPath -ArgumentList "/uninstall /quiet /norestart /log C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-TableaDesktop.log" -Wait
    $ReturnCode = $Uninstall.ExitCode
    Write-Output "Return Code: $ReturnCode"
}
else {
    Write-Output "Unable to locate Tableau installation media on device, exiting"
    Exit 1
}

Stop-Transcript