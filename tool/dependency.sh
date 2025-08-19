#!/bin/bash
# file = tool/dependency.sh
set -e # Exit immediately if a command exits with a non-zero status.
source ~/software/scripts/exit-codes.sh
source ~/software/scripts/tool/installation.sh

# set the default package manager
PACKAGE_MANAGER=${PACKAGE_MANAGER:-nala}

# function to get missing dependencies
function get_not_installed_dependencies() {
    local dependencies=("$@")
    local uninstalled_deps=()

    for dep in "${dependencies[@]}"; do
        if ! is_installed "${dep}"; then
            uninstalled_deps+=("${dep}")
        fi
    done

    # only returns the array if it's not empty
    if [ ${#uninstalled_deps[@]} -gt 0 ]; then
        printf '%s\n' "${uninstalled_deps[@]}"
    fi
}

function install_dependencies() {
    local dependencies=("$@")

    for dep in "${dependencies[@]}"; do
        echo "Installing dependency '${dep}'..."

        sudo "${PACKAGE_MANAGER}" install -y "${dep}" || {
            echo "ERROR: failed to install dependency '${dep}'"
            return "$ERROR"
        }

        echo "done!"
    done

    echo
    echo "OK: all dependencies installed!"
    return "$OK"
}

function manage_dependencies() {
    local required_dependencies=("$@")

    # update the system
    sudo "${PACKAGE_MANAGER}" update || return "$ERROR"

    # get missing dependencies
    mapfile -t not_installed_dependencies < <(get_not_installed_dependencies "${required_dependencies[@]}")

    # Are there not installed dependencies?
    if [ ${#not_installed_dependencies[@]} -gt 0 ]; then
        echo "Not installed dependencies: ${not_installed_dependencies[*]}"
        install_dependencies "${not_installed_dependencies[@]}" || return "$ERROR"

    # Are all the dependencies installed?
    else
        echo "OK: dependencies are fine"
        return "$OK"
    fi
}
