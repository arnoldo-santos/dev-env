#!/bin/bash
# file = tool/git-repo.sh
source ~/software/scripts/tool/exit-codes.sh
source ~/software/scripts/tool/directory.sh

function is_valid_git_url() {
    local url="$1"

    # try fetching references quietly
    if git ls-remote --exit-code --heads "$url" &>/dev/null; then
        return "$YES"
    else
        return "$NO" # invalid or unreachable
    fi
}

function check_git_url() {
    local url="$1"

    is_valid_git_url "$url" || {
        echo "ERROR: invalid git url '$repo_url'" >&2
        return "$ERROR"
    }
    return "$OK"
}

function clone_repo() {
    local software_name="$1"
    local repo_url="$2"
    local repo_dir="$3"

    check_git_url "$repo_url" || return "$ERROR"

    echo "Cloning ${software_name} repository..."

    git clone "${repo_url}" "${repo_dir}" && {
        echo "done!"
        return "$OK"
    }

    echo "ERROR: failed to clone ${software_name} repository" >&2
    return "$ERROR"
}

function pull_repo() {
    local software_name="$1"
    local repo_dir="$2"

    echo "Pulling ${software_name} repository in ${repo_dir}..."
    change_to_repo_dir "$repo_dir" || return "$ERROR"

    if git pull; then
        echo "done!"
        restore_current_dir || return "$ERROR"
        return "$OK"
    else
        echo "ERROR: failed to pull the repository" >&2
        restore_current_dir
        return "$ERROR"
    fi
}

function manage_repo_cloning() {
    local software_name="$1"
    local repo_url="$2"
    local repo_dir="$3"

    check_git_url "$repo_url" || return "$ERROR"

    # installation_dir doesn't exists
    if ! is_dir "${repo_dir}"; then
        mkdir -p "${repo_dir}"

        clone_repo "${software_name}" "${repo_url}" "${repo_dir}" && return "$OK"
        return "$ERROR"
    fi

    # installation_dir is empty
    if dir_is_empty "${repo_dir}"; then
        clone_repo "${software_name}" "${repo_url}" "${repo_dir}" && return "$OK"
        return "$ERROR"
    fi

    # installation_dir is a git repo
    if dir_is_a_git_repo "${repo_dir}"; then
        echo "${software_name} repository already exists"
        pull_repo "$software_name" "$repo_dir" || return "$ERROR"
        return "$OK"
    fi

    # installation_dir isn't a git repo
    recreate_repo_dir "$repo_dir" || return "$ERROR"

    clone_repo "${software_name}" "${repo_url}" "${repo_dir}" && return "$OK"
    return "$ERROR"
}

# Usage: function <repo>
# Parameter: repo ~> "Kitware/CMake" or "clangd/clangd"
function get_latest_lts_github_release() {
    local repo="$1"
    curl -s "https://api.github.com/repos/${repo}/releases" |
        jq -r '
            .[] |
            select(.prerelease == false and .draft == false) |
            .tag_name |
            select(test("^v?[0-9]+\\.[0-9]+\\.[0-9]+$")) |
            sub("^v"; "")
        ' |
        sort -V |
        tail -n1
}

function binary_is_up_to_date() {
    local source_dir="$1"
    local commit_file="$2"

    local installed_commit
    local latest_commit

    if [[ -f "$commit_file" ]]; then
        installed_commit=$(<"$commit_file")
    else
        return "$NO" # commit file does not exist, so consider it not up-to-date
    fi

    latest_commit="$(cd "$source_dir" && git rev-parse HEAD)"

    [[ "$installed_commit" == "$latest_commit" ]]
}
