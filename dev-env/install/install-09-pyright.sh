#!/bin/bash
# file: install-09-pyright.sh
source ~/software/scripts-dev/std-tool.sh

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
