#!/bin/bash
# file = install-00-ghostty.sh
source ~/software/scripts-dev/std-tool.sh
source ~/software/scripts-dev/tool/installation.sh

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
	curl -fsSL https://download.opensuse.org/repositories/home:clayrisser:sid/Debian_Unstable/Release.key | gpg --dearmor | sudo tee /etc/apt/keyrings/home_clayrisser_sid.gpg >/dev/null
	ARCH="$(dpkg --print-architecture)"
	sudo tee /etc/apt/sources.list.d/home:clayrisser:sid.sources >/dev/null <<EOF
Types: deb
URIs: http://download.opensuse.org/repositories/home:/clayrisser:/sid/Debian_Unstable/
Suites: /
Architectures: $ARCH
Signed-By: /etc/apt/keyrings/home_clayrisser_sid.gpg
EOF

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
