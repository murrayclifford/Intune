$appdetails = (Get-ItemProperty Registry::HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*) | Where-Object { $_.DisplayName -like "*Tableau Reader*"}

try {
    if ($appdetails.DisplayName -like "*Tableau Reader*"){
    Write-Output "Tableau Reader is installed and will now be removed"
    Exit 1
    }
    else {
    Write-Output "Tableau Reader is not installed. No action required"
    Exit 0
    }
}
catch {
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
}