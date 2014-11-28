#!/bin/sh
# Simple downloader for channel9.msdn.com

set -euo pipefail
IFS=$'\n\t'

download_url() {
    tmp=`mktemp`
    curl -s $1 -o $tmp
    url=`grep -oP '(?<=<a href=").*(?=\">High Quality WMV</a>)' $tmp`
    title=`grep -oP '(?<=<meta name="title" content=").*(?="/>)' $tmp`
    rm $tmp
    curl -C - -# $url -o "$title.wmv"
}

for url in "$@"; do
    download_url $url
done
