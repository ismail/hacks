#!/bin/sh
# Simple downloader for channel9.msdn.com

set -euo pipefail
IFS=$'\n\t'

download_url() {
    tmp=`mktemp`
    curl -s $1 -o $tmp
    url=`grep -oP '(?<=<a href=").*(?=\">High Quality WMV</a>)' $tmp`
    title=`grep -oP '(?<=<title>).*(?=</title>)' $tmp | recode HTML_4.0 | sed 's/ |.*//g'`
    rm $tmp
    echo "Downloading \""$title".wmv\" ..."
    curl -C - -# $url -o "$title.wmv"
}

for url in "$@"; do
    download_url $url
done

echo "Done."
