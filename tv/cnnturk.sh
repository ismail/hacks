#!/bin/sh

key=`curl -s "http://www.cnnturk.com/player/embed/51cc1dbd32dc9f19b8bc77cf"|grep key|cut -f2 -d"="|cut -f1 -d"&"`

cvlc "http://live.netd.com.tr/S1/HLS_LIVE/cnn_turk/index.m3u8?key=$key&live=true"
