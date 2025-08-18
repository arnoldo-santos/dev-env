#!/bin/bash
# file = tool/version.sh



# Goal { check if the first version is greater than the others one }
# Parameters {
#   $1 -> first version
#   $2 -> second version
#   $x -> others version
#}
# Returns {
#   true    -> 0
#   false   -> non-zero
#}
version_is_greater() {
   test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}
