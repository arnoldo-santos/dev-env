#!/bin/bash
# file = install-01-nvm.sh
# nvm: Node Version Manager

# root directory
ROOT_DIR="$HOME/software/scripts"
# imports
source "${ROOT_DIR}"/tool/installation.sh
source "${ROOT_DIR}"/tool/git-repo.sh
source "${ROOT_DIR}"/tool/std.sh

declare -A SOFTWARE=(
    [id]=nvm
    [name]="Node Version Manager"
    [version]=$(get_latest_lts_github_release "nvm-sh/nvm")

)

function install_program() {
    local prog_id="${SOFTWARE[id]}"
    local prog_name="${SOFTWARE[name]}"
    local prog_version="${SOFTWARE[version]}"

    is_installed "${prog_id}" && {
        echo "${prog_name} is already installed!"
        return "$OK"
    }

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/"v${prog_version}"/install.sh | bash && {
        echo "OK: ${prog_name} installed successfully!"
        return "$OK"
    }

    echo "ERROR: failed to install ${prog_name}" >&2
    return "$ERROR"
}

install_program && reload_zsh_config
