#!/usr/bin/env zsh

directory=ftp://ftp.vim.org/pub/vim/patches
version=7.4

echo "Updated to revision $2, fixes the following problems"
for i in {$1..$2}; do
    curl $directory/$version/$version.$i -s | grep -v "Binary file (standard input) matches" | \
    tr -d '\n' | grep -oP "Problem:.*Solution:" | sed s,"Problem:    ","  * ", | sed s,"Solution:",, | \
    tr '\t' '\n' | sed  s,'           ','',
done
