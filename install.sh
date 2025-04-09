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
        brew install git stow neovim exa bat atuin zoxide mise starship tmux zsh unzip yazi
    elif [[ $1 == "ubuntu" ]]; then
        print_info "Installing dependencies with apt..."
        sudo apt update
        sudo apt install -y git stow neovim bat curl eza tmux zsh unzip \
            ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick # yazi related

        # Install atuin if not already installed
        if ! command -v atuin &> /dev/null; then
            print_info "Installing atuin..."
            bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)
        fi

        # Install starship if not already installed
        if ! command -v starship &> /dev/null; then
            print_info "Installing starship..."
            curl -sS https://starship.rs/install.sh | sh
        fi

        # Install mise if not already installed
        if ! command -v mise &> /dev/null; then
            print_info "Installing mise..."
            curl https://mise.run | sh
        fi
    fi
}

# Install antidote (zsh plugin manager)
install_antidote() {
    print_info "Installing antidote..."
    if [[ ! -d "${ZDOTDIR:-~}/.antidote" ]]; then
        git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
    else
        print_info "antidote is already installed"
    fi
}

# Install JetBrains Mono Nerd Font
install_fonts() {
    print_info "Installing JetBrains Mono Nerd Font..."
    if [[ $1 == "macos" ]]; then
        brew tap homebrew/cask-fonts
        brew install --cask font-jetbrains-mono-nerd-font
    elif [[ $1 == "ubuntu" ]]; then
        # Install fontconfig if not already installed
        if ! command -v fc-cache &> /dev/null; then
            print_info "Installing fontconfig..."
            sudo apt install -y fontconfig
        fi

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

# Stow configurations
stow_configurations() {
    print_info "Stowing configurations..."
    cd ~/dotfiles

    # stow errors if exists
    [ -e ~/.zshrc ] && rm ~/.zshrc
    [ -e ~/.gitconfig ] && rm ~/.gitconfig

    dirs_to_stow=("alacritty" "home" "mise" "nvim" "starship" "zsh")

    for dir in "${dirs_to_stow[@]}"; do
        print_info "Stowing $dir..."
        stow -R "$dir"
    done
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

    # Stow configurations
    stow_configurations

    print_success "Installation complete! Please restart your terminal for changes to take effect."
    print_info "Note: You may need to manually install additional tools mentioned in your configs."
}

# Run the installation
main
