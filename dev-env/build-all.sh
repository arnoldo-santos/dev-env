#!/bin/bash
# file = build-all.sh

# root directory
ROOT_DIR="$HOME/software/scripts"
# import
source "${ROOT_DIR}"/tool/std.sh
source "${ROOT_DIR}"/tool/bash-files.sh

function build_all() {
    local scripts
    scripts=("${ROOT_DIR}"/dev-env/build/build-*.sh)

    echo "Building software..."

    if run_scripts "${scripts[@]}"; then
        echo "OK: all software built successfully!"
        return "$OK"
    else
        echo "ERROR: software build failed" >&2
        return "$ERROR"
    fi
}

build_all
