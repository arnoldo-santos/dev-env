#!/bin/bash
# file = install-00-zsh.sh

# root directory
ROOT_DIR="$HOME/software/scripts"
source "${ROOT_DIR}"/tool/std.sh

function zsh_is_installed() {
	zsh --version &>/dev/null
}

function install_zsh() {
	sudo nala install zsh
}

function set_zsh_as_default_shell() {
	echo "Setting zsh as the default shell..."

	if chsh -s "$(which zsh)"; then
		echo "Done!"
		echo "Log out and log back in again to use zsh"
		return "$OK"

	else
		echo "ERROR: faliled to set zsh as default shell" >&2
		return "$ERROR"
	fi
}

function shell_is_zsh_0() {
	[[ "$SHELL" == *"zsh"* ]]
}

function shell_is_zsh_1() {
	$SHELL --version 2>/dev/null | grep -q "zsh"
}

function shell_is_zsh() {
	shell_is_zsh_0 || shell_is_zsh_1
}

# install Oh My Zsh
function install_ohmyzsh() {
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

function install_zsh_autosuggestions() {
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

function run() {
	echo "Checking zsh..."

	if zsh_is_installed; then
		echo "OK: zsh is installed"
	fi

	if shell_is_zsh; then
		echo "Done!"
		return "$OK"
	fi

	echo "done!"
	echo "Installing zsh..."

	if install_zsh; then
		echo "done!"

		if zsh_is_installed; then
			echo "OK: zsh installation successfull!"
		else
			echo "ERROR: zsh checking failed" >&2
			return "$ERROR"
		fi

	else
		echo "ERROR: zsh installation failed" >&2
		return "$ERROR"
	fi

	set_zsh_as_default_shell || exit "$ERROR"
	exit "$OK"

	if set_zsh_as_default_shell; then
 		install_ohmyzsh || return "$ERROR"
		install_zsh_autosuggestions || return "$ERROR"
		exit "$OK"
	else
		exit "$ERROR"
	fi
}

run
