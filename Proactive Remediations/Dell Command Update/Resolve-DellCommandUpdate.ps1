<#
    .SYNOPSIS
    Remove Dell Command | Update installations
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Resolve-DellCommandUpdate.log" -Append
Write-Output "Starting detection of Dell Command | Update installation"

# Define registry uninstall paths to be searched
Write-Output "Identifying Dell Command | Update installations from registry"
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Search defined registry uninstall locations
$UninstallSearchFilter = {($_.GetValue('DisplayName') -like 'Dell Command | Update*')}

# Uninstall any detected Dell Command | Update installations

try{
    foreach ($Path in $RegUninstallPaths){
        if (Test-Path $Path){
            Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
            ForEach-Object{
            Write-Host "Found installation: $($_.PSChildName)"
            $Arguments = '/X' + $($_.PSChildName) + ' /qn /l*v C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Resolve-DellCommandUpdate' + $($_.PSChildName) +'.log'
            $Uninstall = Start-Process MSIexec.exe -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
            $ReturnCode = $Uninstall.ExitCode
            Write-Host "Return Code: $ReturnCode"
            }
        }
    }
}
catch{
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}
