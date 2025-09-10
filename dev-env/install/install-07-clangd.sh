#!/bin/bash
# file = install-07-clangd.sh

# root directory
ROOT_DIR="$HOME/software/scripts"
source "${ROOT_DIR}"/tool/std.sh
source "${ROOT_DIR}"/tool/download.sh
source "${ROOT_DIR}"/tool/decompress.sh
source "${ROOT_DIR}"/tool/binary.sh
source "${ROOT_DIR}"/tool/installation.sh
source "${ROOT_DIR}"/tool/symlink.sh
source "${ROOT_DIR}"/tool/git-repo.sh

declare -A SOFTWARE=(
    [name]=Clangd
    [binary]=clangd
    [download_dir]="${HOME}/Downloads"
    [symlink_dir]="${HOME}/.local/bin"
)

SOFTWARE[latest_version]=$(get_latest_lts_github_release "clangd/clangd")
SOFTWARE[installation_dir]="${HOME}/software/pre-built-bin/${SOFTWARE[binary]}"
SOFTWARE[binary_path]="${SOFTWARE[installation_dir]}/bin/${SOFTWARE[binary]}"
SOFTWARE[symlink]="${SOFTWARE[symlink_dir]}/${SOFTWARE[binary]}"
SOFTWARE[zip_file_name]="${SOFTWARE[binary]}-linux-${SOFTWARE[latest_version]}.zip"
SOFTWARE[download_url]="https://github.com/${SOFTWARE[binary]}/${SOFTWARE[binary]}/releases/download/${SOFTWARE[latest_version]}/${SOFTWARE[zip_file_name]}"

DOWNLOAD_DIR_CREATED=0

function get_clangd_installed_version() {
    echo "$(clangd --version | grep -oP '\d+\.\d+\.\d+' | head -n1)"
}

function report_what_to_do() {
    local latest_version="${SOFTWARE[latest_version]}"

    # software is installed
    if is_installed "${SOFTWARE[binary]}"; then
        local installed_version
        installed_version=$(get_clangd_installed_version)

        # software is up to date
        if [[ "$installed_version" == "$latest_version" ]]; then
            echo "OK: ${SOFTWARE[name]} v${installed_version} is up to date!"
            return "${OPERATION[nothing_to_do]}"
        fi

        # software needs upgrade
        echo "New version found: $latest_version"
        echo "Upgrading ${SOFTWARE[name]}..."
        return "${OPERATION[upgrade]}"
    fi

    # software is not installed
    echo "Installing ${SOFTWARE[name]}..."
    return "${OPERATION[install]}"
}

function download_software() {
    local zip_file_name="${SOFTWARE[zip_file_name]}"
    local download_dir="${SOFTWARE[download_dir]}"
    local download_url="${SOFTWARE[download_url]}"

    if [[ ! -d "${download_dir}" ]]; then
        echo "New download directory created: $download_dir"
        mkdir -p "${download_dir}"
        DOWNLOAD_DIR_CREATED=1
    fi

    manage_download "${zip_file_name}" "${download_dir}" "${download_url}"
}

function remove_old_software_version() {
    local installation_dir="${SOFTWARE[installation_dir]}"

    # installation dir doesn't exists
    if [[ ! -d "${installation_dir}" ]]; then
        echo "ERROR: can't find $installation_dir" >&2
        return "$ERROR"
    fi

    # clean previous installation files
    echo "Cleaning up ${installation_dir}..."
    rm -rf "${installation_dir:?}/"* || {
        echo "ERROR: failed to clean up ${installation_dir}" >&2
        return "$ERROR"
    }

    echo "done!"
    return "$OK"
}

function decompress_software() {
    local zip_file_name="${SOFTWARE[zip_file_name]}"
    local download_dir="${SOFTWARE[download_dir]}"
    local zip_file_path="${download_dir}/${zip_file_name}"
    local installation_dir="${SOFTWARE[installation_dir]}"

    if [[ ! -d "${installation_dir}" ]]; then
        mkdir -p "${installation_dir}"
        echo "New installation directory created: $installation_dir"
    fi

    manage_zip_decompression "${zip_file_name}" "${zip_file_path}" "${installation_dir}" || return "$ERROR"

    echo "Cleaning up ${zip_file_path}..."
    rm -f "${zip_file_path}" || {
        echo "ERROR: failed to clean up ${zip_file_path}" >&2
        return "$ERROR"
    }

    echo "done!"
    return "$OK"
}

function check_software_binary() {
    manage_binary_validation "${SOFTWARE[name]}" "${SOFTWARE[binary_path]}"
}

function make_software_symlink() {
    local symlink="${SOFTWARE[symlink]}"
    local symlink_dir="${SOFTWARE[symlink_dir]}"
    local source="${SOFTWARE[binary_path]}"

    if [[ ! -d "$symlink_dir" ]]; then
        mkdir -p "$symlink_dir"
        echo "New symlink directory created: $symlink_dir"
    fi

    make_symlink "${source}" "${symlink}"
}

# delete the download dir only if it was created by this script
function remove_new_download_dir() {
    local download_dir="${SOFTWARE[download_dir]}"

    if ((DOWNLOAD_DIR_CREATED)); then
        echo "Deleting download directory: ${download_dir}..."

        rm -rf "${download_dir:?}" || {
            echo "ERROR: failed to delete download directory \"${download_dir}\"" >&2
            return "$ERROR"
        }
    fi

    return "$OK"
}

function install_software() {
    download_software &&
        decompress_software &&
        check_software_binary &&
        make_software_symlink &&
        remove_new_download_dir || return "$ERROR"
    return "$OK"
}

# param: action = installation | upgrade
function manage_software() {
    local action="$1"

    if install_software; then
        echo "OK: ${SOFTWARE[name]} $action successfull!"
        return "$OK"
    fi

    echo "ERROR: ${SOFTWARE[name]} $action failed" >&2
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
        manage_software "installation" || return "$ERROR"
        return "$OK"
    fi

    # upgrade software
    if ((outcome == OPERATION[upgrade])); then
        remove_old_software_version || return "$ERROR"
        manage_software "upgrade" || return "$ERROR"
        return "$OK"
    fi

    # handle error
    echo "ERROR: invalid exit status" >&2
    return "$ERROR"
}

run
