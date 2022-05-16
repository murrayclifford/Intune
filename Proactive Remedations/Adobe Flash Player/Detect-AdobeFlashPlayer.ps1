# Define application to be removed
$appdetails = (Get-ItemProperty Registry::HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*) | Where-Object { $_.DisplayName -like "*Adobe Flash Player*"}


try {
    if ($appdetails.DisplayName -like "*Adobe Flash Player*"){
    Write-Output "Adobe Flash Player is installed and will now be removed"
    Exit 1
    }
    else {
    Write-Output "Adobe Flash Player is not installed. No action required"
    Exit 0
    }
}
catch {
    $errMsg = $_.exeption.essage
    Write-Output $errMsg
}