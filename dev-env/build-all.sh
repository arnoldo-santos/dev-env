#!/bin/bash
# file: build-all.sh

# Set strict mode
set -euo pipefail

# import
source ~/software/scripts/exit-codes.sh
source ~/software/scripts/tool/bash-files.sh

function build_all() {
    local scripts
    scripts=("${HOME}"/software/scripts/dev-env/build/build-*.sh)

    echo "Building software..."

    if run_scripts "${scripts[@]}"; then
        echo "OK: all software built successfully!"
        return "$OK"
    else
        echo "ERROR: failed to build software" >&2
        return "$ERROR"
    fi
}

build_all
