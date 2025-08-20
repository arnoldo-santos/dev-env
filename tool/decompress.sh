#!/bin/bash
# file = tool/decompress.sh
source ~/software/scripts-dev/exit-codes.sh

# Goal: decompress a zip file from 'source' to 'destination'
# Parameters {
#    src: source
#    dst: destination
# }
# Exit Status {
#    0: success
#    1: failure
# }
function decompress_zip_file() {
    # parameters
    local src=$1
    local dst=$2

    # extract the archive directly from ${src} to ${dst}
    # unzip -q "${src}" -d "${dst}"
    # -q: quiet
    tmp_dir="$(mktemp -d)" &&
        unzip -q "${src}" -d "${tmp_dir}" &&
        mv "${tmp_dir}"/*/* "${dst}" &&
        rm -r "${tmp_dir}" &&
        return "$OK"

    return "$ERROR"
}

# Goal: manage the decompression of a zip file from 'source' to 'destination'
# Parameters {
#    zip_file_name: name of the zip file
#    src:       source
#    dst:       destination
# }
# Exit Status {
#    0: success
#    1: failure
# }
function manage_zip_decompression() {
    # parameters
    local zip_file_name=$1
    local zip_file_path=$2
    local installation_dir=$3

    # notify the user
    echo "Extracting ${zip_file_name} to ${installation_dir}..."

    decompress_zip_file "${zip_file_path}" "${installation_dir}" && {
        echo "OK: successful extraction!"
        return "$OK"
    }

    echo "ERROR: extraction failed" >&2
    return "$ERROR"
}
