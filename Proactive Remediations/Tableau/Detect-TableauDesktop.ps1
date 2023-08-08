<#
    .SYNOPSIS
    Detects all installations matching Adobe Acrobat Reader with a version greater than or equal to 22.001.20085
#>

if(Get-WmiObject -Class Win32_Product -Filter "Name like 'Tableau%'"){
    Write-Output "Tableau product detected and will now be removed"
    Exit 1
    }
else{
    Write-Output "Tableau products not detected. No action required"
    Exit 0
    }