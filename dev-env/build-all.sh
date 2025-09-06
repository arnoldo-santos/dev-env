#!/bin/bash
# file = build-all.sh

# import
source ~/software/scripts-dev/std-tool.sh
source ~/software/scripts-dev/tool/bash-files.sh

function build_all() {
    local scripts
    scripts=("${HOME}"/software/scripts-dev/dev-env/build/build-*.sh)

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
