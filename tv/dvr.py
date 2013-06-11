#!/usr/bin/env python
# -*- coding: utf-8 -*-

# 17.05.2012

import sys
from subprocess import call

pageUrl = "http://www.yildiz.tv/?act=dvr"
swfVfy = "http://www.yildiz.tv/dvr/dvrGoogle16.swf?v=1.6b"
streamMap = { "ntv"     :   "origin1",
              "ntvspor" :   "origin1",
              "tmb"     :   "origin2",
              "haberturk" : "origin2",
              "kanalturk" : "origin1",
              "sky360"    : "origin2",
              "cnbce"     : "origin2",
              "foxtv"     : "origin2",
              "eurod"     : "origin1",
              "euros"     : "origin2",
              "trt1"      : "origin1",
              "trt3"      : "origin1",
              "beyaz"     : "origin2",
              "trtcocuk"  : "origin1",
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
        url = "rtmp://%s.nar.tv/dvrh264/%s" % (streamMap[channel], channel)
    except KeyError:
        print("No channel named %s" % channel)
        help()

    app = "dvrh264/%s" % channel
    playPath = "mp4:%s" % channel
    command = "rtmpdump -r %s -a %s -W %s -p %s -y %s --live" % \
              (url, app, swfVfy, pageUrl, playPath)
    call("%s | vlc -" % command, shell=True)


