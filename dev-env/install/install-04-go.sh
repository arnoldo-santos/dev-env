#!/bin/bash
# file = install-04-go.sh

source ~/software/scripts-dev/tool/version.sh
source ~/software/scripts-dev/tool/symlink.sh
source ~/software/scripts-dev/tool/installation.sh
source ~/software/scripts-dev/tool/git-repo.sh
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

function get_go_installed_version() {
    go version | awk '{print $3}' | sed 's/go//'
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
    [nothing_to_do]=0
    [install]=1
    [upgrade]=2
)

function report_what_to_do() {
    echo "Checking ${SOFTWARE[name]}..."

    # software is installed
    if is_installed "${SOFTWARE[binary]}"; then

        SOFTWARE[installed_version]=$(get_go_installed_version)

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

function download_software() {
    echo "Downloading ${SOFTWARE[name]} v${SOFTWARE[version_to_install]}..."
    mkdir -p "${SOFTWARE[download_dir]}"

    # download failed
    if ! curl -Lo "${SOFTWARE[installation_file]}" "${SOFTWARE[download_url]}"; then
        echo "ERROR: failed to download ${SOFTWARE[name]} v${SOFTWARE[version_to_install]}" >&2
        echo "WARNING: check your internet connection and the version number" >&2
        return "$ERROR"
    fi

    # download success
    echo "done!"
    return "$OK"
}

function install_software() {
    echo "Installing ${SOFTWARE[name]} v${SOFTWARE[version_to_install]}..."

    mkdir -p "${SOFTWARE[parent_dir]}"

    # installation failed
    if ! tar -C "${SOFTWARE[parent_dir]}" -xzf "${SOFTWARE[installation_file]}"; then
        echo "ERROR: failed to install ${SOFTWARE[name]} v${SOFTWARE[version_to_install]}" >&2
        echo "WARNING: check your permissions and disk space" >&2
        return "$ERROR"
    fi

    # installation successful
    make_symlink "${SOFTWARE[binary_file]}" "${SOFTWARE[symlink]}" || return "${ERROR}"
    refresh_zsh || return "$ERROR"

    echo "done!"
    return "$OK"
}

function uninstall_software() {
    echo "Uninstalling ${SOFTWARE[name]}..."

    # installation directory does not exist
    if [[ ! -d "${SOFTWARE[installation_dir]}" ]]; then
        echo "ERROR: uninstallation failed" >&2
        echo "WARNING: can't find a ${SOFTWARE[name]} installation directory" >&2
        return "$ERROR"
    fi

    # uninstallation failed
    # Always attempt both, fail if either fails
    if ! {
        rm -rf "${SOFTWARE[installation_dir]}" &
        rm -f "${SOFTWARE[symlink]}" &
        wait
    }; then
        echo "ERROR: uninstallation failed" >&2
        echo "WARNING: check your permissions" >&2
        return "$ERROR"
    fi

    # uninstallation successful
    refresh_zsh || return "$ERROR"
    echo "done!"
    return "$OK"
}

function clean_up() {
    echo "Cleaning Up..."

    # failure
    if ! rm -f "${SOFTWARE[installation_file]}"; then
        echo "ERROR: clean up failed" >&2
        return "$ERROR"
    fi

    # success
    echo "done!"
    return "$OK"
}

function manage_software_installation() {
    download_software || return "${ERROR}"
    install_software || return "${ERROR}"
    clean_up || return "${ERROR}"
    return "${OK}"
}

function go_installed_ok() {
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
function check_go() {
    local action="${1}"

    go_installed_ok && {
        echo "OK: ${SOFTWARE[name]} ${action} completed!"
        return "$OK"
    }

    # handle error
    echo "ERROR: ${SOFTWARE[name]} ${action} failed" >&2
    return "$ERROR"
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
        manage_software_installation || return "$ERROR"
        check_go "installation" || return "$ERROR"
        return "$OK"
    fi

    # upgrade software
    if ((outcome == OPERATION[upgrade])); then
        uninstall_software || return "$ERROR"
        manage_software_installation || return "$ERROR"
        check_go "upgrade" || return "$ERROR"
        return "$OK"
    fi

    # handle error
    echo "ERROR: invalid exit status of function 'report_what_to_do()' in script ${THIS_SCRIPT_PATH}" >&2
    return "$ERROR"
}

run
