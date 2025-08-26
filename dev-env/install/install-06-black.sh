#!/bin/bash
# file = install-06-black.sh

# imports
source ~/software/scripts-dev/std-tool.sh
source ~/software/scripts-dev/tool/version.sh
source ~/software/scripts-dev/tool/git-repo.sh
source ~/software/scripts-dev/dev-env/tool/installation.sh
source ~/software/scripts-dev/dev-env/tool/update-path.sh

# Set exit on error
set -e

declare -A SOFTWARE=(
    [name]="Black (Python Code Formatter)"
    [binary]=black
    [dependency]=pipx
    [version_to_install]=$(get_latest_lts_github_release "psf/black")
)
SOFTWARE[binary_path]="${HOME}/.local/bin/${SOFTWARE[binary]}"
SOFTWARE[install_cmd]="${SOFTWARE[dependency]} install ${SOFTWARE[binary]}"

# ------------ NEW CODE ---------------------

function get_black_installed_version() {
    local version_output

    if version_output=$(black --version 2>/dev/null); then
        echo "$version_output" | head -n 1 | sed 's/black, \([0-9.]*\).*/\1/'
        return "$OK"
    else
        echo "ERROR: failed to get version of ${SOFTWARE[name]}" >&2
        return "$ERROR"
    fi
}

function report_what_to_do() {
    echo "Checking ${SOFTWARE[name]}..."

    # software is installed
    if is_installed "${SOFTWARE[binary]}"; then

        SOFTWARE[installed_version]=$(get_black_installed_version)

        # software is up to date
        if ! version_is_greater "${SOFTWARE[version_to_install]}" "${SOFTWARE[installed_version]}"; then
            echo "${SOFTWARE[name]} v${SOFTWARE[installed_version]} is up to date!"
            return "${OPERATION[nothing_to_do]}"
        fi

        # software needs upgrade
        echo "New version found: ${SOFTWARE[version_to_install]}"
        echo "Upgrading ${SOFTWARE[name]}..."
        return "${OPERATION[upgrade]}"
    fi

    # software is not installed
    echo "Installing ${SOFTWARE[name]}..."
    return "${OPERATION[install]}"
}

function install_software() {
    if bash -c "${SOFTWARE[install_cmd]}"; then
        echo "done!"
        return "$OK"
    else
        echo "ERROR: failed to install ${SOFTWARE[name]}" >&2
        return 1 # fuck
    fi

}

# -------------------------------------------
function check_dependency() {
    local dependency="${SOFTWARE[dependency]}"

    echo "Checking dependency ${dependency}..."

    if sudo nala install "${dependency}"; then
        echo "done!"
        return 0 # ok
    else
        echo "ERROR: failed to install dependency ${dependency}" >&2
        return 1 # fuck
    fi
}

function check_program() {
    local binary="${SOFTWARE[binary]}"
    local prog_name="${SOFTWARE[name]}"
    local prog_full_name="${SOFTWARE[full_name]}"

    echo "Checking ${prog_full_name}..."

    if is_installed "${binary}"; then
        echo "${prog_name} is already installed"
        echo "Upgrading it..."
    else
        echo "${prog_name} isn't installed"
        echo "Installing it..."
    fi
}

function install_program() {
    local prog_name="${SOFTWARE[name]}"
    local install_cmd="${SOFTWARE[install_cmd]}"

    if bash -c "${install_cmd}"; then
        echo "done!"
        return 0 # ok
    else
        echo "ERROR: failed to install ${prog_name}" >&2
        return 1 # fuck
    fi

}

function update_PATH() {
    local bin_path="${SOFTWARE[binary_path]}"

    echo "Updating \$PATH..."
    [[ ! -d "$bin_path" ]] && mkdir -p "$bin_path"

    if update_path "$bin_path"; then
        echo "done!"
        return 0 # ok
    else
        echo "ERROR: failed to update \$PATH with $bin_path" >&2
        return 1 # fuck
    fi

}

function manage_program() {
    local prog_full_name="${SOFTWARE[full_name]}"

    check_program
    check_dependency || return 1 # fuck
    install_program || return 1  # fuck
    update_PATH || return 1      # fuck

    echo "${prog_full_name}: OK!"
    return 0 # ok
}

manage_program
