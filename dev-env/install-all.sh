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
        print_success "all software installed successfully!"
        return "$OK"
    else
        print_error "failed to install software"
        return "$ERROR"
    fi
}

install_all
