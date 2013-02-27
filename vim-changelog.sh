#!/bin/zsh

directory=ftp://ftp.vim.org/pub/vim/patches
version=7.3

echo "Updated to revision $2, fixes the following problems"
for i in {$1..$2}; do
    curl $directory/$version/$version.$i -s | grep -v "Binary file (standard input) matches" | \
    tr '\n' ' '|grep -oP "Problem:.*Solution:"|sed s,"Problem:    ","  * ",|sed s,"Solution:",,|tr '\t' '\n'
done
