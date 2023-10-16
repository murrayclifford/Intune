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
Write-Output "Starting removal 7-Zip installations"

# Set Uninstall binary locations
$UninstallPath_x86 = "C:\Program Files (x86)\7-Zip\" 
$UninstallPath_x64 = "C:\Program Files\7-Zip\"

try{

    #region EXE installations

    # Check for 32-bit 7-Zip installations
    if(Test-Path "$UninstallPath_x86\Uninstall.exe"){
        Write-Output "Info: Found 7-Zip EXE-based installation: $UninstallPath_x86, attempting to uninstall"
        $Uninstall = Start-Process -FilePath "$UninstallPath_x86\Uninstall.exe" -ArgumentList "/S" -Wait
        $ReturnCode = $Uninstall.ExitCode
        Write-Output "Info: Return Code: $ReturnCode"
        
    }

    # Check for 64-Bit 7-Zip instllations
    if(Test-Path "$UninstallPath_x64\Uninstall.exe"){
        Write-Output "Info: Found 7-Zip EXE-based installation: $UninstallPath_x64, attempting to uninstall"
        $Uninstall = Start-Process -FilePath "$UninstallPath_x64\Uninstall.exe" -ArgumentList "/S" -Wait
        $ReturnCode = $Uninstall.ExitCode
        Write-Output "Info: Return Code: $ReturnCode"  
    }

    #endregion

    #region MSI installations

    # Set search criteria for 7-Zip MSI installations
    Write-Output "Info: Identifying 7-Zip installations from registry"
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
                Write-Output "Info: Found installation: $($_.PSChildName)"
                $Arguments = '/X' + $($_.PSChildName) + ' /qn /l*v C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Uninstall-7-Zip' + $($_.PSChildName) +'.log'
                $Uninstall = Start-Process MSIexec.exe -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
                $ReturnCode = $Uninstall.ExitCode
                Write-Output "Info: Return Code: $ReturnCode"
                if (Test-path $Path){
                    Write-Output "Warning: Orphaned 7-zip installation registry keys $Path found on $Env:ComputerSystem, removing"
                    Remove-Item $Path -Recurse
                }
            }
        }
        if(Test-Path $UninstallPath_x86){
            Write-Output "Warning: $UninstallPath_x86 found on $env:ComputerName, attempting to remove"
            Remove-Item -Path $UninstallPath_x86 -Recurse
        }
        if(Test-Path $UninstallPath_x64){
            Write-Output "Warning: $UninstallPath_x64 found on $env:ComputerName, attempting to remove"
            Remove-Item -Path $UninstallPath_x64 -Recurse
        }
    }

    #endregion

    #region Third-party application remediation

    # Check for Mitel MiContact installations
    $MiContactPath = "C:\Program Files (x86)\Mitel\MiContact Centre\Services\UpdaterService\7za.exe"
    $MitelPath = "C:\Program Files (x86)\Mitel"

    Write-Output "Info: Checking for MiContact binaries on $Env:ComputerSystem"
    if(Test-Path $MiContactPath){
        Write-Output "Info: Found MiContact binaries on target $Env:ComputerSystem. Preparing to remove"
        Remove-Item $MitelPath -Recurse -Force
    }
    else{
        Write-Output "Info: MiContact and 7-Zip binaries not found on $Env:ComputerSystem"
    }

    #endregion

    #region Clean-up of orphaned installation directories
    
    # Check for orphaned 32-bit installation directories
    Write-Output "Info: Confirm whether $UninstallPath_x86 has been removed"
    if(Test-Path $UninstallPath_x86){
        Write-Output "Warning: $UninstallPath_x86 found on $env:ComputerName, attempting to remove"
        Remove-Item -Path $UninstallPath_x86 -Recurse
    }
    else{
        Write-Output "Info: $UninstallPath_x86 not found on $env:ComputerName"
    }

    # Check for orphaned 64-bit installation directories
    Write-Output "Info: Confirm whether $UninstallPath_x64 has been removed"
    if(Test-Path $UninstallPath_x64){
        Write-Output "Warning: $UninstallPath_x64 found on $env:ComputerName, attempting to remove"
        Remove-Item -Path $UninstallPath_x64 -Recurse
    }
    else{
        Write-Output "Info: $UninstallPath_x64 not found on $env:ComputerName"
    }

    #endregion

    Write-Output "Info: Clean-up of 7-Zip completed"
    Stop-Transcript
    Write-Output "Info: Clean-up of 7-Zip completed"

}
catch{

    Write-Warning "7-Zip clean-up failed"
    $errMsg = $_.exception.message
    Write-Output $errMsg
    Stop-Transcript
    Write-Output $errMsg
    Exit 2000

}