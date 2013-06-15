#!/usr/bin/env python

import os
import sys

url="http://translate.google.com/translate_tts?tl="
userAgent="Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) \
           Chrome/29.0.1535.3 Safari/537.36"
lang=sys.argv[1]
word="%22".join(sys.argv[2:])

if __name__ == "__main__":
    os.system("curl -s -A \"%s\" \"%s%s&q=\"%s\"\" | vlc -" % (userAgent, url, lang, word))

