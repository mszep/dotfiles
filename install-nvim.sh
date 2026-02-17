#!/bin/bash

# Neovim Configuration Installer
# This script installs the nvim configuration from this dotfiles repository

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_SOURCE_DIR="$SCRIPT_DIR/nvim"
NVIM_TARGET_DIR="$HOME/.config/nvim"

print_status "Starting Neovim configuration installation..."

# Check if source nvim directory exists
if [ ! -d "$NVIM_SOURCE_DIR" ]; then
    print_error "Source nvim directory not found at $NVIM_SOURCE_DIR"
    exit 1
fi

# Create ~/.config directory if it doesn't exist
if [ ! -d "$HOME/.config" ]; then
    print_status "Creating ~/.config directory..."
    mkdir -p "$HOME/.config"
fi

# Handle existing nvim configuration
if [ -d "$NVIM_TARGET_DIR" ]; then
    BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    print_warning "Existing nvim configuration found at $NVIM_TARGET_DIR"
    print_status "Creating backup at $BACKUP_DIR"
    mv "$NVIM_TARGET_DIR" "$BACKUP_DIR"
    print_success "Backup created successfully"
fi

# Copy nvim configuration
print_status "Installing nvim configuration..."
cp -r "$NVIM_SOURCE_DIR" "$NVIM_TARGET_DIR"
print_success "Nvim configuration copied to $NVIM_TARGET_DIR"

# Set proper permissions
print_status "Setting proper permissions..."
chmod -R 755 "$NVIM_TARGET_DIR"

# Check if nvim is installed
if command -v nvim >/dev/null 2>&1; then
    print_success "Neovim is installed ($(nvim --version | head -n1))"
else
    print_warning "Neovim is not installed. Please install it first:"
    echo "  - On macOS: brew install neovim"
    echo "  - On Ubuntu/Debian: sudo apt install neovim"
    echo "  - On Fedora: sudo dnf install neovim"
    echo "  - On Arch: sudo pacman -S neovim"
fi

print_success "Installation completed successfully!"
print_status "Configuration installed at: $NVIM_TARGET_DIR"

# Display next steps
echo
echo "Next steps:"
echo "1. Start nvim to trigger plugin installation"
echo "2. Lazy.nvim will automatically install configured plugins"
echo "3. Restart nvim after plugin installation completes"
echo
echo "Configuration includes:"
echo "  - Core settings (lua/config/set.lua)"
echo "  - Key remappings (lua/config/remap.lua)"
echo "  - Lazy.nvim plugin manager (lua/config/lazy.lua)"
echo "  - Various plugins configured in lua/plugins/"

if [ -d "$BACKUP_DIR" ]; then
    echo
    print_status "Your previous configuration was backed up to:"
    echo "  $BACKUP_DIR"
fi