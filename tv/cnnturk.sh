#!/bin/sh

subpage=`curl -s http://www.cnnturk.com/canli-yayin|grep embed|cut -f4 -d"/"|cut -f1 -d '"'`
key=`curl -s "http://www.cnnturk.com/player/embed/$subpage"|grep key|cut -f2 -d"="|cut -f1 -d"&"`
bitrate=1000

if [ -z $key ]; then
    echo "Failed to get play path.";
fi

vlc "http://live.netd.com.tr/S1/HLS_LIVE/cnn_turk/$bitrate/prog_index.m3u8?key=$key&live=true"
