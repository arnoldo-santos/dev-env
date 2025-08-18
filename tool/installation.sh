#!/bin/bash
# file = installation.sh

# Usage {
#	is_installed <binary>
# }
# Goal {
#   check If a program IS installed
#}
# Parameters {
#   $1 = program's binary
#}
# Returns {
#  0 = success
#  nonzero = failure
#}
function is_installed() {
	local binary="$1"
	command -v "$binary" >/dev/null 2>&1
}

# Usage {
#	check_cmd <command>
# }
# Goal {
#   check IF a command EXECUTES correctly
#}
# Parameters {
#   $1 = command to check
#}
# Returns {
#  0 = success
#  nonzero = failure
#}
function check_cmd() {
	local cmd="$1"
	eval "$cmd" >/dev/null 2>&1
}
