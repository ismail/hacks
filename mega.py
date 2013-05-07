#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import re
from urllib.request import urlopen

url="https://search.twitter.com/search.json"
query="q=%23Mega&result_type=recent"

def fetchTweets(url, query):
    data = urlopen("%s?%s" % (url, query)).read()
    d = json.loads(data.decode("utf-8"))
    imageUrl = None

    for result in d["results"]:
        text = result["text"]
        if text.find("$") >= 0 and text.find("t.co") >= 0:
            url = text.split("http://")[1]
            imageUrl = findImage(url)
            break

    print(imageUrl)

def findImage(url):
    data = urlopen("http://%s" % url).read().decode("utf-8")
    m = re.search("(?<=pbs.twimg.com/media/)\w+", data)
    return ("https://pbs.twimg.com/media/%s.jpg:large" % m.group(0))

if __name__ == "__main__":
    fetchTweets(url, query)
