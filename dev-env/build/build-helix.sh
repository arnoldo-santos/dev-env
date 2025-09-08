#!/bin/bash
# file = build-helix.sh

source ~/software/scripts-dev/std-tool.sh
source ~/software/scripts-dev/tool/symlink.sh
source ~/software/scripts-dev/tool/git-repo.sh
source ~/software/scripts-dev/tool/dependency.sh

declare -A SOFTWARE=(
    [name]=helix
    [binary]=hx
)
SOFTWARE[repo_dir]="${HOME}/software/repos/${SOFTWARE[name]}"
SOFTWARE[installation_dir]="${HOME}/software/bin/${SOFTWARE[name]}"
SOFTWARE[config_dir]="${HOME}/.config/${SOFTWARE[name]}"
SOFTWARE[runtime_src]="${SOFTWARE[repo_dir]}/runtime"
SOFTWARE[runtime_lnk]="${SOFTWARE[config_dir]}/runtime"
SOFTWARE[binary_src]="${SOFTWARE[repo_dir]}/target/release/${SOFTWARE[binary]}"
SOFTWARE[binary_installed]="${SOFTWARE[installation_dir]}/${SOFTWARE[binary]}"
SOFTWARE[symlink_dir]="${HOME}/.local/bin"
SOFTWARE[symlink]="${SOFTWARE[symlink_dir]}/${SOFTWARE[binary]}"
SOFTWARE[git_repo_url]="https://github.com/${SOFTWARE[name]}-editor/${SOFTWARE[name]}.git"

# check the necessary directories for the installation
function check_dirs() {
    local repo_dir="${SOFTWARE[repo_dir]}"
    local installation_dir="${SOFTWARE[installation_dir]}"
    local symlink_dir="${SOFTWARE[symlink_dir]}"

    [[ -d "${repo_dir}" ]] || mkdir -p "${repo_dir}"
    [[ -d "${installation_dir}" ]] || mkdir -p "${installation_dir}"
    [[ -d "${symlink_dir}" ]] || mkdir -p "${symlink_dir}"
}

# check the commit history file
function check_commit_file() {
    local commit_file="${SOFTWARE[installation_dir]}/COMMIT_HISTORY"
    [[ -f "${commit_file}" ]] || touch "${commit_file}"
}

# check the binary status
function check_binary() {
    local repo_dir="${SOFTWARE[repo_dir]}"
    local commit_file="${SOFTWARE[installation_dir]}/COMMIT_HISTORY"

    if binary_is_up_to_date "${repo_dir}" "${commit_file}"; then
        echo "OK: ${SOFTWARE[name]^} is already up-to-date"
        echo "Done!"
        return "$OK"
    fi

    return "$ERROR"
}

# compile source code
function compile_src() {
    local repo_dir="${SOFTWARE[repo_dir]}"
    local software_name="${SOFTWARE[name]^}"

    echo "Compiling $software_name source code..."
    change_to_dir "${repo_dir}" || return "$ERROR"

    if cargo install --path helix-term --locked; then
        echo "done!"
        return "$OK"
    fi

    echo "ERROR: failed to compile $software_name" >&2
    return "$ERROR"
}

# store the latest commit hash in the installation directory
function update_commit_file() {
    local commit_file="${SOFTWARE[installation_dir]}/COMMIT_HISTORY"
    git rev-parse HEAD >"${commit_file}"
}

# install the binary
function install_binary() {
    # binary source
    local bin_src="${SOFTWARE[binary_src]}"
    # binary target
    local bin_trg="${SOFTWARE[binary_installed]}"

    if mv "$bin_src" "$bin_trg"; then
        return "$OK"
    fi

    echo "ERROR: failed to move binary '${bin_src}' -> '${bin_trg}'" >&2
    return "$ERROR"
}

function manage_symlink() {
    local source="$1"
    local symlink="$2"
    local use_sudo="${3:-false}"
    local options="${4:--sf}"
    make_symlink "${source}" "${symlink}" "${use_sudo}" "${options}" || return "$ERROR"
}

function build_software() {

    local prog_name="${SOFTWARE[name]^}"
    local repo_url="${SOFTWARE[git_repo_url]}"
    local repo_dir="${SOFTWARE[repo_dir]}"
    local installation_dir="${SOFTWARE[installation_dir]}"

    echo "Building ${prog_name}..."
    # checks the necessary directories for the installation
    check_dirs
    # clone the repository
    manage_repo_cloning "${prog_name}" "${repo_url}" "${repo_dir}" || return "$ERROR"
    # checks the commit history file
    check_commit_file
    # check the binary status
    check_binary && return "$OK"
    # compile source code
    compile_src || return "$ERROR"
    # store the latest commit hash in the installation directory
    update_commit_file
    # install the binary
    install_binary || return "$ERROR"

    # check symlinks
    # binary symlink
    local source="${SOFTWARE[binary_installed]}"
    local symlink="${SOFTWARE[symlink]}"
    # [[ -d "${SOFTWARE[symlink_dir]}" ]] || mkdir -p "${SOFTWARE[symlink_dir]}"
    # make_symlink "${source}" "${symlink}" || return "$ERROR"
    manage_symlink "${source}" "${symlink}" || return "$ERROR"
    # runtime symlink
    source="${SOFTWARE[runtime_src]}"
    symlink="${SOFTWARE[runtime_lnk]}"
    # make_symlink "${source}" "${symlink}" false "-Tsf" || {
    #     echo "ERROR: runtime symlink failed" >&2
    #     return "$ERROR"
    # }
    manage_symlink "${source}" "${symlink}" false "-Tsf" || return "$ERROR"

    echo "OK: ${prog_name} installed successfully!"
    echo "Done!"
    return "$OK"
}

build_software
