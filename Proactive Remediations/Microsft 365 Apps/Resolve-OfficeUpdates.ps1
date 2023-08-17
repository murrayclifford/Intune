<#
    .SYNOPSIS
    Executes the Office Click to Run process to force update the installed Office client
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

# Start Logging - changed logging to a static patch as Intune PR's rename the scripts as 'detect' and 'remediation'
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Resolve-OfficeUpdates.log" -Append
Write-Output "Starting detection of Office version"


try {
    Write-Output "Attempting to force Office Click To Run updates"
    Start-Process "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" -ArgumentList "/update user updatepromptuser=true displaylevel=true"
}
catch {
    Write-Output "ERROR: Office Click to Run update process failed"
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}