#!/bin/sh

rtmpdump -r "rtmp://mn-l.mncdn.com/showtv/" -a "showtv/" -f "LNX 12,0,0,44" -W "http://static.oroll.com/p.swf" -p "http://www.showtv.com.tr/canli-yayin/showtv" -y "showtv2" - | mpv -
