#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
function print_status() {
	echo -e "${BLUE}[INFO]${NC} $1"
}

function print_success() {
	echo -e "${GREEN}[SUCCESS]${NC} $1"
}

function print_warning() {
	echo -e "${YELLOW}[WARNING]${NC} $1"
}

function print_error() {
	echo -e "${RED}[ERROR]${NC} $1"
}

# Check if backup path is provided
if [ $# -eq 0 ]; then
	print_error "No backup path provided!"
	echo "Usage: $0 <backup_destination_path>"
	echo "Example: $0 /media/jaw/voltu-V/backup/laptop"
	exit 1
fi
BACKUP_PATH="$1"

# directories to backup (relative to home directory)
HOME_DIRS_TO_BACKUP=(
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
HOME_FILES_TO_BACKUP=(
	".zshrc"
	".oh-my-zsh/custom/aliases.zsh"
)

# files to backup (relative to root directory)
ROOT_FILES_TO_BACKUP=(
	"etc/apt/sources.list"
)

# function to backup a directory
function backup_dir_from_home() {
	local source_dir="$HOME/$1"
	local dest_dir="$BACKUP_PATH/$1"

	if [[ -d "$source_dir" ]]; then
		print_status "Backing up: ${source_dir}..."

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

function backup_file() {
	local source_file="$1"
	local dest_file="$2"

	if [[ -f "$source_file" ]]; then
		print_status "Backing up: ${source_file}..."

		[[ -f "$dest_file" ]] || {
			mkdir -p "$(dirname "$dest_file")"
			touch "$dest_file"
		}

		# Use rsync for efficient backup with progress
		if rsync -av --progress "$source_file" "$dest_file"; then
			print_success "done!"
		else
			print_error "Failed to backup: $1"
			return 1
		fi
	else
		print_warning "Source file does not exist, skipping: $source_file"
	fi
}

function backup_file_from_home() {
	local source_file="$HOME/$1"
	local dest_file="$BACKUP_PATH/$1"
	backup_file "$source_file" "$dest_file"
}

# not ready
function backup_file_from_root() {
	local source_file="/$1"
	local dest_file="$BACKUP_PATH/$1"
	backup_file "$source_file" "$dest_file"
}

function backup_directories() {
	for dir in "${HOME_DIRS_TO_BACKUP[@]}"; do
		backup_dir_from_home "$dir"
		echo # blank line for readability
	done
}

function backup_files() {
	for file in "${HOME_FILES_TO_BACKUP[@]}"; do
		backup_file_from_home "$file"
		echo # blank line for readability
	done

	for file in "${ROOT_FILES_TO_BACKUP[@]}"; do
		backup_file_from_root "$file"
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

	for dir in "${HOME_DIRS_TO_BACKUP[@]}"; do
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
backup_files
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
