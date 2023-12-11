<#
    .SYNOPSIS
    Searches for Visual Studio Code (User) installation binaries and registry keys

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

# Editable variables
$App = "Visual Studio Code (User)"
$LogPath = "$($Env:ProgramData)\Microsoft\IntuneManagementExtension\Logs"
$LogName = "Resolve-VSCodeUserInstall.log"
$LogIntro = "INFO: Starting detection of $($App)"

# Start Logging
Start-Transcript -Path $LogPath\$LogName -Append
Write-Output $LogIntro

# Loop through user profiles to check for VS Code installation binaries and registry keys
try {
    #region VSCodeBinaries

    # Run test and store as variable
    $BinaryTest = Get-ChildItem -Path "C:\Users\" -Filter "code.exe" -Recurse -Force -ErrorAction SilentlyContinue
    #endregion VSCodeBinaries

    #region VSCodeRegistry

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
        $VSCodeKey = "Registry::HKU\$($Profile.SID)\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{771FD6B0-FA20-440A-A002-3B3BAC16DC50}_is1"

        # Check for registry key and remove if found
        Write-Output "INFO: Checking for $($App) registry key"
        if(Test-Path $VSCodeKey){
            Write-Output "INFO: Found $($App) registry key in $($Profile.SID)"
            $RegistryTest = "Non-compliant"
        }
        
        # Unload ntuser.dat        
        if ($Profile.SID -in $UnloadedHives.SID) {
            # Garbage collection and closing of ntuser.dat
            [gc]::Collect()
            reg unload HKU\$($Profile.SID) | Out-Null
        }
        
        # Break profile loop when VS Code registry keys found for any user
        if($RegistryTest){
            Write-Output "INFO: $App registry keys found, exiting profile loop"
            break
        }
    }
    #endregion VSCodeRegistry
 
    # Check where test is compliant or not - if no instances of VS Code are discovered then mark as 'Compliant' and exit with 0
    if (($BinaryTest) -OR ($RegistryTest)) {
        Write-Warning "Non-compliant: $App binaries or registry keys found on $($Env:ComputerName)"
        Stop-Transcript
        Write-Warning "Non-compliant: $App binaries or registry keys found on $($Env:ComputerName)"
        Exit 1
    }
    # If instances of VS Code are discovered then mark as 'Non Compliant' and exit with 1
    else {
        Write-Output "Compliant: $App binaries or registry keys not found on $($Env:ComputerName)"
        Stop-Transcript
        Write-Output "Compliant: $App binaries or registry keys not found on $($Env:ComputerName)"
        Exit 0
    }
}
 
catch {
    # Write errors messages to the log and exit
    $errMsg = "ERR: Script execution failed"
    Write-Output $errMsg
    Stop-Transcript
    Write-Output $errMsg
    Exit 2000
}