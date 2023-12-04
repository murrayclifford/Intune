<#
    .NOTES
    - Reference and source material: https://www.pdq.com/blog/modifying-the-registry-users-powershell/




#>

# Define regex pattern for user SIDs
$PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
 
# Get Username, SID, and location of ntuser.dat for all users
$ProfileList = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object { $_.PSChildName -match $PatternSID } | 
    Select-Object  @{name = "SID"; expression = { $_.PSChildName } }, 
    @{name = "UserHive"; expression = { "$($_.ProfileImagePath)\ntuser.dat" } }, 
    @{name = "Username"; expression = { $_.ProfileImagePath -replace '^(.*[\\\/])', '' } }
 
# Get all user SIDs found in HKEY_USERS (ntuder.dat files that are loaded)
$LoadedHives = Get-ChildItem Registry::HKEY_USERS | Where-Object { $_.PSChildname -match $PatternSID } | Select-Object @{name = "SID"; expression = { $_.PSChildName } }
 
# Get all users that are not currently logged
$UnloadedHives = Compare-Object $ProfileList.SID $LoadedHives.SID | Select-Object @{name = "SID"; expression = { $_.InputObject } }, UserHive, Username
 
# Loop through each profile on the machine
try{
    Foreach ($Profile in $ProfileList) {
        # Load User ntuser.dat if it's not already loaded
        if ($Profile.SID -in $UnloadedHives.SID) {
            reg load HKU\$($Profile.SID) $($Profile.UserHive) | Out-Null
        }
    
        # Define regitry key location
        $VSCodeKey = "Registry::HKEY_USERS\$($Profile.SID)\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{771F6B0-FA20-440A-A002-3B3BAC16DC50}_is1"

        # Check for registry key and remove if found
        if(Test-Path $VSCodeKey){
            Write-Output "INFO: Found Visual Studio Code registry key in $($Profile.SID)"
            Remove-Item -Path $VSCodeKey -Force
        }
    
        # Unload ntuser.dat        
        IF ($Profile.SID -in $UnloadedHives.SID) {
            # Garbage collection and closing of ntuser.dat
            [gc]::Collect()
            reg unload HKU\$($Profile.SID) | Out-Null
        }
    }
}
catch{
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}