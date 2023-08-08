<#
    .SYNOPSIS
    Uninstalls 7-Zip installations
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Resolve-7-Zip.log" -Append
Write-Output "Starting uninsatllation 7-Zip installations"

# Set Uninstall binary locations
$UninstallPath_x86 = "C:\Program Files (x86)\7-Zip\Uninstall.exe" 
$UninstallPath_x64 = "C:\Program Files\7-Zip\Uninstall.exe"

# Check for 32-bit 7-Zip installations
if((Test-Path $UninstallPath_x86)){
    Write-Output "Found 7-Zip EXE-based installation, attempting to uninstall"
    $Uninstall = Start-Process -FilePath $UninstallPath_x86 -ArgumentList "/S" -Wait
    $ReturnCode = $Uninstall.ExitCode
    Write-Output "Return Code: $ReturnCode"
}

# Check for 64-Bit 7-Zip instllations
if((Test-Path $UninstallPath_x64)){
    Write-Output "Found 7-Zip EXE-based installation, attempting to uninstall"
    $Uninstall = Start-Process -FilePath $UninstallPath_x64 -ArgumentList "/S" -Wait
    $ReturnCode = $Uninstall.ExitCode
    Write-Output "Return Code: $ReturnCode"
}

# Set search criteria  for 7-Zip MSI installations
Write-Host "Identifying 7-Zip installations from registry"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

$UninstallSearchFilter = {($_.GetValue('DisplayName') -like '7-Zip*')}

# Uninstall any 7-Zip MSI installations
foreach ($Path in $RegUninstallPaths) {
    if (Test-Path $Path) {
        Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
        foreach {
        Write-Host "Found installation: $($_.PSChildName)"
        $Arguments = '/X' + $($_.PSChildName) + ' /qn /l*v C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-7-Zip' + $($_.PSChildName) +'.log'
        $Uninstall = Start-Process MSIexec.exe -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
        $ReturnCode = $Uninstall.ExitCode
        Write-Host "Return Code: $ReturnCode"
        }
    }
}

# Check for Mitel MiContact installations
$MiContactPath = "C:\Program Files (x86)\Mitel\MiContact Centre\Services\UpdaterService\7za.exe"
$MitelPath = "C:\Program Files (x86)\Mitel"

if(Test-Path $MiContactPath){
    Write-Output "Found MiContact binaries on target device. Preparing to remove"
    Remove-Item $MitelPath -Recurse -Force
}

Stop-Transcript