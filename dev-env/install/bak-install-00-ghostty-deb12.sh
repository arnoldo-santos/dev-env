#!/bin/bash
# file = install-00-ghostty.sh

# root directory
ROOT_DIR="$HOME/software/scripts"
source "${ROOT_DIR}"/tool/std.sh
source "${ROOT_DIR}"/tool/installation.sh

declare -A SOFTWARE=(
	[name]=Ghostty
	[binary]=ghostty
)

function install_software() {
	echo "Checking ${SOFTWARE[name]}..."

	if is_installed "${SOFTWARE[binary]}"; then
		echo "done!"
		echo "OK: ${SOFTWARE[name]} is already installed!"
		return "$OK"
	fi

	echo "Installing ${SOFTWARE[name]}..."

	# add repository
	echo 'deb http://download.opensuse.org/repositories/home:/clayrisser:/bookworm/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/home:clayrisser:bookworm.list
	curl -fsSL https://download.opensuse.org/repositories/home:clayrisser:bookworm/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_clayrisser_bookworm.gpg >/dev/null

	# update repos
	sudo nala update

	# install
	if sudo nala install "${SOFTWARE[binary]}"; then
		echo "done!"
		return "$OK"
	fi

	echo "ERROR: ${SOFTWARE[name]} installation failed" >&2
	return "$ERROR"
}

install_software
