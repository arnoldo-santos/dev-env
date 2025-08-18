#!/bin/bash
# file = tool/directory.sh

# Goal = check if a path is a directory
# Usage = function <path>
function is_dir() {
	local dir="$1"
	[[ -d "$dir" ]]
}

function check_dir() {
	local dir="$1"

	is_dir "$dir" || {
		echo "ERROR: $dir isn't a directory" >&2
		return 1 # shit
	}
	return 0 # ok
}

# Goal = check if a directory is empty
# Usage = function <directory>
function dir_is_empty() {
	local dir="$1"

	# check if it's a directory
	check_dir "$dir" || return 2 # shit

	# Enable nullglob to avoid literal globs if directory is empty
	shopt -s nullglob dotglob
	local files=("$dir"/*)
	shopt -u nullglob dotglob

	((${#files[@]} == 0))
}

# change to a directory safely
function change_to_dir() {
	local dir="$1"

	# check if it's a directory
	check_dir "$dir" || return 1 # shit

	cd "$dir" 2>/dev/null && return 0 # ok

	echo "ERROR: failed to change to directory '${dir}'" >&2
	return 1 # shit
}

# Goal = check if a directory is a Git repository
function dir_is_a_git_repo() {
	local dir="$1"

	# it's an empty directory
	dir_is_empty "$dir" && {
		echo "ERROR: $dir is an empty directory" >&2
		return 1 # shit
	}

	# it isn't a directory
	(("$?" == 2)) && return 2 # shit

	# check if the directory is inside a Git work tree
	git -C "$dir" rev-parse --is-inside-work-tree &>/dev/null
}

function save_current_dir() {
	local current_dir
	current_dir="$PWD"

	# push current dir
	pushd . >/dev/null || {
		echo "ERROR: 'pushd ${current_dir}' failed" >&2
		return 1 # shit
	}
	return 0 # ok
}

function restore_current_dir() {
	local current_dir
	current_dir="$PWD"

	popd >/dev/null || {
		echo "ERROR: 'popd ${current_dir}' failed" >&2
		return 1 # shit
	}
	return 0 # ok
}

function change_to_repo_dir() {
	local repo_dir="$1"
	local current_dir
	current_dir="$PWD"

	save_current_dir || return 1 # shit

	# change to the repo dir
	change_to_dir "${repo_dir}" || {
		restore_current_dir
		return 1 # shit
	}

	return 0 # ok
}

# Goal: Check if the given directory is dangerous to delete (like / or $HOME)
# Usage: is_dangerous_dir <path>
# Return: 0 = dangerous, 1 = safe
function is_dangerous_dir() {
	local path="$1"

	# Resolve absolute path
	local resolved
	resolved="$(readlink -f "$path" 2>/dev/null)"

	# Block if empty or not resolvable
	[[ -z "$resolved" ]] && return 0

	# Block if it's root or home
	[[ "$resolved" == "/" ]] && return 0
	[[ "$resolved" == "$HOME" ]] && return 0
	[[ "$resolved" == "$HOME/" ]] && return 0

	# Block if it's one of the system-critical dirs
	case "$resolved" in
	/home | /root | /etc | /usr | /bin | /sbin | /lib | /lib64 | /boot | /opt | /srv | /var | /dev | /proc | /sys | /run)
		return 0
		;;
	esac

	# Enforce minimum path depth (e.g., /foo = unsafe, /foo/bar = safe)
	local depth
	depth=$(awk -F'/' '{print NF-1}' <<<"$resolved")
	((depth < 2)) && return 0

	return 1 # safe
}

function recreate_repo_dir() {
	local installation_dir="$1"

	# installation_dir isn't a git repo
	echo "INFO: directory '${installation_dir}' is not a Git repository"
	echo "Recreating directory..."

	if is_dangerous_dir "$installation_dir"; then
		echo "ERROR: refusing to delete dangerous directory '$installation_dir'" >&2
		return 1
	fi

	rm -rf "${installation_dir}" || {
		echo "ERROR: failed to remove directory '${installation_dir}'" >&2
		return 1 # failure
	}

	mkdir -p "${installation_dir}" || {
		echo "ERROR: failed to create directory '$installation_dir'" >&2
		return 1 # shit
	}

	echo "done!"
	return 0 # ok
}
