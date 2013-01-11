#!/usr/bin/env python
# -*- coding: utf-8 -*-

# 17.05.2012

import sys
from subprocess import call

pageUrl = "http://www.yildiz.tv/?act=dvr"
swfVfy = "http://www.yildiz.tv/dvr/dvrGoogle16.swf?v=1.6b"
streamMap = { "canlintv"     :   "edge1-1",
              "ntvspor"      :   "origin3",
              "canliatv"     :   "edge1-1",
              "tmbtv"        :   "origin2",
              "kanala"       :   "origin2",
              "haberturk"    :   "origin2",
              "kanalturk"    :   "edge1-1",
              "skyturk"      :   "origin2",
              "cnbce"        :   "origin2",
              "tntturk"      :   "edge1-1",
              "foxtv"        :   "origin2",
              "blumberg"     :   "edge1-1",
              "eurod"        :   "origin3",
              "euros"        :   "origin2",
              "trt1"         :   "edge1-1",
              "trtavaz"      :   "edge1-1",
              "trt3"         :   "edge1-1",
              "kanal7"       :   "edge1-1",
              "cine5"        :   "origin2",
              "yumurcak"     :   "origin2",
              "flash"        :   "origin2",
              "canlitv8"     :   "origin2",
              "tv24"         :   "origin3",
              "samanyolu"    :   "origin3",
              "kraltvavrupa" :   "origin2",
              "power"        :   "origin2",
              "beyaz"        :   "origin3",
              "trtcocuk"     :   "origin3",
              "kidz"         :   "origin3",
              "akilli"       :   "origin3",
              "idmanaz"      :   "edge1-1",
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
    call("%s | avplay -" % command, shell=True)


