<#
    .SYNOPSIS
    Detect and remove Mitel application installation directory
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\$($MyInvocation.MyCommand.Name).log" -Append
Write-Output "Starting removal of Mitel application installation directory"

# Specify Mitel application services
$MiAudioService = Get-Service -Name "MiAudioService"
$MitelUpdate = Get-Service -Name "UpdaterService"

# Specify for Mitel installation directory
$MitelPath = "C:\Program Files (x86)\Mitel"

try {
    # Check if Mitel services are running on device before removing directory
    if($MitelUpdate.Status -eq 'Running'){
        Write-Output "Status: $MitelUpdate service running. Stopping service before removal."
        Stop-Service -Name $MitelUpdate -Force     
    }
    if($MiAudioService.Status -eq 'Running'){
        Write-Output "Status: $MiAudioService service running. Stopping service before removal."
        Stop-Service -Name $MiAudioService -Force
    }
    # Check for Mitel installation directory and remove from the device
    if(Test-Path $MitelPath){
        Write-Output "Found Mitel application installation directory on target device. Preparing to remove"
        Remove-Item $MitelPath -Recurse -Force
    }
    else{
        Write-Output "Mitel application installation directory not found on device"
    }
    Stop-Transcript
    Exit 0
}
catch {
    $errMsg = $_.exeption.message
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}