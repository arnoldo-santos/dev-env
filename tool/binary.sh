#!/bin/bash
# file = tool/binary.sh
source ~/software/scripts-dev/exit-codes.sh

function binary_is_fine() {
    local binary_file="$1"

    [[ -f "${binary_file}" ]] || {
        echo "ERROR: binary does not exist" >&2
        return "$NO"
    }

    [[ -x "${binary_file}" ]] || {
        echo "ERROR: binary not excecutable" >&2
        return "$NO"
    }

    return "$YES"
}

function manage_binary_validation() {
    local software_name="$1"
    local binary_path="$2"

    binary_is_fine "${binary_path}" && {
        printf "OK: %s\n" "$software_name binary file created successfully!"
        return "$OK"
    }

    echo "ERROR: $software_name binary file creation failed" >&2
    return "$ERROR"
}
