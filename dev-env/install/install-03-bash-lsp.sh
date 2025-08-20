#!/bin/bash
# file = install-bash-lsp.sh

source ~/software/dev/dev-env/tool/installation.sh
source ~/software/dev/dev-env/tool/bash-files.sh
source ~/software/dev/dev-env/tool/action.sh

# Set strict mode
set -euo pipefail

SUCCESS=0
FAILURE=1

declare -A SOFTWARE=(
    [name]="Bash Language Server"
    [binary]="bash-language-server"
)

function report_what_to_do() {
    if is_installed "${SOFTWARE[binary]}"; then
        echo "Upgrading '${SOFTWARE[name]}'..."
        return 0
    fi
    # else
    echo "Installing '${SOFTWARE[name]}'..."
    return 0
}

function install_software_dependencies() {
    local dependency_scripts
    dependency_scripts=("${HOME}"/software/dev/dev-env/essentials/dependencies/bash-lsp/install-*.sh)

    echo "Installing ${SOFTWARE[name]}'s dependencies...'"

    if run_scripts "${dependency_scripts[@]}"; then
        echo "done!"
        return "${SUCCESS}"
    else
        echo "ERROR: failed to install some dependency" >&2
        return "${FAILURE}"
    fi
}

function install_software() {

    if npm i -g "${SOFTWARE[binary]}"; then
        echo "done!"
        return "${SUCCESS}"
    fi

    # else
    echo "ERROR: '${SOFTWARE[name]}' failed" >&2
    return "${FAILURE}"
}

function run() {
    report_what_to_do
    install_software_dependencies || return "$FAILURE"
    install_software
}

run
