<#
    .SYNOPSIS
    Checks the target system for Meraki Systems Manager Agent installations

#>

Start-Transcript -Path "$Env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Detect-MerakiAgent.log"

Write-Output "Status: begin detection of Meraki Systems Manager Agent"
$AppDetails = (Get-ItemProperty Registry::HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*) | Where-Object { $_.DisplayName -like "*Meraki Systems Manager Agent*"}

if ($AppDetails.DisplayName){
    Write-Output "Status: Found installation of "$AppDetails.DisplayName""
    Exit 1
}
else{
    Write-Output "Status: Did not find any installations of "$AppDetails.DisplayName""
}

Stop-Transcript