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





