#!/bin/bash
# file = tool/update-path.sh
source ~/software/scripts/tool/exit-codes.sh

# colors
readonly GREEN="\033[32m"
readonly YELLOW="\033[33m"
readonly RED="\033[31m"
readonly RESET="\033[0m"

# check if the given binary path is correct
function is_binary_path_ok() {
    local binary_path="${1}"

    # Isn't binary_path a directory?
    if [[ ! -d "${binary_path}" ]]; then
        echo -e "${RED}ERROR: ${binary_path} is not a directory${RESET}"
        return "$NO"
    fi

    # Isn't binary_path an executable directory?
    if [[ ! -x "${binary_path}" ]]; then
        echo -e "${RED}ERROR: ${binary_path} is not executable${RESET}"
        return "$NO"
    fi

    return "$YES"
}

# remove duplicate occurrences of a given path in $PATH
# old nale = remove_duplicates
function remove_duplicates_in_PATH() {
    local path_to_remove="${1}"

    if [[ -z "${path_to_remove}" ]]; then
        echo "${PATH}"
        return
    fi

    local new_path=""
    local path_entry

    IFS=':' read -r -a path_entries <<<"${PATH}"

    for path_entry in "${path_entries[@]}"; do

        if [[ "${path_entry}" == "${path_to_remove}" ]]; then

            if [[ -z "${new_path}" ]]; then
                new_path="${path_entry}"
            fi

        else
            new_path+="${new_path:+:}${path_entry}"
        fi
    done

    echo "${new_path}"
}

# update the .bashrc file with the new $PATH
function update_bashrc() {
    local new_path="${1}"

    if [ ! -w ~/.bashrc ]; then
        echo "Error: ~/.bashrc file is not writable." >&2
        return 1
    fi

    # Create a backup of ~/.bashrc
    cp -p ~/.bashrc ~/.bashrc.bak || {
        echo "Error: failed to create backup of ~/.bashrc" >&2
        return 1
    }

    # Update the PATH variable in ~/.bashrc
    if grep -q "^export PATH=" ~/.bashrc; then
        sed -i "s|^export PATH=.*|export PATH=\"${new_path}\"|" ~/.bashrc
    else
        printf "export PATH=\"%s\"\n" "${new_path}" >>~/.bashrc
    fi

    # Source .bashrc to apply changes to the current shell
    source ~/.bashrc || {
        echo "Error: failed to source ~/.bashrc" >&2
        return 1
    }
}

# Check if the given binary path exists in $PATH
function path_exists() {
    local binary_path="${1}"
    [[ ${PATH} =~ (^|:)${binary_path}(:|$) ]]
}

# Goal { update the $PATH with the given binary_path }
function update_path() {
    # Check if argument is provided
    if (($# != 1)); then
        echo "Usage: $0 <binary_path>"
        echo "Error: missing binary_path"
        echo "Warning: you must give a binary_path"
        return 1
    fi

    local binary_path="${1}"

    if ! is_binary_path_ok "${binary_path}"; then
        exit 1
    fi

    if path_exists "${binary_path}"; then

        if (($(grep -o ":${binary_path}:" <<<":${PATH}:" | wc -l) > 1)); then
            new_path=$(remove_duplicates "${binary_path}")
            update_bashrc "${new_path}" && echo -e "${GREEN}Duplicate occurrences of ${binary_path} removed from PATH.${RESET}"

        else
            echo -e "${GREEN}${binary_path} is already in PATH without duplicates.${RESET}"
        fi

    else
        read -r -p "${binary_path} is not in PATH. Do you want to add it? (yes/no): " choice
        while [[ "${choice}" != "yes" && "${choice}" != "no" ]]; do
            read -r -p "Invalid choice. Please enter 'yes' or 'no': " choice
        done

        case "${choice}" in
        yes)
            new_path="${PATH}:${binary_path}"
            update_bashrc "${new_path}" && echo -e "${GREEN}${binary_path} added to PATH.${RESET}"
            ;;
        no)
            echo -e "${YELLOW}No changes made to PATH.${RESET}"
            ;;
        esac
    fi
}
