<#
    .SYNOPSIS
    Copies Microsoft Teams Meeting room configuration files to the local device

#>

#region script configuration

# Editable variables
$LogPath = "$($Env:ProgramData)\Microsoft\IntuneManagementExtension\Logs"
$LogName = "Set-TeamsMeetingRoomConfig.log"
$SkypeSettingsURL = ""
$CustomBackgroundURL = ""

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
Start-Transcript -Path $LogPath\$LogName -Append
Write-Output $LogIntro

#endregion

#region script logic

try{
    # Download SkypeSettings XML file
    $OutFile = "C:\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState\SkypeSettings.xml"
    $params = @{
        URI             = $SkypeSettingsURL
        OutFile         = $OutFile
        UseBasicParsing = $true
        ErrorAction     = "Stop"
    }
    Invoke-WebRequest @params

    # Download custom background
    $OutFile = "C:\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState\SkypeSettings.xml"
    $params = @{
        URI             = $CustomBackgroundURL
        OutFile         = $OutFile
        UseBasicParsing = $true
        ErrorAction     = "Stop"
    }
    Invoke-WebRequest @params
}
catch{
    throw $_
}

#endregion