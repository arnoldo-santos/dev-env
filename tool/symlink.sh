#!/bin/bash
# file = tool/symlink.sh
source ~/software/scripts/exit-codes.sh

# old name = reload_shell_config
function restart_shell() {
    exec zsh -l
}

# Goal {
#   Check if a path exists
# }
# Parameters {
#   1) path = some path
# }
function path_exists() {
    local path="$1"
    [[ -e "${path}" ]]
}

# Goal {
#   Check if a path is a symlink
# }
# Parameters {
#   1) path = some path
# }
function is_a_symlink() {
    local path="$1"
    [[ -L "${path}" ]]
}

# Goal {
#   Check if a symlink points to a source
# }
# Parameters {
#   1) source   = some path
#   2) symlink  = some path
# }
function symlink_is_ok() {
    local source="$1"
    local symlink="$2"
    [[ "$(readlink -f "${source}")" == "$(readlink -f "${symlink}")" ]]
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

    # check if the symlink already exists and is correct
    if is_a_symlink "${symlink}" && symlink_is_ok "${source}" "${symlink}"; then
        echo "OK: symlink '${symlink}' is fine!"
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
        echo "OK: symlink made successfully: '${symlink}'"
        return "$OK"
    }

    # handle failure
    echo "ERROR: symlink creation failed: '${symlink}'" >&2
    return "$ERROR"
}
