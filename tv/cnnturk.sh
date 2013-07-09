#!/bin/sh

key=`curl -s "http://video.cnnturk.com/actions/Video/NetDPlayer" | grep -oP '(?<=index.m3u8\?key=).*?(?=&live=)'`

cvlc "http://live.netd.com.tr/S1/HLS_LIVE/cnn_turk/1500/prog_index.m3u8?key=$key&live=true"
