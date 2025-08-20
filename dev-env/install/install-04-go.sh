#!/bin/bash
# file = install-04-go.sh

source ~/software/scripts-dev/dev-env/tool/version.sh
source ~/software/scripts-dev/dev-env/tool/symlink.sh
source ~/software/scripts-dev/dev-env/tool/installation.sh
source ~/software/scripts-dev/dev-env/tool/git-repo.sh
source ~/software/scripts-dev/std-tool.sh

THIS_SCRIPT_PATH=$(realpath "${BASH_SOURCE[0]}")

function get_latest_stable_go_release() {
    local version

    version=$(curl -s "https://go.dev/dl/?mode=json" |
        jq -r '
            [.[] | select(.stable == true)][0].version
        ')

    if [[ -z "$version" ]]; then
        return "$ERROR"
    fi

    echo "${version#go}"
    return "$OK"
}

declare -A SOFTWARE=(
    [name]=Go
    [binary]=go
    [parent_dir]="${HOME}/software/pre-built-bin"
    [download_dir]="${HOME}/Downloads"
    [version_to_install]=$(get_latest_stable_go_release)
)

SOFTWARE[file_name]="go${SOFTWARE[version_to_install]}.linux-amd64.tar.gz"
SOFTWARE[download_url]="https://dl.google.com/go/${SOFTWARE[file_name]}"
SOFTWARE[installation_dir]="${SOFTWARE[parent_dir]}/${SOFTWARE[binary]}"
SOFTWARE[binary_file]="${SOFTWARE[installation_dir]}/bin/${SOFTWARE[binary]}"
SOFTWARE[installation_file]="${SOFTWARE[download_dir]}/${SOFTWARE[file_name]}"
SOFTWARE[symlink]="${HOME}/.local/bin/${SOFTWARE[binary]}"

# operations' data
declare -A OPERATION=(
    [nothing_to_do]=1
    [install]=2
    [upgrade]=3
)

function report_operation_to_do() {
    # Go is installed
    if is_installed "${SOFTWARE[binary]}"; then

        local go_installed_version
        go_installed_version=$(go version | awk '{print $3}' | sed 's/go//')
        echo "${SOFTWARE[name]} version ${go_installed_version} is already installed"

        # Go needs upgrade
        if version_is_greater "${SOFTWARE[version_to_install]}" "${go_installed_version}"; then
            echo "A newer version (${SOFTWARE[version_to_install]}) is available. Proceeding with upgrade..."
            return "${OPERATION[upgrade]}"
        fi

        # Go is up to date
        echo "The installed version is up to date or newer. No action needed"
        return "${OPERATION[nothing_to_do]}"
    fi

    # Go is not installed
    echo "${SOFTWARE[name]} is not installed. Proceeding with installation..."
    return "${OPERATION[install]}"
}

# Download Go
function download_go() {
    echo "Downloading ${SOFTWARE[name]} version ${SOFTWARE[version_to_install]}..."
    mkdir -p "${SOFTWARE[download_dir]}"

    # download failed
    if ! curl -Lo "${SOFTWARE[installation_file]}" "${SOFTWARE[download_url]}"; then
        echo "ERROR: failed to download ${SOFTWARE[name]}. Please check your internet connection and the version number" >&2
        return "$ERROR"
    fi

    # download success
    echo "OK: download successful!"
    return "$OK"
}

# Install Go
function install_go() {
    echo "Installing ${SOFTWARE[name]} version ${SOFTWARE[version_to_install]}..."

    mkdir -p "${SOFTWARE[parent_dir]}"

    # installation failed
    if ! tar -C "${SOFTWARE[parent_dir]}" -xzf "${SOFTWARE[installation_file]}"; then
        echo "ERROR: failed to install ${SOFTWARE[name]}. Please check your permissions and disk space" >&2
        return "$ERROR"
    fi

    # installation successful
    echo "OK: ${SOFTWARE[name]} version ${SOFTWARE[version_to_install]} installed successfully!"
    return "$OK"
}

# Remove any previous Go installation
function uninstall_go() {
    echo "Checking for existing ${SOFTWARE[name]} installation..."

    # installation directory exists
    if [[ -d "${SOFTWARE[installation_dir]}" ]]; then

        echo "Uninstalling previous ${SOFTWARE[name]} installation in ${SOFTWARE[installation_dir]}..."

        # Removing installation directory failed
        if ! rm -rf "${SOFTWARE[installation_dir]}"; then

            echo "ERROR: failed to remove existing ${SOFTWARE[name]} installation. Please check your permissions" >&2
            return "$ERROR"
        fi

        # installation directory removed successfully
        echo "OK: ${SOFTWARE[name]} uninstallation successful!"
        return "$OK"
    fi

    # installation directory does not exist
    echo "WARNING: can't find a ${SOFTWARE[name]} installation directory" >&2
    echo "ERROR: ${SOFTWARE[name]} uninstallation failed" >&2
    return "$ERROR"
}

function clean_up() {
    echo "Cleaning up ${SOFTWARE[name]} installation file ${SOFTWARE[installation_file]}..."

    # clean up successful
    rm -f "${SOFTWARE[installation_file]}" && {
        echo "OK: ${SOFTWARE[name]} installation file cleaned up successfully!"
        return "$OK"
    }

    # clean up failed
    echo "ERROR: ${SOFTWARE[name]} installation file clean up failed"
    return "$ERROR"
}

# Goal {
#   Install or Upgrade program depending of the given 'action' parameter
# }
# Parameters {
#   1) action   <- string { "creation" | "update" }
# }
# Returns {
#   True  -> 0
#   False -> non-zero
# }
manage_program() {
    # parameter
    local action="${1}"
    # flags
    local success=0
    local failure=1

    download_go || return "${failure}"

    install_go || return "${failure}"

    make_symlink "${action}" "${SOFTWARE[binary_file]}" "${SOFTWARE[symlink]}" || return "${failure}"

    clean_up || return "${failure}"

    return "${success}"
}

go_installed_ok() {
    go version &>/dev/null
}

# Goal {
#   Check Go installation
# }
# Parameters {
#   1) action   <- string { "installation" | "upgrade" }
# }
# Returns {
#   True  -> ^ 0
#   False -> ^ 1
# }
check_go() {
    local action="${1}"

    # source ~/.bashrc

    go_installed_ok && {
        echo "OK: ${SOFTWARE[name]} ${action} completed!"
        return "${SOFTWARE[success]}"
    }

    # handle error
    echo "ERROR: ${SOFTWARE[name]} ${action} failed" >&2
    return "${SOFTWARE[failure]}"
}

run() {
    local outcome
    report_operation_to_do
    outcome=$?

    # Go is up to date
    if [ "${outcome}" -eq "${OPERATION[nothing_to_do]}" ]; then
        return "${SOFTWARE[success]}"
    fi

    local action

    # install Go
    if [ "${outcome}" -eq "${OPERATION[install]}" ]; then
        action="creation"

        manage_program "${action}" || return "${SOFTWARE[failure]}"

        check_go "installation" && return "${SOFTWARE[success]}"
        return "${SOFTWARE[failure]}"
    fi

    # upgrade Go
    if [ "${outcome}" -eq "${OPERATION[upgrade]}" ]; then
        action="upgrade"

        uninstall_go || return "${SOFTWARE[failure]}"

        manage_program "${action}" || return "${SOFTWARE[failure]}"

        check_go "upgrade" && return "${SOFTWARE[success]}"
        return "${SOFTWARE[failure]}"
    fi

    # handle error
    echo "ERROR: invalid outcome of function 'report_operation_to_do' in function 'run' in script ${THIS_SCRIPT_PATH}" >&2
    return "${SOFTWARE[failure]}"
}

run
