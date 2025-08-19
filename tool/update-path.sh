#!/bin/bash
# file = tool/update-path.sh
source ~/software/scripts/exit-codes.sh
source ~/software/scripts/tool/symlink.sh

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

function update_PATH_in_zshrc() {
    local new_path="${1}"

    if [[ ! -w ~/.zshrc ]]; then
        echo "ERROR: ~/.zshrc file is not writable." >&2
        return "$ERROR"
    fi

    # create a backup of ~/.zshrc
    cp -p ~/.zshrc ~/.zshrc.bak || {
        echo "ERROR: failed to create backup of ~/.zshrc" >&2
        return "$ERROR"
    }

    # check if the comment exists
    if grep -q "# duplicates in PATH removed" ~/.zshrc; then
        # comment exists, update the export line that follows it
        sed -i '/# duplicates in PATH removed/{n;s/^export PATH=.*/export PATH="'"${new_path}"'"/;}' ~/.zshrc || {
            echo "ERROR: failed to update ~/.zshrc" >&2
            return "$ERROR"
        }
    else
        # comment doesn't exist, append the entire block
        {
            echo ""
            echo "# duplicates in PATH removed"
            echo "export PATH=\"${new_path}\""
        } >>~/.zshrc || {
            echo "ERROR: failed to write to ~/.zshrc" >&2
            return "$ERROR"
        }
    fi

    return "$OK"
}

# check if the given binary path exists in $PATH
function is_in_PATH() {
    local binary_path="${1}"

    if [[ -z "$binary_path" ]]; then
        echo "ERROR: No path provided" >&2
        return 1
    fi

    [[ ${PATH} =~ (^|:)${binary_path}(:|$) ]]
}

function has_duplicate_in_PATH() {
    local target_path="${1}"

    # Check if target_path is provided
    if [[ -z "$target_path" ]]; then
        echo "ERROR: No path provided" >&2
        return 1
    fi

    # Count occurrences of the path in PATH
    local count
    count=$(grep -o ":${target_path}:" <<<":${PATH}:" | wc -l)

    # Return 0 (true) if count > 1, otherwise return 1 (false)
    if ((count > 1)); then
        return "$YES" # Has duplicates
    else
        return "$NO" # No duplicates
    fi
}

function prompt_add_to_PATH() {
    local binary_path="${1}"

    if [[ -z "$binary_path" ]]; then
        echo "ERROR: No path provided" >&2
        return 1
    fi

    read -r -p "${binary_path} is not in PATH. Do you want to add it? (yes/no): " choice

    # Convert to lowercase and accept various forms
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    while [[ ! "$choice" =~ ^(y|yes|n|no)$ ]]; do
        read -r -p "Invalid choice. Please enter 'yes' or 'no': " choice
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
    done

    case "${choice}" in
    y | yes)
        local new_path="${PATH}:${binary_path}"

        if update_PATH_in_zshrc "${new_path}"; then
            echo -e "${GREEN}OK: ${binary_path} added to PATH${RESET}"
            return "$OK"
        else
            echo -e "${RED}ERROR: Failed to add ${binary_path} to PATH${RESET}"
            return "$ERROR"
        fi
        ;;
    n | no)
        echo -e "${YELLOW}No changes made to PATH${RESET}"
        return "$OK"
        ;;
    esac
}

# Goal { update the $PATH with the given binary_path }
function update_PATH() {
    # check if argument is provided
    if (($# != 1)); then
        echo "Usage: $0 <binary_path>"
        echo "Error: missing binary_path"
        echo "Warning: you must give a binary_path"
        return "$ERROR"
    fi

    local binary_path="${1}"
    is_binary_path_ok "${binary_path}" || return "$ERROR"

    if is_in_PATH "${binary_path}"; then

        # if (($(grep -o ":${binary_path}:" <<<":${PATH}:" | wc -l) > 1)); then
        if has_duplicate_in_PATH "${binary_path}"; then
            new_path=$(remove_duplicates_in_PATH "${binary_path}")

            if update_PATH_in_zshrc "${new_path}"; then
                echo -e "${GREEN}Duplicate occurrences of ${binary_path} removed from PATH.${RESET}"
                return "$OK"
            else
                echo -e "${RED}ERROR: Failed to add ${new_path} to PATH${RESET}"
                return "$ERROR"
            fi

        else
            echo -e "${GREEN}${binary_path} is already in PATH without duplicates.${RESET}"
            return "$OK"
        fi

    else
        prompt_add_to_PATH "$binary_path"
    fi
}
