#!/bin/sh
# Simple downloader for channel9.msdn.com

set -euo pipefail

title=""
url=""

extract_url () {
    ext="wmv"
    tmp=`mktemp`
    curl -s $1 -o $tmp

    url=$(grep -oP '(?<=<a href=").*(?=\">High Quality WMV</a>)' $tmp || true)
    if [ -z $url ]; then
        url=$(grep -oP '(?<=<a href=").*(?=\">High Quality MP4</a>)' $tmp || true)
        ext="mp4"
    fi

    if [ -z $url ]; then
        echo "No suitable media found."
        exit 1
    fi

    title=$(grep -oP '(?<=<title>).*(?=</title>)' $tmp | recode HTML_4.0 | sed -e 's/ |.*//g' -e 's|/|_|g' -e 's/:/./g')

    rm $tmp
}

stream_url () {
    extract_url $1
    mpv $url
}

download_url () {
    extract_url $1
    echo "Downloading \""$title".$ext\" ..."
    curl -C - -# $url -o "$title.$ext"
}

if [[ ${1:-} = "-s" ]]; then
    stream=1
    stream_url $2
else
    for url in "$@"; do
        download_url $url
    done
fi

echo "Done."
