#!/bin/bash
# file = mk-dev-env.sh

# set strict mode
set -euo pipefail
# import
source ~/software/scripts-dev/std-tool.sh

function make_dev_env() {
    local dir="scripts-dev"

    # install essential software
    bash ~/software/"$dir"/dev-env/install-all.sh || return "$ERROR"

    # build software
    # bash ~/software/"$dir"/dev-env/build-all.sh || return "$ERROR"

    echo "OK: Development Environment created successfully!"
    return "$OK"
}

make_dev_env
