#!/bin/bash
# file = build-cspell-lsp.sh
set -e # Exit immediately if a command exits with a non-zero status.
source ~/software/dev/dev-env/tool/git-repo.sh
source ~/software/dev/dev-env/tool/directory.sh

declare -A SOFTWARE=(
    [name]="Spell Checker LSP"
    [binary]=cspell-lsp
    [installation_dir]="$HOME/software/repos/spell-checker"
    [dictionary_path]=/usr/share/dict/words
)

function config_helix() {
    local spell_checker="${SOFTWARE[name]}"
    local helix_config_dir=~/.config/helix
    local helix_lang_config_file="${helix_config_dir}"/languages.toml
    local dictionary_path="${SOFTWARE[dictionary_path]}"

    # create config directory if it doesn't exist
    if ! is_dir "$helix_config_dir"; then
        mkdir -p "$helix_config_dir"
    fi

    # Helix's languages.toml file doesn't exists
    [[ -f "${helix_lang_config_file}" ]] || {
        echo "ERROR: failed to config Helix to use ${spell_checker}" >&2
        echo "       file not found: ${helix_lang_config_file}" >&2
        return 1 # failure
    }

    if grep -q "cspell" "${helix_lang_config_file}"; then
        echo "OK: ${spell_checker} config is already in ${helix_lang_config_file}"
        return 0 # SUCCESS
    fi

    echo "Adding Helix config to use ${spell_checker}..."

    # Append configuration to languages.toml
    cat <<EOF >>"${helix_lang_config_file}"
[language-server.cspell]
command = "cspell-lsp"
args = ["--stdio", "--dictionary", "${dictionary_path}"]
EOF

    echo "OK: ${spell_checker} config added to ${helix_lang_config_file}"
    return 0 # SUCCESS
}

install_spell_checker() {
    if npm install -g @vlabo/cspell-lsp; then
        config_helix || return 1 # shit
        return 0                 # ok
    else
        echo "ERROR: Failed to install @vlabo/cspell-lsp" >&2
        return 1
    fi
}

install_spell_checker

# #------------------------------------------------------------------------------
# # not use it: error with 'bun'
# build_spell_checker() {
#    local prog_name="${SPELL_CHECKER[name]}"
#    local installation_dir="${SPELL_CHECKER[installation_dir]}"
#    cd "${installation_dir}"

#    npm install && bun build ./main.ts --compile --outfile cspell-lsp && {
#       # return to the old directory
#       cd -
#       echo "OK: ${prog_name} built successfully!"
#       return 0 # success
#    }
#    cd -
#    echo "ERROR: failed to build ${prog_name}"
#    return 1 # failure
# }
# # not use it
# build_program() {
#    local prog_name="${SPELL_CHECKER[name]}"
#    local repo_url="${SPELL_CHECKER[git_repo_url]}"
#    local installation_dir="${SPELL_CHECKER[installation_dir]}"

#    manage_repo_cloning "${prog_name}" "${repo_url}" "${installation_dir}" &&
#       build_spell_checker "${prog_name}" "${installation_dir}" && config_helix
# }
