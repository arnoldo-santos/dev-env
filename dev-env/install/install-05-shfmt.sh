#!/bin/bash
# file = install-shfmt.sh
# shfmt: to format scripts

set -e # Exit immediately if a command exits with a non-zero status.

# imports
source "${HOME}/software/scripts/tool/symlink.sh"
source "${HOME}/software/scripts/tool/installation.sh"

# variables
SUCCESS=0
FAILURE=1

# shfmt's data
declare -A SHFMT=(
   [name]="Shell Format"
   [binary]=shfmt
   [parent_dir]="${HOME}/software"
   [download_dir]="${HOME}/Downloads"
)

SHFMT[binary_path]="${HOME}/go/bin/${SHFMT[binary]}"
SHFMT[symlink]="${HOME}/.local/bin/${SHFMT[binary]}"
GO_INSTALLATION_SCRIPT="${HOME}/software/scripts/dev-env/essentials/dependencies/bash-lsp/golang.sh"



check_go() {
   if installed go; then
      echo "Go is already installed"
      return "${SUCCESS}"
   else
      echo "Go is not installed"
      return "${FAILURE}"
   fi
}



install_go() {
   if [ ! -f "$GO_INSTALLATION_SCRIPT" ]; then
      echo "ERROR: Go installation script not found at ${GO_INSTALLATION_SCRIPT}"
      return "${FAILURE}"
   fi

   echo "Installing Go..."
   bash "${GO_INSTALLATION_SCRIPT}"
}



manage_go() {
   local go_installation

   check_go
   go_installation=$?

   # Go is already installed
   [ "${go_installation}" -eq "${SUCCESS}" ] && return "${SUCCESS}"

   # else: Go is not installed
   install_go
   go_installation=$?

   # check installation error
   [ "${go_installation}" -eq "${FAILURE}" ] && return "${FAILURE}"
}



install_shfmt() {
   # installation OK
   go install mvdan.cc/sh/v3/cmd/shfmt@latest && return "${SUCCESS}"
   # else: installation failed
   return "${FAILURE}"
}



exit_script_if_error() {
   local operation_status=$1
   local error_message=$2

   if [ "${operation_status}" -eq "${FAILURE}" ]; then
      echo "${error_message}"
      exit "${FAILURE}"
   fi
}



manage_shfmt() {
   # parameter
   local action=$1
   # operations status
   local symlink_status
   local installation_status
   # error messages
   local installation_err_mssg="ERROR: ${SHFMT[name]} installation failed"
   local symlink_err_mssg="ERROR: ${SHFMT[name]} symlink failed"

   manage_go
   install_shfmt
   installation_status=$?
   # error -?> exit
   exit_script_if_error "${installation_status}" "${installation_err_mssg}"

   # ! error -?> make symlink
   manage_symlink "${action}" "${SHFMT[binary_path]}" "${SHFMT[symlink]}"
   symlink_status=$?
   # error -> exit
   exit_script_if_error "${symlink_status}" "${symlink_err_mssg}"
}



run_script() {

   # shfmt isn't installed
   if ! installed "${SHFMT[binary]}"; then
      echo "${SHFMT[name]} is not installed. Installing it..."
      manage_shfmt "creation"

   # shfmt is installed
   else
      echo "${SHFMT[name]} is already installed. Upgrading it..."

      local old_version
      local new_version

      old_version=$("${SHFMT[binary]}" --version | cut -d' ' -f3)

      manage_shfmt "upgrade"

      new_version=$("${SHFMT[binary]}" --version | cut -d' ' -f3)

      if [ "${old_version}" != "${new_version}" ]; then
         echo "${SHFMT[name]} has been updated from ${old_version} to ${new_version} successfully"
      else
         echo "${SHFMT[name]} is already up-to-date"
      fi
   fi
}



run_script
