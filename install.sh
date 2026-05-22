#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR=""

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
        brew bundle --file Brewfile

    elif [[ $1 == "ubuntu" ]]; then
        print_info "Installing dependencies with apt..."
        sudo apt update
        sudo apt install -y git stow zsh

        if ! command -v mise &> /dev/null; then
            print_info "Installing mise..."
            curl https://mise.run | sh
        fi
    fi

    export PATH="$HOME/.local/bin:$PATH"
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

backup_target() {
    local target="$1"
    local relative_path

    if [[ ! -e "$target" && ! -L "$target" ]]; then
        return 0
    fi

    if [[ -L "$target" ]]; then
        return 0
    fi

    if [[ -z "$BACKUP_DIR" ]]; then
        BACKUP_DIR="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        print_info "Backing up existing files to $BACKUP_DIR..."
    fi

    relative_path="${target#$HOME/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$relative_path")"
    mv "$target" "$BACKUP_DIR/$relative_path"
}

backup_existing_configs() {
    local targets=(
        "$HOME/.config/ghostty/config"
        "$HOME/.gitconfig"
        "$HOME/.ideavim"
        "$HOME/.tmux.conf"
        "$HOME/.config/mise.toml"
        "$HOME/.config/starship.toml"
        "$HOME/.zshenv"
        "$HOME/.zshrc"
        "$HOME/.zsh_plugins.txt"
    )

    for target in "${targets[@]}"; do
        backup_target "$target"
    done
}

stow_configurations() {
    print_info "Stowing configurations..."
    backup_existing_configs

    dirs_to_stow=("ghostty" "home" "mise" "starship" "zsh")

    for dir in "${dirs_to_stow[@]}"; do
        print_info "Stowing $dir..."
        stow --dir="$SCRIPT_DIR" --target="$HOME" -R "$dir"
    done
}

install_mise_tools() {
    print_info "Installing tools managed by mise..."
    mise install
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

    install_antidote

    stow_configurations

    install_mise_tools

    change_shell_to_zsh

    print_success "Installation complete! Please restart your terminal for changes to take effect."
}

main
