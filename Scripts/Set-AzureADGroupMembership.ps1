<#
    .SYNOPSIS
    Gathers a device ID from Microsoft Intune and adds device to an Azure AD Group

    .NOTES
    v1.00 - Inital script development
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
Start-Transcript -Path "$Env:SystemDrive\Temp\Intune\Set-AzureADGroupMembership.log" -Append
Write-Output "Adding objects to Azure AD groups"

# Check for Intune PowerShell SDK module
$IntuneModule = Get-InstalledModule -Name Microsoft.Graph.Intune

try{
    if($IntuneModule -eq $null){
        Write-Output "Microsoft.Graph.Intune module is not installed, installing"
        Install-Module -Name Microsoft.Graph.Intune -Force
    }
    else{
        Write-Output "$($IntuneModule.Name) is installed"
    }
}
catch{
    Write-Warning "Installation of Microsoft.Graph.Intune PowerShell module failed"
    $errMsg = $_.exception.message
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}

# Connect to Microsoft Graph
try{
    $RequiredScopes = @("Group.ReadWrite.All", "GroupMember.ReadWrite.All", "Device.ReadWrite.All")
    Connect-MgGraph -Scopes $RequiredScopes
}
catch{
    Write-Warning "Connecting to Microsoft Graph failed"
    $errMsg = $_.exception.message
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000 
}

# Create array of devices to process
$Devices = Get-Content -Path "C:\Temp\Intune\Devices.txt"

# Loop through devices and add to Azure AD Group
$AzureADGroup = Get-MgGroup -Filter "displayName -eq 'APM-MEM-DefenderRemediation-Production'"

try{
    Write-Output "Begin adding devices to $($AzureADGroup)"
    foreach($Device in $Devices){
        Write-Output "Grabbing DeviceID from Azure AD"
        $IntuneDevice = Get-MgDeviceManagementManagedDevice -Filter "deviceName eq '$($Device)"



        Write-Output "Adding $($Device) to $($AzureADGroup)"
        $AzureADDevice = Get-MgDevice -Filter "(displayName -eq $($Device)) -and (TrustType -eq 'ServerAd')"
        New-MgGroupMember -GroupId $AzureADGroup.Id -DirectoryObjectId $AzureADDevice.Id


    }
}
catch{
    Write-Warning "Error adding device to Azure AD group"
    $errMsg = $_.exception.message
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000 
}

