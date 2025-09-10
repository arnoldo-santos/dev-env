#!/bin/bash
# file = install-bash-lsp.sh

# root directory
ROOT_DIR="$HOME/software/scripts"
source "${ROOT_DIR}"/tool/std.sh
source "${ROOT_DIR}"/tool/installation.sh
#

declare -A SOFTWARE=(
    [name]="Bash Language Server"
    [binary]="bash-language-server"
)

function report_what_to_do() {
    if is_installed "${SOFTWARE[binary]}"; then
        echo "Upgrading '${SOFTWARE[name]}'..."
        return "$OK"
    fi
    # else
    echo "Installing '${SOFTWARE[name]}'..."
    return "$OK"
}

function install_software() {
    # install dependency
    sudo nala install shellcheck || {
        echo "ERROR: failed to install \`shellcheck\`" >&2
        return "$ERROR"
    }

    # install software
    if npm i -g "${SOFTWARE[binary]}"; then
        echo "done!"
        return "$OK"
    fi

    # else
    echo "ERROR: '${SOFTWARE[name]}' failed" >&2
    return "$ERROR"
}

function run() {
    report_what_to_do
    install_software
}

run
