function IsWSLDistributionInstalled {
    param (
        [string]$distributionName
    )

    # Get the list of all WSL distributions
    $wslListAll = wsl --list --all

    # Check if the distribution is installed
    $isInstalled = $wslListAll -contains $distributionName

    return $isInstalled
}

# Usage
$distributionName = "Ubuntu (Default)"
$isInstalled = IsWSLDistributionInstalled -distributionName $distributionName
Write-Output $isInstalled


