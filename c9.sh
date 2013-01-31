#!/bin/sh
# Simple downloader for channel9.msdn.com

tmp=`mktemp`
curl -s $1 -o $tmp
url=`grep -oP '(?<=<a href=").*(?=\">High Quality WMV</a>)' $tmp`
title=`grep -oP '(?<=<meta name="title" content=").*(?="/>)' $tmp`
rm $tmp
curl -C - -# $url -o "$title.wmv"