#!/usr/bin/env python

import os
import sys

url="http://translate.google.com/translate_tts?tl="
userAgent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36"

lang=sys.argv[1]
word="%22".join(sys.argv[2:])

if __name__ == "__main__":
    os.system('curl -s -A "%s" "%s%s&q="%s"" | mpv - &> /dev/null' % (userAgent, url, lang, word))

