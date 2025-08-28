#!/bin/bash
# file = install-06-black.sh

# imports
source ~/software/scripts-dev/std-tool.sh
source ~/software/scripts-dev/tool/version.sh
source ~/software/scripts-dev/tool/git-repo.sh
source ~/software/scripts-dev/tool/installation.sh
source ~/software/scripts-dev/tool/update-path.sh

# Set exit on error
set -e

declare -A SOFTWARE=(
    [name]="Black (Python Code Formatter)"
    [binary]=black
    [dependency]=pipx
    [version_to_install]=$(get_latest_lts_github_release "psf/black")
)
SOFTWARE[binary_directory]="${HOME}/.local/bin"
SOFTWARE[binary_path]="${SOFTWARE[binary_directory]}/${SOFTWARE[binary]}"
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

# install|upgrade dependency
function install_dependency() {
    local dependency="${SOFTWARE[dependency]}"

    echo "Checking dependency ${dependency}..."

    if sudo nala install "${dependency}"; then
        echo "done!"
        return "$OK"
    else
        echo "ERROR: failed to install dependency ${dependency}" >&2
        return "$ERROR"
    fi

}

function install_software() {
    bash -c "${SOFTWARE[install_cmd]}"
}

function update_path() {
    local bin_dir="${SOFTWARE[binary_directory]}"
    local bin_path="${SOFTWARE[binary_path]}"

    echo "Updating \$PATH..."
    [[ ! -d "$bin_dir" ]] && mkdir -p "$bin_dir"

    if update_PATH "$bin_path"; then
        echo "done!"
        return "$OK"
    else
        echo "ERROR: failed to update \$PATH with $bin_path" >&2
        return "$ERROR"
    fi
}

# param: action = installation | upgrade
function manage_software() {
    local action="$1"

    install_dependency || return "$ERROR"

    if ! install_software; then
        echo "ERROR: ${SOFTWARE[name]} $action failed" >&2
        return "$ERROR"
    fi

    update_path || return "$ERROR"

    echo "OK: ${SOFTWARE[name]} $action successfull!"
    return "$OK"
}

function run() {
    local outcome
    report_what_to_do
    outcome=$?

    # software is up to date
    if ((outcome == OPERATION[nothing_to_do])); then
        echo "Nothing to do"
        return "$OK"
    fi

    # install software
    if ((outcome == OPERATION[install])); then
        manage_software "installation" || return "$ERROR"
        return "$OK"
    fi

    # upgrade software
    if ((outcome == OPERATION[upgrade])); then
        manage_software "upgrade" || return "$ERROR"
        return "$OK"
    fi

    # handle error
    echo "ERROR: invalid exit status of function 'report_what_to_do()' in script ${THIS_SCRIPT_PATH}" >&2
    return "$ERROR"
}

run
