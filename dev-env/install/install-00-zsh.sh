#!/bin/bash
# file = install-00-zsh.sh
source ~/software/scripts-dev/std-tool.sh

check_zsh() {
	zsh --version &>/dev/null
}

install_zsh() {
	sudo nala install zsh
}

set_zsh_as_default_shell() {
	chsh -s "$(which zsh)"
}

message() {
	echo "Log out and log back in again to use zsh"
}
# or
restart_shell() {
	/bin/zsh
}

check_shell_update() {
	[[ "$SHELL" == *"zsh"* ]]
}

check_shell_version() {
	$SHELL --version 2>/dev/null | grep -q "zsh"
}
