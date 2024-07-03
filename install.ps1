function Test-IsAdministrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}


if (-not (Test-IsAdministrator)) {
    Write-Host "This script requires administrator privileges for some operations. Please run the script as an administrator."
    exit
}


Write-Host "Running administrative operations..."
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Start-Sleep -Seconds 5


if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop is not installed. Installing Scoop..."
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
scoop install versions/nodejs20


$wslInstalled = (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq 'Enabled'

function IsWSLDistributionInstalled {
    param (
        [string]$distributionName
    )

    
    $wslListAll = wsl --list --all

    
    $isInstalled = $wslListAll -contains $distributionName

    return $isInstalled
}


$wslInstalled = $null -ne (wsl --list --all)

if (-not $wslInstalled) {
    Write-Host "Installing WSL..."
    wsl --install
    Write-Host "WSL installed. Please restart your computer and re-run this script."
    exit
}


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


Write-Host "Setting up WSL environment..."


wsl -d Ubuntu -e bash -c "sudo apt update && sudo apt install -y clang libicu-dev libssl-dev libcurl4-openssl-dev"


wsl -d Ubuntu -e bash -c "curl -L https://swiftlang.github.io/swiftly/swiftly-install.sh | bash"


wsl -d Ubuntu -e bash -c "source ~/.local/share/swiftly/env.sh"
wsl -d Ubuntu -e bash -c "source ~/.local/share/swiftly/env.sh && swiftly install latest"
wsl -d Ubuntu -e bash -c "source ~/.local/share/swiftly/env.sh && swiftly use latest"

wsl -d Ubuntu -e bash -c "source ~/.local/share/swiftly/env.sh && swift --version"


wsl -d Ubuntu -e bash -c "cd /tmp/ && git clone https://github.com/vapor/toolbox.git && cd toolbox && source ~/.local/share/swiftly/env.sh && swift build -c release"


wsl -d Ubuntu -e bash -c "sudo mv /tmp/toolbox/.build/release/vapor /usr/local/bin/"


wsl -d Ubuntu -e bash -c "vapor --help"

Write-Host "WSL environment and Vapor Toolbox setup completed."





