#Connect-MsolService
#Connect-AzureAD

 

$Devices = Import-CSV -Path C:\Temp\Intune\AAD_Groups\Devices.csv -Delimiter ";"
$GroupName = "APM-MEM-MitelClientComponentPack-Removal"
$AADGroup = Get-AzureADGroup -SearchString $GroupName

 

foreach($Device in $Devices){
    $AADDevice = Get-MsolDevice -Name $Device.AssetName | Where-Object {$_.DeviceTrustType -eq "Domain Joined"}
    Add-AzureADGroupMember -ObjectId $AADGroup.ObjectID -RefObjectId $AADDevice.ObjectID
    Write-Output "Status: $($AADDevice.DisplayName) has been added to $GroupName"
    }