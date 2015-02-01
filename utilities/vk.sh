#!/usr/bin/env zsh

username=vk@donmez.ws
password=
base="http://vk.com/video_ext.php?"

download () {
    values=($(curl -s $1 | grep -o -E "oid=.*hd=" | awk -F '&#038;' '{print $1" "$2" "$3}'))
    youtube-dl "$base$values[1]&$values[2]&$values[3]&api_hash=&hd=1" --username=$username --password=$password
}

for url in "$@"; do
    download $url
done
