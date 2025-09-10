#!/bin/bash
# file = tool/symlink.sh

# root directory
ROOT_DIR="$HOME/software/scripts"
source "${ROOT_DIR}"/tool/std.sh

# Check if a path exists (file, directory, symlink, etc.)
function path_exists() {
    local path="$1"
    [[ -e "${path}" || -L "${path}" ]]
}

# Get the absolute canonical path by resolving all symlinks
function get_canonical_path() {
    local path="$1"
    readlink -f "${path}"
}

# Check if a path is a symbolic link
function is_symbolic_link() {
    local path="$1"
    path_exists "${path}" && [[ -L "${path}" ]]
}

# Check if two paths resolve to the same target
function paths_resolve_to_same_target() {
    local path1="$1"
    local path2="$2"

    # Both paths must exist
    path_exists "${path1}" && path_exists "${path2}" &&
        [[ "$(get_canonical_path "${path1}")" == "$(get_canonical_path "${path2}")" ]]
}

# Goal {
#   Make a symlink dynamically
# }
# Parameters {
#   1) source   = string { PROGRAM[binary_file] }
#   2) symlink  = string { PROGRAM[symlink] }
#   3) use_sudo = boolean (optional, default=false)
#   4) options  = string (optional, default="-sf")
# }
function make_symlink() {
    local source="${1}"
    local symlink="${2}"
    local use_sudo="${3:-false}" # default to false if not provided
    local options="${4:--sf}"    # default to "-sf" if not provided
    local cmd

    echo "Checking symlink ${symlink} -> ${source}..."

    # check if the symlink already exists and is correct
    if is_symbolic_link "${symlink}" && paths_resolve_to_same_target "${source}" "${symlink}"; then
        echo "OK: symlink is fine!"
        return "$OK"
    fi

    # build the command
    cmd="ln ${options} \"${source}\" \"${symlink}\""

    if [ "${use_sudo}" = true ]; then
        cmd="sudo ${cmd}"
    elif [ "${use_sudo}" != false ]; then
        echo "ERROR: invalid value for parameter 'use_sudo' in function 'tool/symlink.make_symlink()' (it must be 'true' or 'false')" >&2
        return "$ERROR"
    fi

    # execute the command
    eval "${cmd}" && {
        echo "OK: symlink made successfully: ${symlink} -> ${source}"
        refresh_zsh || return "$ERROR"
        return "$OK"
    }

    # handle failure
    echo "ERROR: symlink creation failed: ${symlink} -> ${source}" >&2
    return "$ERROR"
}
