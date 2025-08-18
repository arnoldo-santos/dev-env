#!/bin/bash

redonly OK=0
redonly ERROR=1

function check_parameters_quantity() {
	local fn_name="$1"
	local expected_args="$2"
	shift 2

	if [[ $# -ne $expected_args ]]; then
		echo "ERROR: function '${fn_name}' expected ${expected_args} arguments, got $#." >&2
		return "$ERROR"
	fi

	return "$OK"
}

function is_parameter_missing() {
	local fn_name="${FUNCNAME[0]}"
	check_parameters_quantity "$fn_name" 1 "$@" || return "$ERROR"
	local parameter="$1"

	[[ -z "${parameter}" ]]
}

function is_float() {
	local fn_name="${FUNCNAME[0]}"
	check_parameters_quantity "$fn_name" 1 "$@" || return "$ERROR"
	local number="$1"

	[[ "${number}" =~ ^-?[[:digit:]]*\.[[:digit:]]+$ ]]
}

function is_integer() {
	local fn_name="${FUNCNAME[0]}"
	check_parameters_quantity "$fn_name" 1 "$@" || return "$ERROR"
	local number="$1"

	[[ "${number}" =~ ^-?[0-9]+$ ]]
}

function is_file_name() {
	local fn_name="${FUNCNAME[0]}"
	check_parameters_quantity "$fn_name" 1 "$@" || return "$ERROR"
	local file_name="$1"

	[[ "${file_name}" =~ ^[-[:alnum:]\._]+$ ]]
}

function check_integer_parameters() {
	local fn_name="$1"
	shift

	local arg
	for arg in "$@"; do
		# if ! [[ "$arg" =~ ^-?[0-9]+$ ]]; then
		if ! is_integer "$arg"; then
			echo "ERROR: in function '${fn_name}' all arguments must be integers. Got invalid value: '$arg'" >&2
			return "$ERROR"
		fi
	done

	return "$OK"
}
