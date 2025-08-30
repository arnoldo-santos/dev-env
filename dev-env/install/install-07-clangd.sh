#!/bin/bash
# file = install-07-clangd.sh

source ~/software/scripts-dev/std-tool.sh
source ~/software/scripts-dev/tool/download.sh
source ~/software/scripts-dev/tool/decompress.sh
source ~/software/scripts-dev/tool/binary.sh
source ~/software/scripts-dev/tool/installation.sh
source ~/software/scripts-dev/tool/symlink.sh
source ~/software/scripts-dev/tool/git-repo.sh

declare -A SOFTWARE=(
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
    local binary="${SOFTWARE[binary]}"
    local software_name="${SOFTWARE[binary]^}"
    local latest_version="${SOFTWARE[latest_version]}"

    # software is installed
    if is_installed "${binary}"; then
        local installed_version
        installed_version=$(get_clangd_installed_version)

        # software is up to date
        if [[ "$installed_version" == "$latest_version" ]]; then
            echo "OK: ${software_name} v${installed_version} is up to date!"
            return "${OPERATION[nothing_to_do]}"
        fi

        # software needs upgrade
        echo "New version found: $latest_version"
        echo "Upgrading $software_name..."
        return "${OPERATION[upgrade]}"
    fi

    # software is not installed
    echo "Installing $software_name..."
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
    local software_name="${SOFTWARE[binary]^}"
    local binary_path="${SOFTWARE[binary_path]}"
    manage_binary_validation "${software_name}" "${binary_path}"
}

function make_software_symlink() {
    local software_name="${SOFTWARE[binary]^}"
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

function old_install_software() {
    local software_name="${SOFTWARE[binary]^}"
    local latest_version="${SOFTWARE[latest_version]}"

    report_what_to_do && return 0           # ok
    remove_old_software_version || return 1 # fuck
    download_software || return 1           # fuck
    decompress_software || return 1         # fuck
    check_software_binary || return 1       # fuck
    make_software_symlink || return 1       # fuck
    remove_new_download_dir || return 1     # fuck

    echo "OK: $software_name version $latest_version installed successfully!"
    return 0 # ok
}

function install_software() {
    download_software || return "$ERROR"
    decompress_software || return "$ERROR"
    check_software_binary || return "$ERROR"
    make_software_symlink || return "$ERROR"
    remove_new_download_dir || return "$ERROR"
    return "$OK"
}

function upgrade_software() {
    remove_old_software_version || return "$ERROR"
    download_software || return "$ERROR"
    decompress_software || return "$ERROR"
    check_software_binary || return "$ERROR"
    make_software_symlink || return "$ERROR"
    remove_new_download_dir || return "$ERROR"
    return "$OK"
}
