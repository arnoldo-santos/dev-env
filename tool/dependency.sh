#!/bin/bash
# file: tool/dependency.sh
set -e # Exit immediately if a command exits with a non-zero status.

source ~/software/scripts/tool/installation.sh

# Set the default package manager
PACKAGE_MANAGER=${PACKAGE_MANAGER:-nala}

# Function to get missing dependencies
get_not_installed_dependencies() {
   local dependencies=("$@")
   local uninstalled_deps=()

   for dep in "${dependencies[@]}"; do
      if ! installed "${dep}"; then
         uninstalled_deps+=("${dep}")
      fi
   done

   # Only returns the array if it's not empty
   if [ ${#uninstalled_deps[@]} -gt 0 ]; then
      printf '%s\n' "${uninstalled_deps[@]}"
   fi
}

install_dependencies() {
   local dependencies=("$@")

   for dep in "${dependencies[@]}"; do
      echo "Installing dependency '${dep}'..."

      sudo "${PACKAGE_MANAGER}" install -y "${dep}" || {
         echo "ERROR: failed to install dependency '${dep}'"
         return 1 # failure
      }

      echo "Done!"
   done

   echo
   echo "OK: all dependencies installed: ${dependencies[*]}"
   return 0 # success
}

manage_dependencies() {
   local required_dependencies=("$@")

   # update the system
   sudo "${PACKAGE_MANAGER}" update || return 1 # failure

   # Get missing dependencies
   mapfile -t not_installed_dependencies < <(get_not_installed_dependencies "${required_dependencies[@]}")

   # Are there not installed dependencies?
   if [ ${#not_installed_dependencies[@]} -gt 0 ]; then
      echo "Not installed dependencies: ${not_installed_dependencies[*]}"
      install_dependencies "${not_installed_dependencies[@]}" || return 1 # failure

   # Are all the dependencies installed?
   else
      echo "All dependencies are installed: ${required_dependencies[*]}"
      return 0 # success
   fi

}
