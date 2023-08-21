<#
    .SYNOPSIS
    Searches device for VS Code installations in user profiles 
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
Start-Transcript -Path "$Env:Programdata\Microsoft\IntuneManagementExtension\Logs\Detect-VSCodeUserInstall.log" -Append
Write-Output "Starting detection of VS Code user profile installations"

# Loop through user profiles to check for VS Code installation binaries
try {
    # Run Test and store as variable
    $Test = Get-ChildItem -Path "C:\Users\" -Filter "code.exe" -Recurse -Force -ErrorAction SilentlyContinue
 
    # Check where test is compliant or not - if no instances of VS Code are discovered then mark as 'Compliant' and exit with 0
    if ($null -eq $Test) {
        Write-Output "Compliant"
        Stop-Transcript
        exit 0
    }
    # If instances of VS Code are discovered then mark as 'Non Compliant' and exit with 1
    else {
        Write-Warning "Non Compliant"
        Stop-Transcript
        exit 1
    }
}
 
catch {
    # Write errors messages to the log and exit
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
    Stop-Transcript
    Exit 2000
}