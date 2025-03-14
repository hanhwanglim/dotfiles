#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print with color
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/lsb-release ]]; then
        echo "ubuntu"
    else
        echo "unknown"
    fi
}

# Install package managers if needed
install_package_managers() {
    if [[ $1 == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            print_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    fi
}

# Install dependencies based on OS
install_dependencies() {
    if [[ $1 == "macos" ]]; then
        print_info "Installing dependencies with Homebrew..."
        brew install git stow neovim exa bat atuin zoxide mise starship tmux zsh
    elif [[ $1 == "ubuntu" ]]; then
        print_info "Installing dependencies with apt..."
        sudo apt update
        sudo apt install -y git stow neovim bat zoxide curl eza tmux zsh

        # Install atuin
        bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)

        # Install starship
        curl -sS https://starship.rs/install.sh | sh

        # Install mise
        curl https://mise.run | sh
    fi
}

# Install antidote (zsh plugin manager)
install_antidote() {
    print_info "Installing antidote..."
    git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
}

# Install JetBrains Mono Nerd Font
install_fonts() {
    print_info "Installing JetBrains Mono Nerd Font..."
    if [[ $1 == "macos" ]]; then
        brew tap homebrew/cask-fonts
        brew install --cask font-jetbrains-mono-nerd-font
    elif [[ $1 == "ubuntu" ]]; then
        mkdir -p ~/.local/share/fonts
        cd ~/.local/share/fonts
        curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
        unzip JetBrainsMono.zip
        rm JetBrainsMono.zip
        fc-cache -f -v
    fi
}

# Change default shell to zsh
change_shell_to_zsh() {
    print_info "Changing default shell to zsh..."
    if ! grep -q "$(command -v zsh)" /etc/shells; then
        print_info "Adding zsh to /etc/shells..."
        command -v zsh | sudo tee -a /etc/shells
    fi
    
    if [[ $SHELL != *"zsh"* ]]; then
        print_info "Changing default shell to zsh..."
        chsh -s "$(command -v zsh)"
        print_success "Shell changed to zsh. Please log out and log back in for changes to take effect."
    else
        print_info "zsh is already the default shell."
    fi
}

# Main installation
main() {
    local os
    os=$(detect_os)

    if [[ $os == "unknown" ]]; then
        print_error "Unsupported operating system"
        exit 1
    fi

    print_info "Setting up dotfiles for $os..."

    # Install package managers
    install_package_managers "$os"

    # Install dependencies
    install_dependencies "$os"

    # Change shell to zsh
    change_shell_to_zsh

    # Install antidote
    install_antidote

    # Install fonts
    install_fonts "$os"

    # Clone dotfiles if not already present
    if [[ ! -d ~/dotfiles ]]; then
        print_info "Cloning dotfiles repository..."
        git clone https://github.com/hanhwanglim/dotfiles.git ~/dotfiles
    fi

    # Stow configurations
    print_info "Stowing configurations..."
    cd ~/dotfiles
    for dir in */; do
        dir=${dir%/}
        print_info "Stowing $dir..."
        stow -R "$dir"
    done

    print_success "Installation complete! Please restart your terminal for changes to take effect."
    print_info "Note: You may need to manually install additional tools mentioned in your configs."
}

# Run the installation
main