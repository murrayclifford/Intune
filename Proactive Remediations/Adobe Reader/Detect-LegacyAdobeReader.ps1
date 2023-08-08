<#
    .SYNOPSIS
    Detects all installations on the local device matching 'Adobe Reader', 'Adobe Reader X', or 'Adobe Reader XI'
#>

Start-Transcript -Path "$Env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Detect-AdobeReader.log" -Append

if(Get-WmiObject -Class Win32_Product -Filter "Name LIKE 'Adobe Reader%'"){
    Write-Output "Adobe Reader detected"
    Exit 1
    }
else{
    Write-Output "Adobe Reader not detected"
    Exit 0
    }

Stop-Transcript