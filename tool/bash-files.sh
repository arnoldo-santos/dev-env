#!/bin/bash
# file = tool/bash-files.sh
source ~/software/scripts-dev/std-tool.sh

function is_file_name_ok() {
    local file_name="$1"
    [[ "${file_name}" =~ ^[-[:alnum:]\._]+$ ]]
}

# Usage {
#	file_exists <file>
# }
# Goal {
#   check If a file exists
#}
# Parameters {
#   $1 = the file
#}
# Returns {
#  0 = success
#  nonzero = failure
#}
function file_exists() {
    local file="$1"
    [[ -f "${file}" ]]
}

# Usage {
#	file_has_sh_extension <file>
# }
# Goal {
#   check If a file has 'sh' extension
# }
# Parameters {
#   $1 = the file
# }
# Returns {
#  0 = success
#  nonzero = failure
# }
function file_has_sh_extension() {
    local file="$1"
    [[ "${file}" == *.sh ]]
}

# Usage {
#	file_has_a_bash_shebang <file>
# }
# Goal {
#   check If a file has a bash shebang
# }
# Parameters {
#   $1 = the file
# }
# Returns {
#  0 = success
#  nonzero = failure
# }
function file_has_a_bash_shebang() {
    local file="$1"

    grep -q "^#!/bin/bash\|#!/usr/bin/env bash" "${file}"
}

# Usage {
#	file_is_a_bash_script <file>
# }
# Goal {
#   check If a file is a bash script
# }
# Parameters {
#   $1 = the file
# }
# Returns {
#  0 = success
#  nonzero = failure
# }
function file_is_a_bash_script() {
    local file="$1"

    ! file_exists "${file}" && {
        echo "ERROR: file '${file}' not found" >&2
        return "${NO}"
    }

    ! file_has_sh_extension "${file}" && {
        echo "ERROR: file '${file}' doesn't has '.sh' extension" >&2
        return "${NO}"
    }

    ! file_has_a_bash_shebang "${file}" && {
        echo "ERROR: file '${file}' doesn't has a bash shebang" >&2
        return "${NO}"
    }

    return "${YES}"
}

# Usage {
#	script_array_is_empty <script_array>
# }
# Goal {
#   check If a script array is empty
# }
# Parameters {
#   $1 = script array
# }
# Returns {
#  0 = success
#  nonzero = failure
# }
function script_array_is_empty() {
    local scripts=("$@")
    ((${#scripts[@]} == 0))
}

# Usage {
#	script_array_only_has_bash_files <script_array>
# }
# Goal {
#   check If a script array only has bash files
# }
# Parameters {
#   $1 = script array
# }
# Returns {
#  0 = success
#  nonzero = failure
# }
function script_array_only_has_bash_files() {
    local scripts=("$@")

    for script in "${scripts[@]}"; do
        ! file_is_a_bash_script "${script}" && {
            echo "ERROR: The file '${script}' is not a bash script" >&2
            return "${NO}"
        }
    done

    return "${YES}"
}

# Usage {
#	script_is_executable <script>
# }
# Goal {
#   check If a script is executable
# }
# Parameters {
#   $1 = the script
# }
# Returns {
#  0 = success
#  nonzero = failure
# }
function script_is_executable() {
    local script="${1}"
    [[ -x "${script}" ]]
}

# Usage {
#	make_script_executable <script>
# }
# Goal {
#   make a script executable
# }
# Parameters {
#   $1 = the script
# }
# Returns {
#  0 = success
#  nonzero = failure
# }
function make_script_executable() {
    local script="${1}"

    chmod +x "${script}" && {
        echo "OK: the script '${script}' was made executable successfully"
        return "${OK}"
    }

    echo "ERROR: failed to make script '${script}' executable" >&2
    return "${ERROR}"
}

# Usage {
#	run_script <script>
# }
# Goal {
#   run a script
# }
# Parameters {
#   $1 = the script
# }
# Returns {
#  0 = success
#  nonzero = failure
# }
function run_script() {
    local script="${1}"

    script_is_executable "${script}" || {
        echo "WARNING: $script hasn't execution permission!"
        return "$SKIP"
    }
    bash "${script}"

    # ! script_is_executable "${script}" && {
    #     make_script_executable "${script}" || return "${ERROR}"
    # }
    # echo
    # # run the script
    # bash "${script}"
}

# Usage {
#	run_scripts <script_array>
# }
# Goal {
#   run an array of scripts
# }
# Parameters {
#   $1 = the array of scripts
# }
# Returns {
#  0 = success
#  nonzero = failure
# }
function run_scripts() {
    local scripts=("$@")

    if script_array_is_empty "${scripts[@]}"; then
        echo "ERROR: script list is empty" >&2
        return "${ERROR}"
    fi

    if ! script_array_only_has_bash_files "${scripts[@]}"; then
        echo "ERROR: script list has non-bash files" >&2
        return "${ERROR}"
    fi

    for script in "${scripts[@]}"; do
        echo
        echo "Running '${script}'..."

        if run_script "${script}"; then
            echo "OK: '${script}' executed successfully!"
            echo
        # else
        #     echo "ERROR: script execution failed at '${script}'" >&2
        #     echo
        #     return "${ERROR}"
        fi
    done

    return "${OK}"
}
