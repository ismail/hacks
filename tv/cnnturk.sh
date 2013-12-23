#!/bin/sh

path=`curl -s "http://www.cnnturk.com/player/embed/51cc1dbd32dc9f19b8bc77cf"|grep path|cut -f2 -d"'"|sed s,"amp;","",g`

cvlc "http://live.netd.com.tr/$path"
