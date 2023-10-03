<#
    .SYNOPSIS
    Loops through a list of users and add them to an Azure AD group
#>

# Start Logging
Start-Transcript -Path "C:\Temp\WS13\Update-AADGroupMembership.log" -Append
Write-Output "Starting Azure AD group update process"

# Parameters
$GroupName = "A-WS13-ConditionalAccess_Batch1"
$CSVFile = "C:\Temp\WS13\WS13_Batch1_Users.csv"
 
# Get users to import from a CSV File
#$Users = Import-Csv -Path $CSVFile -Header "UserPrincipalName"

$Users = Get-Content -Path C:\Temp\WS13\WS13_Batch1_Users.txt

# Connect to Azure AD
Connect-AzureAD

# Gather Azure AD group information
$Group = Get-AzureADGroup -Filter "DisplayName eq '$GroupName'"
 
# Get Exisiting Members of the Group
$GroupMembers = Get-AzureADGroupMember -ObjectId $Group.ObjectId | Select -ExpandProperty UserPrincipalName
 
#Add Each user to the Security group
ForEach ($User in $Users){
    # Gather user details from Active Directory
    $ADUser = Get-ADUser -Identity $User
    
    #Check if the group has the member already
    If($GroupMembers -contains $ADUser.UserPrincipalName)    {
        Write-host "User '$($ADUser.UserPrincipalName)' is already a Member of the Group!" -f Yellow
    }
    Else{
        # Add user to Azure AD group
        $UserObj = Get-AzureADUser -ObjectId $ADUser.UserPrincipalName
        Add-AzureADGroupMember -ObjectId $Group.ObjectId -RefObjectId $UserObj.ObjectId
        Write-host -f Green "Added user to the Group:"$ADUser.UserPrincipalName
    }
}

Stop-Transcript