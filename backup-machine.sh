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
DIRS_TO_BACKUP=(
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

# files to backup
FILES_TO_BACKUP=(
	# relative to home directory
	".zshrc"
	".oh-my-zsh/custom/aliases.zsh"
	# relative to root directory
	"etc/apt/sources.list"
)

# function to backup a directory
function backup_dir() {
	local source_dir="$1"
	local decorator="$2"
	local dest_dir="$3"

	if [[ -d "$source_dir" ]]; then
		print_status "Backing up: ${source_dir}..."

		# check destination directory
		# mkdir -p "$(dirname "$dest_dir")"
		[[ -d "$dest_dir" ]] || mkdir -p "$dest_dir"

		# backup directory
		if rsync -av --progress "$source_dir/" "$dest_dir/"; then
			print_success "$source_dir backed up"
			return "$OK"
		else
			print_error "Failed to backup: $source_dir"
			return "$ERROR"
		fi
	else
		print_warning "Source directory does not exist, skipping: $source_dir"
	fi
}

function backup_directories() {
	for dir in "${DIRS_TO_BACKUP[@]}"; do
		backup_dir "$HOME/$dir" to "$BACKUP_PATH/$dir"
		echo # blank line for readability
	done
}

function backup_file() {
	local source_file="$1"
	local decorator="$2"
	local dest_file="$3"

	if [[ -f "$source_file" ]]; then
		print_status "Backing up: ${source_file}..."

		# check destination file
		[[ -f "$dest_file" ]] || {
			mkdir -p "$(dirname "$dest_file")"
			touch "$dest_file"
		}

		# backup file
		if rsync -av --progress "$source_file" "$dest_file"; then
			print_success "$source_file backed up"
			return "$OK"
		else
			print_error "Failed to backup: $source_file"
			return "$ERROR"
		fi
	else
		print_warning "Source file does not exist, skipping: $source_file"
	fi
}

function backup_files() {
	for file in "${FILES_TO_BACKUP[@]}"; do
		# backup_file
		echo # blank line for readability
	done
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

	for dir in "${DIRS_TO_BACKUP[@]}"; do
		source_dir="$HOME/$dir"
		if [ -d "$source_dir" ]; then
			size=$(du -sh "$source_dir" 2>/dev/null | cut -f1)
			echo "- $dir ($size)" >>"$info_file"
		else
			echo "- $dir (SKIPPED - does not exist)" >>"$info_file"
		fi
	done
}

print_status "Starting laptop backup process..."
print_status "Backup destination: $BACKUP_PATH"

[[ -d "$BACKUP_PATH" ]] || mkdir -p "$BACKUP_PATH"

backup_directories
file_info

#------------------------------------------------------------------------------
# mkdir -p /media/jaw/voltu-V/backup/laptop

# # Backup main directories
# rsync -av ~/data/ /media/jaw/voltu-V/backup/laptop/data/
# rsync -av ~/software/scripts/ /media/jaw/voltu-V/backup/laptop/software/scripts/
# rsync -av ~/Music/ /media/jaw/voltu-V/backup/laptop/Music/
# rsync -av ~/Pictures/ /media/jaw/voltu-V/backup/laptop/Pictures/
# rsync -av ~/tmp/ /media/jaw/voltu-V/backup/laptop/tmp/

# # Backup specific config directories
# rsync -av ~/.config/black/ /media/jaw/voltu-V/backup/laptop/.config/black/
# rsync -av ~/.config/ghostty/ /media/jaw/voltu-V/backup/laptop/.config/ghostty/
# rsync -av ~/.config/helix/ /media/jaw/voltu-V/backup/laptop/.config/helix/
# rsync -av ~/.config/zed/ /media/jaw/voltu-V/backup/laptop/.config/zed/
#------------------------------------------------------------------------------
