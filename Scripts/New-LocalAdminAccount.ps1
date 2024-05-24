<#
    .SYNOPSIS
    - Creates a new local user account adn adds it to the Administrators group
    - Password is not specified and random
    - Intended for use with Windows LAPS deployments
#>

# Create local account and add to Administrators group
net user /add NewCo_Admin
net localgroup administrators NewCo_Admin /add