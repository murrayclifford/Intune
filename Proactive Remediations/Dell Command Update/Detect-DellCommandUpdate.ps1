<#
    .SYNOPSIS
    Searches local device for Dell Command | Update installations
#>

# Check if PowerShell is running as a 32-bit process and restart as a 64-bit process
if (!([System.Environment]::Is64BitProcess)) {
    if ([System.Environment]::Is64BitOperatingSystem) {
        Write-Output "Relaunching process as 64-bit process"
        $Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$($MyInvocation.MyCommand.Definition)`""
        $ProcessPath = $(Join-Path -Path $Env:SystemRoot -ChildPath "\Sysnative\WindowsPowerShell\v1.0\powershell.exe")
        $params = @{
            FilePath     = $ProcessPath
            ArgumentList = $Arguments
            Wait         = $True
            WindowStyle  = "Hidden"
        }
        Start-Process @params
        exit 0
    }
}

# Start Logging
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Detect-DellCommandUpdate.log" -Append
Write-Output "Starting detection of Dell Command | Update installation"

# Check for Dell Command | Update installations
try {
    if(Get-WmiObject -Class Win32_Product -Filter "Name like 'Dell Command | Update%'"){
    Write-Output "Dell Command | Update detected and will now be removed"
    Exit 1
    }
else{
    Write-Output "Dell Command | Update not detected. No action required"
    Exit 0
    }
}
catch {
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}