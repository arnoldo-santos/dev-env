#!/bin/bash
# file = build-pyenv.sh
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
SOFTWARE[commit_file]="${SOFTWARE[installation_dir]}/COMMIT_HISTORY"

# check the necessary directories for the installation
function check_dirs() {
	local repo_dir="${SOFTWARE[repo_dir]}"
	local installation_dir="${SOFTWARE[installation_dir]}"

	[[ -d "${repo_dir}" ]] || mkdir -p "${repo_dir}"
	[[ -d "${installation_dir}" ]] || mkdir -p "${installation_dir}"
}

# check the commit history file
function check_commit_file() {
	local commit_file="${SOFTWARE[commit_file]}"
	[[ -f "${commit_file}" ]] || touch "${commit_file}"
}

# check the binary status: up-to-date OR not
function check_binary() {
	local repo_dir="${SOFTWARE[repo_dir]}"
	local commit_file="${SOFTWARE[commit_file]}"

	if binary_is_up_to_date "${repo_dir}" "${commit_file}"; then
		echo "OK: ${SOFTWARE[name]} is already up-to-date"
		return "$OK"
	fi
	echo "WARNING: ${SOFTWARE[name]} needs update"
	return "$OK"

}

# compile a dynamic Bash extension to speed up PyEnv
function compile_dyn_bash_ext() {
	local repo_dir="${SOFTWARE[repo_dir]}"

	cd "$repo_dir" && src/configure && make -C src
	cd - &>/dev/null
}

# store the latest commit hash at the installation directory in the commit file
function update_commit_file() {
	local repo_dir="${SOFTWARE[repo_dir]}"
	local commit_file="${SOFTWARE[commit_file]}"

	cd "$repo_dir"
	git rev-parse HEAD >"${commit_file}"
	cd - &>/dev/null
}

# set up shell environment for PyEnv
# function setup_zsh() {
# 	local repo_dir="${SOFTWARE[repo_dir]}"

# 	# check if PyEnv configuration already exists
# 	if ! grep -q "export PYENV_ROOT=\"$repo_dir\"" ~/.zshrc; then
# 		echo -e '\n# PyEnv' >>~/.zshrc
# 		echo "export PYENV_ROOT=\"$repo_dir\"" >>~/.zshrc
# 		echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >>~/.zshrc
# 		echo 'eval "$(pyenv init - zsh)"' >>~/.zshrc
# 	fi
# }
function setup_zsh() {
	local repo_dir="${SOFTWARE[repo_dir]}"
	local repo_dir_generic="${repo_dir/#$HOME/\$HOME}"

	# Check if pyenv configuration already exists
	if ! grep -q "export PYENV_ROOT=\"$repo_dir_generic\"" ~/.zshrc; then
		echo -e '\n# PyEnv' >>~/.zshrc
		echo "export PYENV_ROOT=\"$repo_dir_generic\"" >>~/.zshrc
		echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >>~/.zshrc
		echo 'eval "$(pyenv init - zsh)"' >>~/.zshrc
	fi
}

function build_software() {
	local software_name="${SOFTWARE[name]}"
	local repo_url="${SOFTWARE[repo_url]}"
	local repo_dir="${SOFTWARE[repo_dir]}"
	local installation_dir="${SOFTWARE[installation_dir]}"

	echo "Building ${software_name}..."
	# checks the necessary directories for the installation
	check_dirs
	# clone the repository
	manage_repo_cloning "${software_name}" "${repo_url}" "${repo_dir}" || return "$ERROR"
	# compile a dynamic bash extension
	compile_dyn_bash_ext
	# checks the commit history file
	check_commit_file
	# store the latest commit hash in the installation directory
	update_commit_file
	# check the binary status
	check_binary
	# check zsh config for PyEnv
	setup_zsh
	# reload zsh config
	refresh_zsh

	echo "OK: ${software_name} installed successfully!"
	echo "Done!"
	return "$OK"
}

build_software
