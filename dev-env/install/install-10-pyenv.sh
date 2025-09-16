#!/bin/bash
# file = install-pyenv.sh
# root directory
ROOT_DIR="$HOME/software/scripts"
# imports
source "${ROOT_DIR}"/tool/std.sh
source "${ROOT_DIR}"/tool/symlink.sh
source "${ROOT_DIR}"/tool/git-repo.sh
source "${ROOT_DIR}"/tool/dependency.sh

declare -A SOFTWARE=(
	[name]=PyEnv
	[binary]=pyenv
)
SOFTWARE[repo_dir]="${HOME}/software/repos/${SOFTWARE[binary]}"
SOFTWARE[repo_url]="https://github.com/${SOFTWARE[binary]}/${SOFTWARE[binary]}.git"
SOFTWARE[installation_dir]="${HOME}/software/bin/${SOFTWARE[binary]}"
SOFTWARE[symlink_dir]="${HOME}/.local/bin"
SOFTWARE[symlink]="${SOFTWARE[symlink_dir]}/${SOFTWARE[binary]}"

# check the necessary directories for the installation
function check_dirs() {
	local repo_dir="${SOFTWARE[repo_dir]}"
	local installation_dir="${SOFTWARE[installation_dir]}"
	local symlink_dir="${SOFTWARE[symlink_dir]}"

	[[ -d "${repo_dir}" ]] || mkdir -p "${repo_dir}"
	[[ -d "${installation_dir}" ]] || mkdir -p "${installation_dir}"
	[[ -d "${symlink_dir}" ]] || mkdir -p "${symlink_dir}"
}
