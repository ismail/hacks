#!/bin/sh

# Interestingly, secret is not static
secret=`curl -s -D- "http://www.showtvnet.com/player/index.asp?ptype=1&product=showtv"|grep -oP "(showtv2\?\S{68})"`

rtmpdump -r "rtmp://mn-l.mncdn.com/showtv/" -a "showtv/" -f "LNX 12,0,0,44" -W "http://static.oroll.com/p.swf" -p "http://www.showtv.com.tr/canli-yayin/showtv" -y "showtv2" - | vlc -
