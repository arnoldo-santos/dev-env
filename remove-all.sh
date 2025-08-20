#!/bin/bash
# file: remove-all.sh

remove_all() {
   echo "Removing all software..."

   rm -rf ~/software/repos/* ~/software/pre-built-bin/* ~/software/bin/* && rm -rf ~/.local/bin/* && {
      echo "OK: all software removed successfully!"
      return 0 # success
   }

   echo "ERROR: failed to remove some software" >&2
   return 1 # failure
}

remove_all
