#!/bin/bash
# file = install-all.sh

# root directory
ROOT_DIR="$HOME/software/scripts"
# import
source "${ROOT_DIR}"/tool/std.sh
source "${ROOT_DIR}"/tool/bash-files.sh

function install_all() {
    local scripts
    scripts=("${ROOT_DIR}"/dev-env/install/install-*.sh)

    echo "Installing software..."

    if run_scripts "${scripts[@]}"; then
        echo "OK: all software installed successfully!"
        return "$OK"
    else
        echo "ERROR: failed to install software" >&2
        return "$ERROR"
    fi
}

install_all
