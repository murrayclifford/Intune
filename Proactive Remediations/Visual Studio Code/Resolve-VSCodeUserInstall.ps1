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
Write-Output "Starting detection of VS Code user profile installations"

# Gather array of user accounts on local device
[System.Collections.ArrayList]$UserArray = (Get-ChildItem C:\Users\).Name
$UserArray.Remove('Public')

try{
    Foreach($User in $UserArray){
        $Path = "$Env:SystemDrive\Users\$User\AppData\Local\Programs\Microsoft VS Code\unins000.exe"
        if(Test-Path $Path){
            Write-Ouput "VS Code is installed for user $User"
            $Args = '/SILENT /NORESTART /FORCECLOSEAPPLICATIONS /log="C:\ProgramData\Microsoft\Intune Management\Logs\VSCodeUserUninstall.log'
            Start-Process $Path -Args $Args -Wait
            Write-Output "VS Code has been uninstalled for $User"
        }
        else{
            Write-Output "VS Code not installed for user $User"
        }
    }
}
catch{
    # Write errors messages to the log and exit
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}