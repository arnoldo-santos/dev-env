#!/bin/bash
# file: build-all.sh

# Set strict mode
set -euo pipefail

# import
source "${HOME}/software/scripts/tool/bash-files.sh"

build_all() {
   local scripts
   scripts=("${HOME}"/software/scripts/dev-env/build/build-*.sh)

   echo "Building software..."

   if run_scripts "${scripts[@]}"; then
      echo "OK: all software built successfully!"
      return 0 # success
   else
      echo "ERROR: failed to build some software" >&2
      return 1 # failure
   fi
}

build_all
