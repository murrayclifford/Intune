<#
    .SYNOPSIS
    Detects all installations matching Adobe Acrobat Reader with a version greater than or equal to 22.001.20085
#>

if(Get-WmiObject -Class Win32_Product -Filter "Name like 'Adobe Acrobat Reader%' AND Version >= '22.001.20085'"){
    Exit 1
    }
else{
    Exit 0
    }