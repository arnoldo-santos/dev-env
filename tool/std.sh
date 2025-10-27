#!/bin/bash

# exit codes
OK=0
YES=0
SKIP=0
NO=1
ERROR=1

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

declare -A OPERATION=(
	[nothing_to_do]=0
	[install]=1
	[upgrade]=2
)

function print_status() {
	echo -e "${BLUE}[INFO]${NC} $1"
}

function print_success() {
	echo -e "${GREEN}[SUCCESS]${NC} $1"
}

function print_warning() {
	echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

function print_error() {
	echo -e "${RED}[ERROR]${NC} $1" >&2
}

function restart_zsh() {
	exec zsh -l
}

function reload_zsh_config() {
	if zsh -c "source ~/.zshenv && source ~/.zshrc"; then
		return $OK
	else
		return $ERROR
	fi
}

function refresh_zsh() {
	if reload_zsh_config; then
		echo "OK: zsh config reloaded"
		return $OK
	fi

	echo "ERROR: failed to reload zsh config" >&2
	return $ERROR
}

# aliases to echo
function say() {
	echo "$@"
}

function put() {
	echo "$@"
}
