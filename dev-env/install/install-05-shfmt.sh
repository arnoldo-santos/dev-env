#!/bin/bash
# file = install-shfmt.sh
# shfmt: to format scripts

# set -e # Exit immediately if a command exits with a non-zero status.
THIS_SCRIPT_PATH=$(realpath "${BASH_SOURCE[0]}")

# imports
source ~/software/scripts-dev/std-tool.sh
source ~/software/scripts-dev/tool/symlink.sh
source ~/software/scripts-dev/tool/version.sh
source ~/software/scripts-dev/tool/git-repo.sh
source ~/software/scripts-dev/tool/installation.sh

# shfmt's data
declare -A SOFTWARE=(
    [name]="ShellFormat"
    [binary]=shfmt
    [parent_dir]="${HOME}/software"
    [download_dir]="${HOME}/Downloads"
    [version_to_install]=$(get_latest_lts_github_release "mvdan/sh")
)

SOFTWARE[binary_path]="${HOME}/go/bin/${SOFTWARE[binary]}"
SOFTWARE[symlink]="${HOME}/.local/bin/${SOFTWARE[binary]}"

function report_what_to_do() {
    echo "Checking ${SOFTWARE[name]}..."

    # software is installed
    if is_installed "${SOFTWARE[binary]}"; then

        SOFTWARE[installed_version]=$("${SOFTWARE[binary]}" --version | cut -d' ' -f3 | tr -d 'v')

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
    if go install mvdan.cc/sh/v3/cmd/shfmt@latest; then
        if make_symlink "${SOFTWARE[binary_path]}" "${SOFTWARE[symlink]}"; then
            return "$OK"
        fi
        echo "ERROR: function 'make_symlink()' failed" >&2
        return "$ERROR"
    fi

    echo "ERROR: command 'go instasll' failed" >&2
    return "$ERROR"
}

function manage_software() {
    local action="$1"

    install_software || {
        echo "ERROR: ${SOFTWARE[name]} $action failed" >&2
        return "$ERROR"
    }
    echo "done!"
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
