#!/bin/bash
# file = install-nvm.sh
# nvm: Node Version Manager

set -e # Exit immediately if a command exits with a non-zero status.
# imports
source ~/software/scripts-dev/tool/installation.sh
source ~/software/scripts-dev/tool/git-repo.sh
source ~/software/scripts-dev/exit-codes.sh

declare -A PROGRAM=(
    [id]=nvm
    [name]="Node Version Manager"
    [version]=$(get_latest_lts_github_release "nvm-sh/nvm")

)

function install_program() {
    local prog_id="${PROGRAM[id]}"
    local prog_name="${PROGRAM[name]}"
    local prog_version="v${PROGRAM[version]}"

    is_installed "${prog_id}" && {
        echo "${prog_name} is already installed!"
        return "$OK"
    }

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/"${prog_version}"/install.sh | bash && {
        echo "OK: ${prog_name} installed successfully!"
        return "$OK"
    }

    echo "ERROR: failed to install ${prog_name}" >&2
    return "$ERROR"
}

install_program && reload_shell_config
