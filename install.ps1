function Test-IsAdministrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    Write-Host "This script requires administrator privileges. Please run it as an administrator."
    exit
}

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop is not installed. Installing Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
} else {
    Write-Host "Scoop is already installed."
}

scoop bucket add main
Write-Host "Downloading and installing Visual Studio components..."
Invoke-WebRequest -Uri https://aka.ms/vs/17/release/vs_community.exe -OutFile vs_community.exe
Start-Process -FilePath vs_community.exe -ArgumentList '--passive', '--wait', '--norestart', '--nocache', '--add', 'Microsoft.VisualStudio.Component.Windows11SDK.22000', '--add', 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64' -Wait
Remove-Item -Path vs_community.exe
scoop bucket add versions
scoop install versions/python39
scoop install main/swift
scoop bucket add versions
scoop install versions/nodejs20

# Check if WSL is installed
$wslInstalled = (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq 'Enabled'

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

# Check if WSL is installed
$wslInstalled = (wsl --list --all) -ne $null

if (-not $wslInstalled) {
    Write-Host "Installing WSL..."
    wsl --install
    Write-Host "WSL installed. Please restart your computer and re-run this script."
    exit
}

# Check if Ubuntu is installed
$distributionName = "Ubuntu (Default)"
$ubuntuInstalled = IsWSLDistributionInstalled -distributionName $distributionName

if (-not $ubuntuInstalled) {
    Write-Host "Installing Ubuntu..."
    wsl --install -d Ubuntu
    Write-Host "Ubuntu installed. Please restart your computer and re-run this script."
    exit
} else {
    Write-Host "Ubuntu is already installed."
}

# Setup WSL environment
Write-Host "Setting up WSL environment..."

# Update and install dependencies
wsl -d Ubuntu -e bash -c "sudo apt update && sudo apt install -y clang libicu-dev libssl-dev libcurl4-openssl-dev"

# Install Swiftly
wsl -d Ubuntu -e bash -c "curl -L https://swiftlang.github.io/swiftly/swiftly-install.sh | bash"

# Source the Swiftly environment script and install the latest Swift
wsl -d Ubuntu -e bash -c "source ~/.local/share/swiftly/env.sh"
wsl -d Ubuntu -e bash -c "source ~/.local/share/swiftly/env.sh && swiftly install latest"
wsl -d Ubuntu -e bash -c "source ~/.local/share/swiftly/env.sh && swiftly use latest"
# Verify the Swift installation
wsl -d Ubuntu -e bash -c "source ~/.local/share/swiftly/env.sh && swift --version"

# Install Vapor Toolbox
wsl -d Ubuntu -e bash -c "cd /tmp/ && git clone https://github.com/vapor/toolbox.git && cd toolbox && source ~/.local/share/swiftly/env.sh && swift build -c release"

# Move the built executable to a directory in your PATH
wsl -d Ubuntu -e bash -c "sudo mv /tmp/toolbox/.build/release/vapor /usr/local/bin/"

# Verify Vapor installation
wsl -d Ubuntu -e bash -c "vapor --help"

Write-Host "WSL environment and Vapor Toolbox setup completed."




