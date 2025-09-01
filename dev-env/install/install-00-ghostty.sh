#!/bin/bash
# file = install-ghostty.sh
source ~/software/dev/dev-env/tool/installation.sh

function install_ghostty() {
	echo "Instaling Ghostty..."

	if is_installed ghostty; then
		echo "Ghostty: I'm already installed"
		return 0
	fi

	# add repository
	echo 'deb http://download.opensuse.org/repositories/home:/clayrisser:/bookworm/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/home:clayrisser:bookworm.list
	curl -fsSL https://download.opensuse.org/repositories/home:clayrisser:bookworm/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_clayrisser_bookworm.gpg >/dev/null
	sudo nala update
	sudo nala install ghostty
}

install_ghostty
