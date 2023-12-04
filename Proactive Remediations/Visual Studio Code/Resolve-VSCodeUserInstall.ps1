<#
    .SYNOPSIS
    Searches and uninstalls VS Code installations in user profiles
#>

# Editable variables
$App = "Visual Studio Code (User)"
$LogPath = "$($Env:ProgramData)\Microsoft\IntuneManagementExtension\Logs"
$LogName = "Resolve-VSCodeUserInstall.log"
$LogIntro = "INFO: Starting detection of $($App)"
$LogExit = "INFO: $($App) has been uninstalled"

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

try{

    #region Uninstall
    
    # Check whether VS Code is running on device
    $VsCodeOpen = Get-Process -Name "Code" -ErrorAction SilentlyContinue | Where-Object {$_.Path.StartsWith($Env:USERPROFILE)}
    if($VsCodeOpen.Count -gt 0){
        Write-Output "WARN: VS Code process currently running. Exiting script"
        Stop-Transcript
        Write-Output "WARN: VS Code process currently running. Exiting script"
        Exit 0
    }

    # Uninstall if VS Code is not running on device
    if($null -eq $VsCodeOpen -or $VsCodeOpen -eq 0){
        # Gather array of user accounts on local device
        [System.Collections.ArrayList]$UserArray = (Get-ChildItem C:\Users\).Name
        $UserArray.Remove('Public')
        # Loop through user profiles and attempt to uninstall VS Code
        Foreach($User in $UserArray){
            $Path = "$Env:SystemDrive\Users\$User\AppData\Local\Programs\Microsoft VS Code\unins000.exe"
            if(Test-Path $Path){
                Write-Output "INFO: VS Code is installed for user $User"
                $Params = '/SILENT /NORESTART /FORCECLOSEAPPLICATIONS'
                Start-Process $Path -Args $Params -Wait
                Write-Output "INFO: VS Code has been uninstalled for $User"
                Stop-Transcript
                Write-Output "INFO: VS Code has been uninstalled for $User"
            }
            else{
                Write-Output "INFO: VS Code not installed for user $User"
                Stop-Transcript
                Write-Output "INFO: VS Code not installed for user $User"
            }
        }
    }
    #endregion Uninstall

    #region RegistryCleanup

    # Define regex pattern for user SIDs
    $PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'

    # Get Username, SID, and location of ntuser.dat for all users
    Write-Output "INFO: Creating list of all user profiles on $($Env:ComputerName)"
    $ProfileList = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object { $_.PSChildName -match $PatternSID } | 
        Select-Object  @{name = "SID"; expression = { $_.PSChildName } }, 
        @{name = "UserHive"; expression = { "$($_.ProfileImagePath)\ntuser.dat" } }, 
        @{name = "Username"; expression = { $_.ProfileImagePath -replace '^(.*[\\\/])', '' } }

    # Get all user SIDs found in HKEY_USERS (ntuder.dat files that are loaded)
    Write-Output "INFO: Creating list of user profiles that have been loaded into the registry"
    $LoadedHives = Get-ChildItem Registry::HKEY_USERS | Where-Object { $_.PSChildname -match $PatternSID } | Select-Object @{name = "SID"; expression = { $_.PSChildName } }

    # Get all users that are not currently logged
    Write-Output "INFO: Creating list of user profiles that have not been loaded into the registry"
    $UnloadedHives = Compare-Object $ProfileList.SID $LoadedHives.SID | Select-Object @{name = "SID"; expression = { $_.InputObject } }, UserHive, Username

    # Loop through each profile on the machine
    Write-Output "INFO: Checking user profiles on $($Env:ComputerName)"
    Foreach ($Profile in $ProfileList) {
        # Load User ntuser.dat if it's not already loaded
        if ($Profile.SID -in $UnloadedHives.SID) {
            Write-Output "INFO: Loading $($Profile.Username) profile"
            reg load HKU\$($Profile.SID) $($Profile.UserHive) | Out-Null
        }
    
        # Define regitry key location
        $VSCodeKey = "Registry::HKEY_USERS\$($Profile.SID)\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{771F6B0-FA20-440A-A002-3B3BAC16DC50}_is1"

        # Check for registry key and remove if found
        Write-Output "INFO: Checking for $($App) registry key"
        if(Test-Path $VSCodeKey){
            Write-Output "INFO: Found $($App) registry key in $($Profile.SID)"
            Remove-Item -Path $VSCodeKey -Force
        }
        
        # Unload ntuser.dat        
        if ($Profile.SID -in $UnloadedHives.SID) {
            # Garbage collection and closing of ntuser.dat
            [gc]::Collect()
            reg unload HKU\$($Profile.SID) | Out-Null
        }  
    }
    #endregion RegistryCleanup
   
    Write-Output "$($LogExit)"
}
catch{
    # Write errors messages to the log and exit
    $errMsg = $_.exeption.message
    Write-Output $errMsg
    Stop-Transcript
    Write-Output $errMsg
    Exit 2000
}