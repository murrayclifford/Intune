<#
    .SYNOPSIS
    Detects all installations per-user installations of Zoom
#>

Start-Transcript -Path "$Env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Detect-ZoomUserInstallation.log" -Append
 
# Discovery
try {
    # Run Test and store as variable
    $Test = Get-ChildItem -Path "C:\Users\" -Filter "Zoom.exe" -Recurse -Force -ErrorAction SilentlyContinue
 
    # Check where test is compliant or not - if no instances of Zoom are discovered then mark as 'Compliant' and exit with 0
    if ($null -eq $Test) {
        Write-Output "Compliant"
        exit 0
    }
    # If instances of Zoom are discovered then mark as 'Non Compliant' and exit with 1
    else {
        Write-Warning "Non Compliant"
        exit 1
    }
}
 
catch {
    # If any errors occur then return 'Non Compliant'
    Write-Warning "Non Compliant"
    exit 1
}