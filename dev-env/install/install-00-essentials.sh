#!/bin/bash
# file: install-essentials.sh

# Set strict mode
set -euo pipefail
# import
source ~/software/scripts-dev/exit-codes.sh
source ~/software/scripts-dev/tool/installation.sh
source ~/software/scripts-dev/tool/bash-files.sh

function add_rust_reload_code_to_zshrc() {
    # Define the lines to add
    local rust_reload_code="
# Rust
. \"\${HOME}/.cargo/env\"
"

    # Check if the lines already exist in ~/.zshrc
    grep -q "Rust" ~/.zshrc && {
        say "OK: 'Rust' already exists in ~/.zshrc"
        return "$OK" # success
    }

    # Append the lines to ~/.zshrc
    put "${rust_reload_code}" >>~/.zshrc && {
        say "OK: Rust's reload code added to ~/.zshrc successfully!"
        return "$OK"
    }

    say "ERROR: failed to add Rust's reload code to ~/.zshrc"
    return "$ERROR"
}

function install_rust() {
    if is_installed rustc; then
        # rustup is installed. check Rust compiler
        rustup override set stable && rustup update stable && add_rust_reload_code_to_zshrc && return "$OK" # success

        say "ERROR: failed to update Rust" >&2
        return "$ERROR"
    else
        # install rustup
        if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh; then
            # rustup installed successfully. check Rust compiler
            rustup override set stable && rustup update stable && add_rust_reload_code_to_zshrc && return "$OK"

            say "ERROR: failed to update Rust" >&2
            return "$ERROR"
        fi

        say "ERROR: Rust installation failed" >&2
        return "$ERROR"
    fi
}

function install_clipboard() {
    case $XDG_SESSION_TYPE in
    x11) sudo nala install xclip || {
        say "ERROR: failed to install 'xclip'" >&2
        return "$ERROR"
    } ;;
    wayland) sudo nala install wl-clipboard || {
        say "ERROR: failed to install 'wl-clipboard'" >&2
        return "$ERROR"
    } ;;
    *)
        say "ERROR: unknown session type: $XDG_SESSION_TYPE" >&2
        return "$ERROR"
        ;;
    esac
    return "$OK"
}

function install_programs() {
    echo "Installing software..."

    if is_installed nala; then
        sudo nala update && sudo nala upgrade
    else
        sudo apt update && sudo apt upgrade
        echo "nala..."
        sudo apt install nala || {
            echo "ERROR: failed to install 'nala'" >&2
            return "${ERROR}"
        }
        echo "done!"
    fi

    echo "curl, wget, git, build-essential..."
    sudo nala install curl wget git build-essential || {
        echo "ERROR: installation failed" >&2
        return "${ERROR}"
    }
    echo "done!"

    say "clipboard copy..."
    install_clipboard || return "$ERROR"
    say "done!"

    say "rustup..."
    install_rust || return "$ERROR"
    say "done!"

    say "zip..."
    sudo nala install zip || return "$ERROR"
    say "done!"

    say "unzip..."
    sudo nala install unzip || return "$ERROR"
    say "done!"

    say "Taplo..."
    npm install -g @taplo/cli || return "$ERROR"
    say "done!"

    return "$OK"
}

install_programs && reload_shell_config
