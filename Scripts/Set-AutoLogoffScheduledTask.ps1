<#
    .SYNOPSIS

#>

Start-Transcript -Path C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Create-SignoutScheduledTask.log
Write-Output "Creating scheduled task to force interactive user sessions to log off when idle"

#Define scheduled task variables
$TaskName = "Automatic logoff when idle"
$TaskDescription = "Scheduled task to automatically force interactive user sessions to log off when idle"
$Author = "APM"


# Define scheduled task XML
Write-Output "Defining scheduled task XML"
$ScheduledTaskXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2022-05-30T15:35:54.4080055</Date>
    <Author>DESKTOP-79NIEHV\Murray</Author>
    <Description>Automatically signout all users after the device has been idle for one hour</Description>
    <URI>\APM\Automatic Signout on Idle</URI>
  </RegistrationInfo>
  <Triggers>
    <IdleTrigger>
      <Enabled>true</Enabled>
    </IdleTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-21-2384115879-2939452552-1597984318-1001</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <Duration>PT10M</Duration>
      <WaitTimeout>PT0S</WaitTimeout>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>false</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>true</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\Windows\System32\logoff.exe</Command>
    </Exec>
  </Actions>
</Task>
"@

# Check if scheduled task is already configured on device
Write-Output "Checking if scheduled task has already been configured on the device"
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction 'SilentlyContinue') {
    try {
        Write-Output "Found scheduled task. Attempting to remove"
        Unregister-ScheduledTask -TaskName $TaskName -ErrorAction 'Stop' -Confirm:$false
    }
    catch {
        Write-Output "Unable to remove scheduled task. Script will exit"
        exit 69005
    }
}
else {
    Write-Output "Scheduled task not configured on device."
}

# Check registry for scheduled task
$ExistingTaskKeys = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks').Where({$_.GetValue('Description') -eq "$TaskDescription"})
if ($null -ne $ExistingTaskKeys) {
    foreach ($Key in $ExistingTaskKeys) {
        Write-Output "Found scheduled task registry keys, removing"
        Remove-Item -Path $($Key.PSPath) -Force -Confirm:$false
    }
}

# Check and remove cached scheduled task files
if (Test-Path -Path "$env:windir\System32\Tasks\APM\$TaskName" -PathType 'Leaf' -ErrorAction 'SilentlyContinue') {
    Write-Oupt "Found legacy scheduled task files. Attempting to remove them"
    Remove-Item -Path "$env:windir\System32\Tasks\APM\$TaskName" -Force -Confirm:$false
}

# Register scheduled task on device
Write-Output "Registering scheduled task on device"
try{
    Register-ScheduledTask -TaskName "$TaskName" -Xml $ScheduledTaskXml
    }
catch{
    Write-Output "Scheduled task could not be created. Script will exit"
}

Stop-Transcript  