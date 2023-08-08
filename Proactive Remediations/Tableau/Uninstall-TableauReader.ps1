<#
    .SYNOPSIS
    Uninstalls Tableau Reader
#>

Start-Transcript -Path C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-TableauReader_Script.log
Write-Host "Starting Tableau Reader removal process"

# Check Program Data for cached Tableau installation binaries
$UninstallPath = Get-ChildItem -Path "C:\ProgramData\Package Cache\*" -Include "Tableau*.exe" -Recurse -ErrorAction SilentlyContinue

if($UninstallPath.Exists){
    Write-Output "Found $($UninstallPath.FullName), now attempting to uninstall"
    Start-Process -FilePath $UninstallPath -ArgumentList "/uninstall /quiet /norestart /log C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-TableaReader_App.log" -Wait
    }

else{
    Write-Output "Unable to locate Tableau installation media on device, exiting"
    Exit 1
}

Stop-Transcript