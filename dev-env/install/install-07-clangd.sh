#!/bin/bash
# file = install-07-clangd.sh

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

function report_what_to_do() {
    local binary="${SOFTWARE[binary]}"
    local prog_name="${SOFTWARE[binary]^}"
    local latest_version="${SOFTWARE[latest_version]}"

    if is_installed "${binary}"; then
        local current_version
        current_version=$("${binary}" --version | grep -oP '\d+\.\d+\.\d+' | head -n1)

        if [[ "$current_version" == "$latest_version" ]]; then
            echo "OK: ${prog_name} v${current_version} is up to date"
            echo "Nothing to do"
            return 0
        else
            echo "${prog_name} is outdated"
            echo "Installed version: $current_version"
            echo "Available version: $latest_version"
            echo "Proceeding with upgrade..."
            echo "Upgrading ${prog_name} version $latest_version..."
            return 1 # fuck
        fi
    fi

    echo "$prog_name isn't installed"
    echo "Proceeding with install..."
    echo "Installing ${prog_name} version $latest_version..."
    return 2 # fuck
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

    # nothing to remove
    if [[ ! -d "${installation_dir}" ]]; then
        mkdir -p "${installation_dir}"
        echo "New installation directory created: $installation_dir"
        return 0 # ok
    fi

    # clean previous installation files
    echo "Cleaning previous installation files in $installation_dir"
    rm -rf "${installation_dir:?}/"* || {
        echo "ERROR: failed to clean installation directory ${installation_dir}" >&2
        return 1 # fuck
    }

    return 0 # ok
}

function decompress_software() {
    local zip_file_name="${SOFTWARE[zip_file_name]}"
    local download_dir="${SOFTWARE[download_dir]}"
    local zip_file_path="${download_dir}/${zip_file_name}"
    local installation_dir="${SOFTWARE[installation_dir]}"

    manage_zip_decompression "${zip_file_name}" "${zip_file_path}" "${installation_dir}" || return 1 # fuck # fuck

    echo "Deleting file $zip_file_path"
    rm -f "${zip_file_path}" || {
        echo "ERROR: failed to remove ${zip_file_path}" >&2
        return 1 # fuck
    }

    return 0 # ok
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

    echo "Making ${software_name}'s symlink..."
    make_symlink "${source}" "${symlink}"
}

# delete the download dir only if it was created by this script
function remove_software_download_dir() {
    local download_dir="${SOFTWARE[download_dir]}"

    if ((DOWNLOAD_DIR_CREATED)); then
        echo "Deleting download directory: ${download_dir}..."

        rm -rf "${download_dir:?}" || {
            echo "ERROR: failed to delete download directory \"${download_dir}\"" >&2
            return 1 # fuck
        }
    fi

    return 0 # ok
}

function install_software() {
    local software_name="${SOFTWARE[binary]^}"
    local latest_version="${SOFTWARE[latest_version]}"

    report_what_to_do && return 0            # ok
    remove_old_software_version || return 1  # fuck
    download_software || return 1            # fuck
    decompress_software || return 1          # fuck
    check_software_binary || return 1        # fuck
    make_software_symlink || return 1        # fuck
    remove_software_download_dir || return 1 # fuck

    echo "OK: $software_name version $latest_version installed successfully!"
    return 0 # ok
}

install_software
