<#
    .SYNOPSIS
    Staets the Microsoft Edge automatic update scheduled tasks to force an update of the browser
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Resolve-GoogleChrome.log" -Append
Write-Output "Starting detection of Microsoft Edge installations"

# Manually start Microsoft Edge automatic update scheduled tasks

try{
    # Run scheduled tasks
    Write-Output "Starting execution of MicrosoftEdgeUpdateTaskMachineCore scheduled task"
    Start-ScheduledTask -TaskName MicrosoftEdgeUpdateTaskMachineCore

    # Wait 2 mintues for previous task to complete
    Write-Output "Waiting for previous task to complete"
    Start-Sleep -Seconds 120

    Write-Output "Starting execution of MicrosoftEdgeUpdateTaskMachineUA scheduled task"
    Start-ScheduledTask -TaskName MicrosoftEdgeUpdateTaskMachineUA

    # Write completion to log and stop transcript
    Write-Output "Completed running Microsoft Edge update scheduled tasks"
    Stop-Transcript
}
catch{
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}