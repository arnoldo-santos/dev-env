#!/bin/bash
#
# root directory
ROOT_DIR="$HOME/software/scripts"
source "${ROOT_DIR}"/tool/std.sh

# Check if backup path is provided
if [ $# -eq 0 ]; then
	print_error "No backup path provided!"
	echo "Usage: $0 <backup_destination_path>"
	echo "Example: $0 /media/jaw/voltu-V/backup/laptop"
	exit 1
fi
BACKUP_PATH="$1"

# directories to backup (relative to home directory)
DIRS_TO_BACKUP_FROM_HOME=(
	"data"
	"software/scripts"
	"Music"
	"Pictures"
	"tmp"
	".config/black"
	".config/ghostty"
	".config/helix"
	".config/zed"
)

# files to backup (relative to home directory)
FILES_TO_BACKUP_FROM_HOME=(
	".zshrc"
	".oh-my-zsh/custom/aliases.zsh"
)

# files to backup (relative to root directory)
FILES_TO_BACKUP_FROM_ROOT=(
	"etc/apt/sources.list"
)

# backup a directory
function backup_dir() {
	# source directory
	local src_dir="$1"
	# just a decorator
	local decorator="$2"
	# destination directory
	local dest_dir="$3"

	# skip the source dir if it doesn't exists
	if [[ ! -d "$src_dir" ]]; then
		print_warning "Source directory does not exist, skipping: $src_dir"
		return
	fi

	print_status "Backing up: ${src_dir}..."

	# check destination directory
	[[ -d "$dest_dir" ]] || mkdir -p "$dest_dir"

	# backup directory
	if rsync -av --progress "$src_dir/" "$dest_dir/"; then
		print_success "$src_dir backed up"
		return "$OK"
	fi

	# backup failed
	print_error "Failed to backup: $src_dir"
	return "$ERROR"
}

# backup a file
function backup_file() {
	# source file
	local src_file="$1"
	# just a decorator
	local decorator="$2"
	# destination file
	local dest_file="$3"

	# skip the source file if it doesn't exists
	if [[ ! -f "$src_file" ]]; then
		print_warning "Source file does not exist, skipping: $src_file"
		return
	fi

	print_status "Backing up: ${src_file}..."

	# check destination file
	[[ -f "$dest_file" ]] || {
		mkdir -p "$(dirname "$dest_file")"
		touch "$dest_file"
	}

	# backup file
	if rsync -av --progress "$src_file" "$dest_file"; then
		print_success "$src_file backed up"
		return "$OK"
	fi

	# backup failed
	print_error "Failed to backup: $src_file"
	return "$ERROR"
}

# Create a backup info file
function file_info() {
	local info_file="$BACKUP_PATH/backup_info.txt"
	cat >"$info_file" <<EOF
Laptop Backup Information
========================
Backup Date: $(date)
Backup Path: $BACKUP_DIR
Source Machine: $(hostname)
User: $(whoami)

Directories Backed Up:
EOF

	for dir in "${DIRS_TO_BACKUP_FROM_HOME[@]}"; do
		source_dir="$HOME/$dir"
		if [ -d "$source_dir" ]; then
			size=$(du -sh "$source_dir" 2>/dev/null | cut -f1)
			echo "- $dir ($size)" >>"$info_file"
		else
			echo "- $dir (SKIPPED - does not exist)" >>"$info_file"
		fi
	done
}

function backup_data() {
	print_status "Starting backup process..."
	print_status "Backup destination: $BACKUP_PATH"
	# check the backup path
	[[ -d "$BACKUP_PATH" ]] || mkdir -p "$BACKUP_PATH"

	# backup dorectories from $HOME
	for dir in "${DIRS_TO_BACKUP_FROM_HOME[@]}"; do
		backup_dir "$HOME/$dir" to "$BACKUP_PATH/$dir"
		echo # blank line for readability
	done

	# backup files from $HOME
	for file in "${FILES_TO_BACKUP_FROM_HOME[@]}"; do
		backup_file "$HOME/$file" to "$BACKUP_PATH/$file"
		echo # blank line for readability
	done

	# backup files from root
	for file in "${FILES_TO_BACKUP_FROM_ROOT[@]}"; do
		backup_file "/$file" to "$BACKUP_PATH/$file"
		echo # blank line for readability
	done
}

function run() {
	backup_data
	file_info
}

run
