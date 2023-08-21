<#
    .SYNOPSIS
    Removes orphaned Zoom registry keys from a device
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

$($MyInvocation.MyCommand.Name).log

# Start Logging
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\$($MyInvocation.MyCommand.Name).log" -Append
Write-Output "Starting detection of orphaned Zoom registry keys"

# Define registry locations for known orphaned keys
$Zoom_455 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{C2A4DC8D-579A-4D8C-9BE6-4544486B6D61}"
$Zoom_512 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{51F42754-DEAC-4D78-AB57-F4433178481A}"
$Zoom_591 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{89A05370-496B-4589-8D16-539314A11C8C}"

Try{
    if(Test-Path -Path $Zoom_455){
        Write-Output "Found: $Zoom_455"
        Remove-Item -Path $Zoom_455
    }
    if(Test-Path -Path $Zoom_512){
        Write-Output "Found: $Zoom_512"
        Remove-Item -Path $Zoom_512  
    }
    if(Test-Path -Path $Zoom_591){
        Write-Output "Found: $Zoom_591"
        Remove-Item -Path $Zoom_591  
    }
}
Catch{
    Write-Output "Detection failed"
    Stop-Transcript
    Exit 2000
}

Write-Output "Removal of orphaned Zoom registry keys complete"
Stop-Transcript