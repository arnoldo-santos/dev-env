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

function build_software() {
    echo "Building ${SOFTWARE[name]^}..."

    local prog_name="${SOFTWARE[name]^}"
    local repo_url="${SOFTWARE[git_repo_url]}"
    local repo_dir="${SOFTWARE[repo_dir]}"
    local installation_dir="${SOFTWARE[installation_dir]}"

    [[ -d "${repo_dir}" ]] || mkdir -p "${repo_dir}"
    [[ -d "${installation_dir}" ]] || mkdir -p "${installation_dir}"

    # clone the repo
    manage_repo_cloning "${prog_name}" "${repo_url}" "${repo_dir}" || return "$ERROR"

    # create the commit history file
    local commit_file="${installation_dir}/COMMIT_HISTORY"
    [[ -f "${commit_file}" ]] || touch "${commit_file}"

    # check binary status
    binary_is_up_to_date "${repo_dir}" "${commit_file}" && {
        echo "OK: ${SOFTWARE[name]^} is already up-to-date"
        echo "Done!"
        return "$OK"
    }

    # compile from source
    echo "Compiling from source..."
    change_to_dir "${repo_dir}" || return "$ERROR"
    cargo install --path helix-term --locked || {
        echo "ERROR: failed to compile ${SOFTWARE[name]^}" >&2
        return "$ERROR"
    }
    echo "done!"

    # Store the latest commit hash in the installation directory
    git rev-parse HEAD >"${commit_file}"

    # install the binary
    mv "${SOFTWARE[binary_src]}" "${SOFTWARE[binary_installed]}" || {
        echo "ERROR: failed to move the binary from '${SOFTWARE[binary_src]}' to '${SOFTWARE[binary_installed]}'" >&2
        return "$ERROR"
    }

    # check symlinks
    # binary symlink
    local source="${SOFTWARE[binary_installed]}"
    local symlink="${SOFTWARE[symlink]}"
    [[ -d "${SOFTWARE[symlink_dir]}" ]] || mkdir -p "${SOFTWARE[symlink_dir]}"
    make_symlink "${source}" "${symlink}" || return "$ERROR"
    # runtime symlink
    source="${SOFTWARE[runtime_src]}"
    symlink="${SOFTWARE[runtime_lnk]}"
    make_symlink "${source}" "${symlink}" false "-Tsf" || {
        echo "ERROR: runtime symlink failed" >&2
        return "$ERROR"
    }

    echo "OK: ${prog_name} installed successfully!"
    echo "Done!"
    return "$OK"
}

build_software
