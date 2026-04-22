#!/usr/bin/env bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/lsb-release ]]; then
        echo "ubuntu"
    else
        echo "unknown"
    fi
}

install_package_managers() {
    if [[ $1 == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            print_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    fi
}

install_dependencies() {
    if [[ $1 == "macos" ]]; then
        print_info "Installing dependencies with Homebrew..."
        brew install git stow mise zsh

    elif [[ $1 == "ubuntu" ]]; then
        print_info "Installing dependencies with apt..."
        sudo apt update
        sudo apt install -y git stow zsh

        if ! command -v mise &> /dev/null; then
            print_info "Installing mise..."
            curl https://mise.run | sh
        fi
    fi
}

install_antidote() {
    print_info "Installing antidote..."
    if [[ ! -d "${ZDOTDIR:-~}/.antidote" ]]; then
        git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
    else
        print_info "antidote is already installed"
    fi
}

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

stow_configurations() {
    print_info "Stowing configurations..."
    cd ~/dotfiles

    [ -e ~/.zshrc ] && rm ~/.zshrc
    [ -e ~/.gitconfig ] && rm ~/.gitconfig

    dirs_to_stow=("ghostty" "home" "mise" "nvim" "starship" "zsh")

    for dir in "${dirs_to_stow[@]}"; do
        print_info "Stowing $dir..."
        stow -R "$dir"
    done
}

main() {
    local os
    os=$(detect_os)

    if [[ $os == "unknown" ]]; then
        print_error "Unsupported operating system"
        exit 1
    fi

    print_info "Setting up dotfiles for $os..."

    install_package_managers "$os"

    install_dependencies "$os"

    change_shell_to_zsh

    install_antidote

    stow_configurations

    print_success "Installation complete! Please restart your terminal for changes to take effect."
    print_info "Note: You may need to manually install additional tools mentioned in your configs."
}

main
