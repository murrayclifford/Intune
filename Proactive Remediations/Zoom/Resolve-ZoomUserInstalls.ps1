<#
    .SYNOPSIS
    Detects all installations on the local device matching 'Adobe Reader', 'Adobe Reader X', or 'Adobe Reader XI'
#>

Start-Transcript -Path "$Env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Remove-ZoomUserInstall.log" -Append

# Gather array of user accounts on local device
[System.Collections.ArrayList]$UserArray = (Get-ChildItem C:\Users\).Name
$UserArray.Remove('Public')

# Create PS Drive for registry cleaning tasks
New-PSDrive HKU Registry HKEY_USERS

# Loop through each user on the local device removing any binaries and registry keys
Foreach($obj in $UserArray){
    $Parent  = "$env:SystemDrive\users\$obj\Appdata\Roaming"
    $Path = Test-Path -Path (Join-Path $Parent 'zoom\bin\zoom.exe')
    if($Path){
        "Zoom is installed for user $obj"
        Stop-Process -Name Zoom -Force -Confirm:$false
        $User = New-Object System.Security.Principal.NTAccount($obj)
        $sid = $User.Translate([System.Security.Principal.SecurityIdentifier]).value
        if(test-path "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Uninstall\ZoomUMX"){
            "Removing registry key ZoomUMX for $sid on HK_Users"
            Remove-Item "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Uninstall\ZoomUMX" -Force
        }
        # Take ownership of the directory
        takeown /a /r /d Y /f (join-path $Parent 'zoom')
        "Removing folder on $Parent"
        Remove-item -Recurse -Path (join-path $Parent 'zoom') -Force -Confirm:$false
        "Removing start menu shortcut"
        Remove-item -recurse -Path (Join-Path $Parent '\Microsoft\Windows\Start Menu\Programs\zoom') -Force
    }
    else{
        "Zoom is not installed for user $obj"
    }
}
Remove-PSDrive HKU

Stop-Transcript