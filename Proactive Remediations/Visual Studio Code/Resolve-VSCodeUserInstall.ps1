<#
    .SYNOPSIS
    Searches and uninstalls VS Code installations in user profiles
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Resolve-VSCodeUserInstall.log" -Append
Write-Output "Info: Starting removal of VS Code user profile installations"


try{

    # Check whether VS Code is running on device
    $VsCodeOpen = Get-Process -Name "Code" -ErrorAction SilentlyContinue | Where-Object {$_.Path.StartsWith($Env:USERPROFILE)}
    if($VsCodeOpen.Count -gt 0){
        Write-Output "Warn: VS Code process currently running. Exiting script"
        Stop-Transcript
        Write-Output "Warn: VS Code process currently running. Exiting script"
        Exit 0
    }

    if($null -eq $VsCodeOpen -or $VsCodeOpen -eq 0){
        # Gather array of user accounts on local device
        [System.Collections.ArrayList]$UserArray = (Get-ChildItem C:\Users\).Name
        $UserArray.Remove('Public')

        # Loop through user profiles and attempt to uninstall VS Code
        Foreach($User in $UserArray){
            $Path = "$Env:SystemDrive\Users\$User\AppData\Local\Programs\Microsoft VS Code\unins000.exe"
            if(Test-Path $Path){
                Write-Output "Info: VS Code is installed for user $User"
                $Params = '/SILENT /NORESTART /FORCECLOSEAPPLICATIONS'
                Start-Process $Path -Args $Params -Wait
                Write-Output "Info: VS Code has been uninstalled for $User"
                Stop-Transcript
                Write-Output "Info: VS Code has been uninstalled for $User"
            }
            else{
                Write-Output "Info: VS Code not installed for user $User"
                Stop-Transcript
                Write-Output "Info: VS Code not installed for user $User"
            }
        }
    }
}
catch{
    # Write errors messages to the log and exit
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Write-Output $errMsg
    Exit 2000
}