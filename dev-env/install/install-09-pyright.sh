#!/bin/bash
# file: install-09-pyright.sh

# root directory
ROOT_DIR="$HOME/software/scripts"
source "${ROOT_DIR}"/tool/std.sh

declare -A SOFTWARE=(
    [name]=PyRight
    [binary]=pyright
)

function install_software() {
    echo "Checking ${SOFTWARE[name]}..."

    if npm install -g "${SOFTWARE[binary]}"; then
        refresh_zsh || return "$ERROR"
        echo "done!"
        return "$OK"
    else
        echo "ERROR: ${SOFTWARE[name]} failed" >&2
        return "$ERROR"
    fi
}

install_software
