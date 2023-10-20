function Get-Uninstaller {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Name
    )

    $local_key     = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $machine_key32 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $machine_key64 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'

    $keys = @($local_key, $machine_key32, $machine_key64)

    $results = Get-ItemProperty -Path $keys -ErrorAction 'SilentlyContinue' | 
        Where-Object { ($_.DisplayName -like "*$Name*") -or ($_.PsChildName -like "*$Name*") }

    foreach ($item in $results) {
        if ($item.PSPath -like "*HKCU*") {
            $item | Add-Member -MemberType NoteProperty -Name 'InstallScope' -Value 'User'
        } else {
            $item | Add-Member -MemberType NoteProperty -Name 'InstallScope' -Value 'System'
        }

        if ($item.InstallDate) {
            $parsedDate = [DateTime]::ParseExact($item.InstallDate, "yyyyMMdd", $null)
            $item | Add-Member -MemberType NoteProperty -Name 'HumanFriendlyInstallDate' -Value $parsedDate.ToString("ddMMMyyyy")
        }
    }

    $results | Select-Object PsPath, DisplayVersion, DisplayName, UninstallString, InstallSource, InstallLocation, QuietUninstallString, InstallDate, @{N='MSI_Code';E={$_.PSChildName}}, HumanFriendlyInstallDate, InstallScope
}