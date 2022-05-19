<#
    .SYNOPSIS
    Checks the target system for Meraki winvnc application binaries
#>

$AppPath = "C:\Program Files (x86)\Meraki\PCC Agent 3.0.2\winvnc.exe"

if(Test-Path -Path $AppPath){
    Write-Host "Match: detected winvnc.exe binaries on device"
    Exit 1
    }
else{
    Write-Host "No Match: did not detect winvnc.exe binaries on device"
    Exit 0
    }