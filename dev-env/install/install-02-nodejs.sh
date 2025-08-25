#!/bin/bash
# file = install-nodejs.sh

set -e
source ~/software/scripts-dev/std-tool.sh
source ~/software/scripts-dev/tool/installation.sh

function add_nodejs_family_binaries_to_zshrc() {
    local version
    version=$(node --version)

    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to retrieve Node.js version. Is Node.js/NVM properly set up?"
        return "$ERROR"
    fi

    local node_path="\${HOME}/.nvm/versions/node/${version}/bin"
    local new_path_block="# Add Node.js ${version} to PATH
export PATH=\"\${PATH}:${node_path}\""

    local zshrc="$HOME/.zshrc"

    # If an old Node.js path line exists, replace it
    if grep -q '# Add Node.js v' "$zshrc"; then
        echo "INFO: Updating existing Node.js PATH in ~/.zshrc"
        sed -i '/# Add Node.js v[0-9]\+\.[0-9]\+\.[0-9]\+ to PATH/{N;d}' "$zshrc"
    fi

    # Append the new one
    echo "$new_path_block" >>"$zshrc"
    echo "OK: Node.js ${version} path added to ~/.zshrc"
    return "$OK"
}

# main
function install_program() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

    nvm install node && reload_zsh_config && add_nodejs_family_binaries_to_zshrc
}

install_program && reload_zsh_config
