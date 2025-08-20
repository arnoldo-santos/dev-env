#!/bin/bash

# exit codes
OK=0
YES=0
SKIP=0
NO=1
ERROR=1

# old name = reload_shell_config
function restart_shell() {
	exec zsh -l
}

function reload_shell_config() {
	zsh -c "source ~/.zshenv && source ~/.zshrc"
}

# aliases to echo
function say() {
	echo "$@"
}

function put() {
	echo "$@"
}
