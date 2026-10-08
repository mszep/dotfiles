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
    print_status "Installing Neovim v0.11..."

    local nvim_version="0.11.4"

    local nvim_package
    case "$(uname -m)" in
        x86_64) nvim_package="linux-x86_64";;
        aarch64|arm64) nvim_package="linux-arm64";;
        *) print_warning "Unknown architecture: $(uname -m)"; return;;
    esac

    print_status "Detected architecture: $(uname -m) -> ${nvim_package}"

    local nvim_url="https://github.com/neovim/neovim/releases/download/v${nvim_version}/nvim-${nvim_package}.tar.gz"
    local temp_dir=$(mktemp -d)

    print_status "Downloading from: $nvim_url"
    curl -fL "$nvim_url" | tar xz -C "$temp_dir"

    local nvim_dir="$temp_dir/nvim-${nvim_package}"
    if [ ! -d "$nvim_dir" ]; then
        nvim_dir="$temp_dir/nvim-linux-x86_64"
    fi

    local local_bin="$HOME/.local/bin"
    mkdir -p "$local_bin"
    cp -r "$nvim_dir"/* "$local_bin/"

    if [[ ":$PATH:" != *":$local_bin:"* ]]; then
        print_status "Adding $local_bin to PATH"
        if [ -f "$HOME/.bashrc" ]; then
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
        fi
        if [ -f "$HOME/.profile" ]; then
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.profile"
        fi
        export PATH="$local_bin:$PATH"
    fi

    rm -rf "$temp_dir"

    print_success "Installed Neovim v${nvim_version} to ~/.local/bin"
}

install_nvim() {
    print_status "Installing Neovim configuration..."

    local nvim_source="$DOTFILES_DIR/nvim"
    local nvim_target="$HOME/.config/nvim"

    mkdir -p "$HOME/.config"

    # Already correctly linked?
    if [ -L "$nvim_target" ] && [ "$(readlink -f "$nvim_target")" = "$(readlink -f "$nvim_source")" ]; then
        print_success "Neovim configuration already symlinked to $nvim_source"
        return
    fi

    if [ -e "$nvim_target" ] || [ -L "$nvim_target" ]; then
        local backup_dir="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing nvim config to $backup_dir"
        mv "$nvim_target" "$backup_dir"
    fi

    # Symlink so the repo is the single source of truth across machines
    ln -s "$nvim_source" "$nvim_target"
    print_success "Neovim configuration symlinked: $nvim_target -> $nvim_source"

    if ! command -v nvim >/dev/null 2>&1; then
        print_warning "Neovim not found - config linked but neovim not available"
    fi
}

install_fish() {
    print_status "Installing Fish shell configuration..."

    local fish_source="$DOTFILES_DIR/fish"
    local fish_target="$HOME/.config/fish"

    mkdir -p "$HOME/.config"

    # Already correctly linked?
    if [ -L "$fish_target" ] && [ "$(readlink -f "$fish_target")" = "$(readlink -f "$fish_source")" ]; then
        print_success "Fish configuration already symlinked to $fish_source"
        return
    fi

    if [ -e "$fish_target" ] || [ -L "$fish_target" ]; then
        local backup_dir="$HOME/.config/fish.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing fish config to $backup_dir"
        mv "$fish_target" "$backup_dir"
    fi

    # Symlink so the repo is the single source of truth across machines
    # (machine-local overrides like fish/conf.d/local.fish stay untracked)
    ln -s "$fish_source" "$fish_target"
    print_success "Fish configuration symlinked: $fish_target -> $fish_source"

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

    # Already correctly linked?
    if [ -L "$tmux_target" ] && [ "$(readlink -f "$tmux_target")" = "$(readlink -f "$tmux_source")" ]; then
        print_success "Tmux configuration already symlinked to $tmux_source"
        return
    fi

    if [ -e "$tmux_target" ] || [ -L "$tmux_target" ]; then
        local backup_dir="$HOME/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing tmux config to $backup_dir"
        mv "$tmux_target" "$backup_dir"
    fi

    # Symlink so the repo is the single source of truth across machines
    ln -s "$tmux_source" "$tmux_target"
    print_success "Tmux configuration symlinked: $tmux_target -> $tmux_source"

    if command -v tmux >/dev/null 2>&1; then
        print_success "Tmux configuration installed"
    else
        print_warning "Tmux not found - config installed but tmux not available"
    fi
}

install_ghostty() {
    print_status "Installing Ghostty configuration..."

    local ghostty_source="$DOTFILES_DIR/ghostty"
    local ghostty_target="$HOME/.config/ghostty"

    mkdir -p "$HOME/.config"

    # Already correctly linked?
    if [ -L "$ghostty_target" ] && [ "$(readlink -f "$ghostty_target")" = "$(readlink -f "$ghostty_source")" ]; then
        print_success "Ghostty configuration already symlinked to $ghostty_source"
        return
    fi

    if [ -e "$ghostty_target" ] || [ -L "$ghostty_target" ]; then
        local backup_dir="$HOME/.config/ghostty.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing ghostty config to $backup_dir"
        mv "$ghostty_target" "$backup_dir"
    fi

    # Symlink so the repo is the single source of truth across machines
    ln -s "$ghostty_source" "$ghostty_target"
    print_success "Ghostty configuration symlinked: $ghostty_target -> $ghostty_source"

    if command -v ghostty >/dev/null 2>&1; then
        print_success "Ghostty configuration installed"
    else
        print_warning "Ghostty not found - config linked but ghostty not available (brew install --cask ghostty)"
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
    echo "  - Ghostty configuration"
    echo

    install_prerequisites "$os"
    echo

    install_nvim
    echo

    install_fish
    echo

    install_tmux
    echo

    install_ghostty
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
    echo "  4. Reload Ghostty config with Cmd+Shift+, (or restart Ghostty)"
    echo
    echo "Installed configs:"
    echo "  - ~/.config/nvim"
    echo "  - ~/.config/fish"
    echo "  - ~/.tmux.conf"
    echo "  - ~/.config/ghostty"
    echo
}

main "$@"
