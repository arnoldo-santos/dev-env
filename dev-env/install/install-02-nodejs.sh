#!/bin/bash
# file = install-02-nodejs.sh

# root directory
ROOT_DIR="$HOME/software/scripts"
source "${ROOT_DIR}"/tool/std.sh
source "${ROOT_DIR}"/tool/installation.sh
source "${ROOT_DIR}"/tool/git-repo.sh

declare -A SOFTWARE=(
    [name]="Node.js"
    [binary]=node
)
SOFTWARE[latest_version]=$(get_latest_lts_github_release "nodejs/node")

function report_what_to_do() {
    local latest_version="${SOFTWARE[latest_version]}"

    # software is installed
    if is_installed "${SOFTWARE[binary]}"; then
        local installed_version
        installed_version=$(node --version)
        # remove the `v`
        installed_version=${installed_version#v}

        # software is up to date
        if [[ "$installed_version" == "$latest_version" ]]; then
            echo "OK: ${SOFTWARE[name]} v${installed_version} is up to date!"
            return "${OPERATION[nothing_to_do]}"
        fi

        # software needs upgrade
        echo "New version found: $latest_version"
        echo "Upgrading ${SOFTWARE[name]}..."
        return "${OPERATION[upgrade]}"
    fi

    # software is not installed
    echo "Installing ${SOFTWARE[name]}..."
    return "${OPERATION[install]}"
}

function add_nodejs_bin_to_zshrc() {
    local version
    version=$(node --version)

    if [[ $? -ne 0 ]]; then
        echo "ERROR: failed to retrieve Node.js version. Is Node.js/NVM properly set up?"
        return "$ERROR"
    fi

    local node_path="\${HOME}/.nvm/versions/node/${version}/bin"
    local new_path_block="# Node.js ${version}
export PATH=\"\${PATH}:${node_path}\""

    local zshrc="$HOME/.zshrc"

    # If an old Node.js path line exists, replace it
    if grep -q '# Node.js v' "$zshrc"; then
        echo "INFO: Updating existing Node.js PATH in ~/.zshrc"
        sed -i '/# Node.js v[0-9]\+\.[0-9]\+\.[0-9]\+/{N;d}' "$zshrc"
    fi

    # Append the new one
    echo "$new_path_block" >>"$zshrc"
    echo "OK: ${SOFTWARE[name]} ${version} path added to ~/.zshrc"
    return "$OK"
}

function install_software() {
    # setup Node Version Manager
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

    # install software
    if nvm install "${SOFTWARE[binary]}"; then
        add_nodejs_bin_to_zshrc || return "$ERROR"
        reload_zsh_config || return "$ERROR"
        echo "OK: ${SOFTWARE[name]} success!"
        return "$OK"
    else
        echo "ERROR: ${SOFTWARE[name]} failed"
        return "$ERROR"
    fi
}

# param: action = installation | upgrade
function manage_software() {
    local action="$1"

    if install_software; then
        print_success "${SOFTWARE[name]} $action successfull!"
        return "$OK"
    fi

    print_error "${SOFTWARE[name]} $action failed" >&2
    return "$ERROR"
}

function run() {
    local outcome
    report_what_to_do
    outcome=$?

    # software is up to date
    if ((outcome == OPERATION[nothing_to_do])); then
        echo "Nothing to do"
        return "$OK"
    fi

    # install software
    if ((outcome == OPERATION[install])); then
        manage_software "installation" || return "$ERROR"
        return "$OK"
    fi

    # upgrade software
    if ((outcome == OPERATION[upgrade])); then
        manage_software "upgrade" || return "$ERROR"
        return "$OK"
    fi

    # handle error
    print_error "invalid exit status"
    return "$ERROR"
}

run
