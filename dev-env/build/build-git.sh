#!/bin/bash
# file = build-git.sh

# root directory
ROOT_DIR="$HOME/software/scripts"
source "${ROOT_DIR}"/tool/std.sh
source "${ROOT_DIR}"/tool/symlink.sh
source "${ROOT_DIR}"/tool/git-repo.sh
source "${ROOT_DIR}"/tool/dependency.sh

declare -A SOFTWARE=(
	[name]=Git
	[bin]=git
)

SOFTWARE[repo_url]="https://github.com/git/git.git"
SOFTWARE[repo_dir]="${HOME}/software/repos/${SOFTWARE[bin]}"
SOFTWARE[installation_dir]="${HOME}/software/bin/${SOFTWARE[bin]}"
SOFTWARE[installed_bin]="${SOFTWARE[installation_dir]}/bin/${SOFTWARE[bin]}"
SOFTWARE[symlink_dir]="${HOME}/.local/bin"
SOFTWARE[symlink]="${SOFTWARE[symlink_dir]}/${SOFTWARE[bin]}"
SOFTWARE[commit_file]="${SOFTWARE[installation_dir]}/COMMIT_HISTORY"

# check the necessary directories for the installation
function check_dirs() {
	local repo_dir="${SOFTWARE[repo_dir]}"
	local installation_dir="${SOFTWARE[installation_dir]}"
	local symlink_dir="${SOFTWARE[symlink_dir]}"

	[[ -d "${repo_dir}" ]] || mkdir -p "${repo_dir}"
	[[ -d "${installation_dir}" ]] || mkdir -p "${installation_dir}"
	[[ -d "${symlink_dir}" ]] || mkdir -p "${symlink_dir}"
}

# check the commit history file
function check_commit_file() {
	local commit_file="${SOFTWARE[commit_file]}"
	[[ -f "${commit_file}" ]] || touch "${commit_file}"
}

# install build dependencies
function check_dependencies() {
	local software="${SOFTWARE[name]}"

	echo "Checking ${software}'s dependencies..."

	if sudo nala install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev; then
		echo "done!"
		return $OK
	fi

	print_error "failed to check ${software}'s dependencies"
	return $ERROR
}

# check the binary status
function check_binary() {
	local repo_dir="${SOFTWARE[repo_dir]}"
	local commit_file="${SOFTWARE[commit_file]}"

	if binary_is_up_to_date "${repo_dir}" "${commit_file}"; then
		echo "OK: ${SOFTWARE[name]} is already up-to-date"
		echo "Done!"
		return "$OK"
	fi

	return "$ERROR"
}

# store the latest commit hash at the installation directory in the commit file
function update_commit_file() {
	local repo_dir="${SOFTWARE[repo_dir]}"
	local commit_file="${SOFTWARE[commit_file]}"

	# checks the commit history file
	[[ -f "$commit_file" ]] || touch "$commit_file"

	if (
		cd "$repo_dir" &&
			git rev-parse HEAD >"$commit_file"
	); then
		return $OK
	fi

	print_error "could not update commit file"
	return $ERROR
}

function manage_symlink() {
	local source="$1"
	local symlink="$2"
	local use_sudo="${3:-false}"
	local options="${4:--sf}"
	make_symlink "${source}" "${symlink}" "${use_sudo}" "${options}" || return "$ERROR"
}

# build software from source
function build_software() {
	local software_name="${SOFTWARE[name]}"
	local repo_dir="${SOFTWARE[repo_dir]}"
	local installation_dir="${SOFTWARE[installation_dir]}"

	echo "Building ${software_name}..."
	change_to_repo_dir "$repo_dir" || return $ERROR

	if make prefix="$installation_dir" all &&
		make prefix="$installation_dir" install; then

		echo "done!"
		restore_current_dir || return $ERROR
		return $OK
	fi

	print_error "failed to build $software_name"
	restore_current_dir || return $ERROR
	return $ERROR
}

# main function
function run() {
	local software_name="${SOFTWARE[name]}"
	local repo_url="${SOFTWARE[repo_url]}"
	local repo_dir="${SOFTWARE[repo_dir]}"
	local installation_dir="${SOFTWARE[installation_dir]}"
	local symlink="${SOFTWARE[symlink]}"
	local bin="${SOFTWARE[installed_bin]}"

	# install dependencies
	check_dependencies || return $ERROR
	# checks the necessary directories for the installation
	check_dirs
	# clone the repository
	manage_repo_cloning "${software_name}" "${repo_url}" "${repo_dir}" || return $ERROR

	# checks the commit history file
	# check_commit_file

	# check the binary status
	check_binary && return $OK
	# build source code
	build_software || return $ERROR
	# store the latest commit hash in the installation directory
	update_commit_file
	# check symlinks
	manage_symlink "${bin}" "${symlink}" || return $ERROR
	# success
	print_success "$software_name installed successfully!"
	return $OK
}

run
