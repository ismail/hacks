#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Licensed under public domain

# 11.01.2014

import sys
from subprocess import call

pageUrl = "http://www.myvideo.az/?act=dvr"
swfVfy = "http://www.myvideo.az/dvr/dvrAvatar7.swf?v=1.91"
streamMap = { "atv"         : "edge04-01",
              "startv"      : "edge04-04",
              "kanald"      : "edge03-01",
              "fox"         : "edge04-09",
              "ntv"         : "edge03-08",
              "kanalturk"   : "edge03-08",
              "skyturk"     : "edge03-08",
              "trt1"        : "edge03-08",
              "trt3"        : "edge03-08",
              "tmbtv"       : "edge03-07",
              "kanal24"     : "edge03-04",
              "planetturk"  : "edge04-07",
              "yumurcaktv"  : "edge04-07",
            }

nameMap = { "atv"        : "atvturk",
            "kanald"     : "canald",
            "fox"        : "foxturk",
            "ntv"        : "canlintv",
            "yumurcaktv" : "yumurcak"
          }

def help():
    print("Usage: %s <channel>" % sys.argv[0])
    print("Available channels:\n")
    i = 1
    for chan in sorted(streamMap.keys()):
        print("%d. %s" % (i, chan))
        i += 1
    sys.exit(1)

if __name__ == "__main__":
    try:
        channel = sys.argv[1]
    except IndexError:
        help()

    try:
        streamServer = streamMap[channel]
        if channel in nameMap.keys():
            channel = nameMap[channel]
        url = "rtmp://%s.az.myvideo.az/dvrh264/%s" % (streamServer, channel)
    except KeyError:
        print("No channel named %s" % channel)
        help()

    app = "dvrh264/%s" % channel
    playPath = "mp4:%s" % channel
    command = "rtmpdump -r %s -a %s -W %s -p %s -y %s --live" % \
              (url, app, swfVfy, pageUrl, playPath)
    call("%s | vlc -" % command, shell=True)
