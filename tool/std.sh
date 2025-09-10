#!/bin/bash

# exit codes
OK=0
YES=0
SKIP=0
NO=1
ERROR=1

declare -A OPERATION=(
	[nothing_to_do]=0
	[install]=1
	[upgrade]=2
)

# old name = reload_shell_config
function restart_zsh() {
	exec zsh -l
}

function reload_zsh_config() {
	zsh -c "source ~/.zshenv && source ~/.zshrc"
}

function refresh_zsh() {
	if ! reload_zsh_config; then
		echo "ERROR: failed to reload zsh config" >&2
		return "$ERROR"
	fi
	return "$OK"
}

# aliases to echo
function say() {
	echo "$@"
}

function put() {
	echo "$@"
}
