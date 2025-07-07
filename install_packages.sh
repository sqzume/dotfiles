#!/bin/bash

# Arch Linux Packages Auto-installer
# Usage: ./install_packages.sh

set -e # Exit on error

# Package list file
PACKAGE_LIST="packages.txt"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
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

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        print_info "pacman will prompt for sudo password when needed"
        exit 1
    fi
}

# Function to update system
update_system() {
    print_info "Updating system packages..."
    sudo pacman -Syu --noconfirm
    print_success "System updated successfully"
}

# Function to install packages from official repositories
install_official_packages() {
    local packages=("$@")

    if [[ ${#packages[@]} -eq 0 ]]; then
        print_warning "No official packages to install"
        return 0
    fi

    print_info "Installing official packages: ${packages[*]}"

    # Check which packages are already installed
    local to_install=()
    for pkg in "${packages[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        else
            print_warning "Package '$pkg' is already installed"
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        sudo pacman -S --needed --noconfirm "${to_install[@]}"
        print_success "Official packages installed successfully"
    else
        print_info "All official packages are already installed"
    fi
}

# Function to install AUR packages (requires yay)
install_aur_packages() {
    local packages=("$@")

    if [[ ${#packages[@]} -eq 0 ]]; then
        print_warning "No AUR packages to install"
        return 0
    fi

    # Check if yay is installed
    if ! command -v paru &>/dev/null; then
        print_error "paru is required for AUR packages but not installed"
        read -p "Do you install paru? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git clone https://aur.archlinux.org/paru.git
            cd paru
            makepkg -si
        else
            return 0
        fi
    fi

    print_info "Installing AUR packages: ${packages[*]}"
    paru -S --needed --noconfirm "${packages[@]}"
    print_success "AUR packages installed successfully"
}

parse_package_list() {
    local file="$1"
    local official_packages=()
    local aur_packages=()

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Remove leading/trailing whitespace
        line=$(echo "$line" | xargs)

        # Skip empty lines and comments
        if [[ -z "$line" || "$line" =~ ^#.*$ ]]; then
            continue
        fi

        # Check if it's an AUR package (marked with aur: prefix)
        if [[ "$line" =~ ^aur:(.+)$ ]]; then
            aur_packages+=("${BASH_REMATCH[1]}")
        else
            official_packages+=("$line")
        fi
    done < "$file"

    # Install packages
    install_official_packages "${official_packages[@]}"
    install_aur_packages "${aur_packages[@]}"
}

main() {
    local package_list_file="${1:-$PACKAGE_LIST}"

    # Check if running as root
    check_root

    print_info "Starting package installation from: $package_list_file"

    # Update system first
    read -p "Update system before installing packages? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        update_system
    else
        return 0
    fi

    # Parse and install packages
    parse_package_list "$package_list_file"

    print_success "Package installation completed!"
}

# Run main function with all arguments
main "$@"
