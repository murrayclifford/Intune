# Start Logging
Start-Transcript -Path C:\Windows\CCM\Logs\Remove-JavaRuntime.log
Write-Host "Starting Java Runtime Environment removal process"

# Gather Java RE installation information from registry

Write-Host "Identifying Java installations from registry"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Define version of Java RE to keep if necessary

#$VersionsToKeep = @('Java 8 Update 261')
#Write-Host "$VersionsToKeep has been whitelisted and will not be uninstalled."

# Stop any running Java processes
Write-Host "Closing any open Java RE processes."
Get-CimInstance -ClassName 'Win32_Process' | Where-Object {$_.ExecutablePath -like '*Program Files\Java*'} | 
    Select-Object @{n='Name';e={$_.Name.Split('.')[0]}} | Stop-Process -Force

# Close any open Internet Explorer processes

if(Get-Process -Name *iexplore*){
    Write-Host "Internet Explorer is running, stopping process."
    Stop-Process -Name *iexplore* -Force -ErrorAction SilentlyContinue
}

# Uninstall unwanted Java versions and clean up program files

$UninstallSearchFilter = {($_.GetValue('DisplayName') -like '*Java*') -and (($_.GetValue('Publisher') -eq 'Oracle Corporation')) -and ($VersionsToKeep -notcontains $_.GetValue('DisplayName'))}

foreach ($Path in $RegUninstallPaths) {
    if (Test-Path $Path) {
        Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
        foreach {
        Write-Host "Found installation: $($_.PSChildName)"
        $Arguments = '/X' + $($_.PSChildName) + ' /qn /l*v C:\Windows\CCM\Logs\Uninstall-JRE' + $($_.PSChildName) +'.log'
        $Uninstall = Start-Process MSIexec.exe -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
        $ReturnCode = $Uninstall.ExitCode
        Write-Host "Return Code: $ReturnCode"
        }
    }
}

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
$ClassesRootPath = "HKCR:\Installer\Products"
Get-ChildItem $ClassesRootPath | 
    Where-Object { ($_.GetValue('ProductName') -like '*Java*')} | Foreach {
    Write-Host "Found orphaned registry keys $ClassesRootPath. Removing."
    Remove-Item $_.PsPath -Force -Recurse
}

$JavaSoftPath = 'HKLM:\SOFTWARE\JavaSoft'
if (Test-Path $JavaSoftPath) {
    Write-Host "Found orphaned JavaSoft registry keys in $JavaSoftPath. Removing."
    Remove-Item $JavaSoftPath -Force -Recurse
}

Stop-Transcript