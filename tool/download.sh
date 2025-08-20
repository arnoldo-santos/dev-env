#!/bin/bash
# file = tool/download.sh
source ~/software/scripts-dev/std-tool.sh

# Goal: download a file using the curl command
# Parameters {
#    Required {
#       download_dst:   destination of the file to be downloaded
#       download_url:   the download URL
#    }
# }
# Exit Status {
#    0:          success
#    non-zero:   failure
# }
function download_file() {
    # parameters
    local download_dst=$1
    local download_url=$2
    # download the file
    curl -f -L -o "${download_dst}" "${download_url}"
}

# Goal: download a file using the curl command
# Parameters {
#    Required {
#       file_name:      the download file name
#       download_dir:   the download directory
#       download_url:   the download URL
#    }
# }
# Exit Status {
#    0: success
#    1: failure
# }
function manage_download() {
    # parameters
    local file_name=$1
    local download_dir=$2
    local download_url=$3
    # destination of the file to be downloaded
    local download_dst="${download_dir}/${file_name}"

    # show downloading message
    printf "%s\n" "Downloading ${file_name} to ${download_dir}..."

    download_file "${download_dst}" "${download_url}" || {
        echo "ERROR: download failed" >&2
        return "$ERROR"
    }

    echo "OK: download successfully!"
    return "$OK"
}
