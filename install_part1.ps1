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