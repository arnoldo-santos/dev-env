#!/bin/bash
# file: install-pyright.sh

install_pyright() {
    echo "Installing Pyright..."

    npm install -g pyright && {
        echo "done!"
        return 0 # ok
    }

    echo "ERROR: failed to install Pyright"
    return 1 # fuck
}

install_pyright
