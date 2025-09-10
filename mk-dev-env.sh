#!/bin/bash
# file = mk-dev-env.sh

# set strict mode
set -euo pipefail
# root directory
ROOT_DIR="$HOME/software/scripts"
# import
source "${ROOT_DIR}"/tool/std.sh

function make_dev_env() {

    # install essential software
    bash "$ROOT_DIR"/dev-env/install-all.sh || return "$ERROR"

    # build software
    bash "$ROOT_DIR"/dev-env/build-all.sh || return "$ERROR"

    echo "OK: Development Environment successfull!"
    return "$OK"
}

make_dev_env
