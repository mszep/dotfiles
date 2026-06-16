#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos";;
        Linux*) echo "linux";;
        *) echo "unknown";;
    esac
}

install_prerequisites() {
    local os="$1"
    print_status "Installing prerequisites..."

    if [ "$os" = "macos" ]; then
        if ! command -v brew >/dev/null 2>&1; then
            print_warning "Homebrew not found. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install git neovim fish tmux
    elif [ "$os" = "linux" ]; then
        if command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y git fish tmux curl
            install_nvim_latest
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y git fish tmux curl
            install_nvim_latest
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm git fish tmux
            install_nvim_latest
        else
            print_warning "No supported package manager found. Please install git, fish, and tmux manually."
        fi
    fi

    print_success "Prerequisites installed"
}

install_nvim_latest() {
    print_status "Installing latest Neovim..."

    local nvim_version
    nvim_version=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name"' | sed 's/.*v\([^"]*\).*/\1/')

    if [ -z "$nvim_version" ]; then
        print_warning "Could not fetch latest nvim version, falling back to apt"
        sudo apt install -y neovim 2>/dev/null || true
        return
    fi

    local arch
    arch=$(uname -m)
    local nvim_package
    case "$arch" in
        x86_64) nvim_package="linux64";;
        aarch64|arm64) nvim_package="linuxarm64";;
        *) print_warning "Unknown architecture: $arch"; return;;
    esac

    local nvim_url="https://github.com/neovim/neovim/releases/download/v${nvim_version}/nvim-${nvim_version}-${nvim_package}.tar.gz"
    local temp_dir=$(mktemp -d)

    curl -sL "$nvim_url" | tar xz -C "$temp_dir"

    sudo cp -r "$temp_dir/nvim-${nvim_version}-${nvim_package}/"/* /usr/local/

    rm -rf "$temp_dir"

    print_success "Installed Neovim v${nvim_version}"
}

install_nvim() {
    print_status "Installing Neovim configuration..."

    local nvim_source="$DOTFILES_DIR/nvim"
    local nvim_target="$HOME/.config/nvim"

    mkdir -p "$HOME/.config"

    if [ -d "$nvim_target" ]; then
        local backup_dir="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing nvim config to $backup_dir"
        mv "$nvim_target" "$backup_dir"
    fi

    cp -r "$nvim_source" "$nvim_target"
    chmod -R 755 "$nvim_target"

    if command -v nvim >/dev/null 2>&1; then
        print_success "Neovim configuration installed"
    else
        print_warning "Neovim not found - config installed but neovim not available"
    fi
}

install_fish() {
    print_status "Installing Fish shell configuration..."

    local fish_source="$DOTFILES_DIR/fish"
    local fish_target="$HOME/.config/fish"

    mkdir -p "$HOME/.config"

    if [ -d "$fish_target" ]; then
        local backup_dir="$HOME/.config/fish.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing fish config to $backup_dir"
        mv "$fish_target" "$backup_dir"
    fi

    cp -r "$fish_source" "$fish_target"
    chmod -R 755 "$fish_target"

    if command -v fisher >/dev/null 2>&1; then
        print_status "Installing fish plugins..."
        fish -c "fisher install jorgebucaran/fisher" 2>/dev/null || true
        fish -c "fisher install edc/bass" 2>/dev/null || true
    else
        print_warning "Fisher not found. Run 'fish -c fisher install jorgebucaran/fisher' after installation"
    fi

    if command -v fish >/dev/null 2>&1; then
        print_success "Fish configuration installed"
    else
        print_warning "Fish not found - config installed but fish not available"
    fi
}

install_tmux() {
    print_status "Installing Tmux configuration..."

    local tmux_source="$DOTFILES_DIR/tmux/tmux.conf"
    local tmux_target="$HOME/.tmux.conf"

    if [ -f "$tmux_target" ]; then
        local backup_dir="$HOME/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing tmux config to $backup_dir"
        cp "$tmux_target" "$backup_dir"
    fi

    cp "$tmux_source" "$tmux_target"

    if command -v tmux >/dev/null 2>&1; then
        print_success "Tmux configuration installed"
    else
        print_warning "Tmux not found - config installed but tmux not available"
    fi
}

set_default_shell() {
    local shell_path
    shell_path=$(command -v fish 2>/dev/null) || return

    local current_shell
    current_shell=$(getent passwd "$USER" | cut -d: -f7)

    if [ "$current_shell" != "$shell_path" ]; then
        print_status "Setting fish as default shell..."

        if [ "$(detect_os)" = "macos" ]; then
            if ! grep -q "$shell_path" /etc/shells 2>/dev/null; then
                echo "$shell_path" | sudo tee -a /etc/shells >/dev/null
            fi
            sudo chsh -s "$shell_path"
        else
            sudo usermod -s "$shell_path" "$USER"
        fi

        print_success "Default shell set to fish"
    fi
}

main() {
    echo "========================================="
    echo "  Dotfiles Installation Script"
    echo "========================================="
    echo

    local os
    os=$(detect_os)
    print_status "Detected OS: $os"

    if [ "$os" = "unknown" ]; then
        print_error "Unsupported operating system"
        exit 1
    fi

    echo
    echo "This will install:"
    echo "  - Neovim configuration"
    echo "  - Fish shell configuration"
    echo "  - Tmux configuration"
    echo

    install_prerequisites "$os"
    echo

    install_nvim
    echo

    install_fish
    echo

    install_tmux
    echo

    set_default_shell

    echo
    echo "========================================="
    print_success "Installation complete!"
    echo "========================================="
    echo
    echo "Next steps:"
    echo "  1. Restart your terminal or run: exec fish"
    echo "  2. Start nvim to trigger plugin installation"
    echo "  3. Start tmux to trigger TPM plugin installation"
    echo
    echo "Installed configs:"
    echo "  - ~/.config/nvim"
    echo "  - ~/.config/fish"
    echo "  - ~/.tmux.conf"
    echo
}

main "$@"
