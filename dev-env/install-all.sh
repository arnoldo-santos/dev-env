#!/bin/bash
# file = install-all.sh

# Set strict mode
set -euo pipefail
# import
source ~/software/scripts/exit-codes.sh
source ~/software/scripts/tool/bash-files.sh

function install_all() {
    local scripts
    scripts=("${HOME}"/software/scripts/dev-env/install/install-*.sh)

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
