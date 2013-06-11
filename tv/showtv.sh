#!/bin/sh

# Interestingly, secret is not static
secret=`curl -s -D- "http://www.showtvnet.com/player/index.asp?ptype=1&product=showtv"|grep -oP "(showtv2\?\S{68})"`

rtmpdump -r "rtmp://fml.45FB.edgecastcdn.net/2045FB/showtv2" -a "2045FB/showtv2" -f "WIN 11,1,102,55" -W "http://www.showtvnet.com/skins/streamplayer.swf?v1.2" -p "http://www.showtvnet.com/player/index.asp?ptype=1&product=showtv" -y "$secret" --live - | avplay -
