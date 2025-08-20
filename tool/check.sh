#!/bin/bash
# file = tool/check.sh
source ~/software/scripts-dev/exit-codes.sh

function is_parameter_missing() {
	local parameter="$1"
	[[ -z "${parameter}" ]]
}

function is_float() {
	local number="$1"
	[[ "${number}" =~ ^-?[[:digit:]]*\.[[:digit:]]+$ ]]
}

function is_integer() {
	local number="$1"
	[[ "${number}" =~ ^-?[0-9]+$ ]]
}

function check_integer_parameters() {
	local fn_name="$1"
	shift

	local arg
	for arg in "$@"; do
		# if ! [[ "$arg" =~ ^-?[0-9]+$ ]]; then
		if ! is_integer "$arg"; then
			echo "ERROR: invalid parameters '$arg' at function '${fn_name}'" >&2
			return "$ERROR"
		fi
	done

	return "$OK"
}
