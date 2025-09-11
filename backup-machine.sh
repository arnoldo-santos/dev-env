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

# Directories to backup (relative to home directory)
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

# function to backup a directory
function backup_directory() {
	local source_dir="$HOME/$1"
	local dest_dir="$BACKUP_PATH/$1"

	if [[ -d "$source_dir" ]]; then
		print_status "Backing up: ${source_dir}..."

		# Create destination directory structure
		# mkdir -p "$(dirname "$dest_dir")"
		[[ -d "$dest_dir" ]] || mkdir -p "$dest_dir"

		# Use rsync for efficient backup with progress
		if rsync -av --progress "$source_dir/" "$dest_dir/"; then
			print_success "done!"
		else
			print_error "Failed to backup: $1"
			return 1
		fi
	else
		print_warning "Source directory does not exist, skipping: $source_dir"
	fi
}

function backup_directories() {
	for dir in "${DIRS_TO_BACKUP[@]}"; do
		backup_directory "$dir"
		echo # Add blank line for readability
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
