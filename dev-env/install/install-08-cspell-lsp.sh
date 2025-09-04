#!/bin/bash
# file = install-08-cspell-lsp.sh
source ~/software/scripts-dev/std-tool.sh

declare -A SOFTWARE=(
    [name]="Spell Checker LSP"
    [repo]="@vlabo/cspell-lsp"
)

function install_software() {
    echo "Checking ${SOFTWARE[name]}..."

    if npm install -g "${SOFTWARE[repo]}"; then
        refresh_zsh || return "$ERROR"
        echo "done!"
        return "$OK"
    else
        echo "ERROR: ${SOFTWARE[name]} failed" >&2
        return "$ERROR"
    fi
}

install_software
