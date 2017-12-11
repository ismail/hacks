#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# 2006-2014 İsmail Dönmez <ismail@donmez.ws>

from urllib.parse import urlencode
from urllib.request import urlopen, Request
from urllib.error import HTTPError
import sys

URL = "http://www.tdk.gov.tr/index.php?option=com_gts&arama=gts&guid=TDK.GTS.546b3e9c2e0046.90953438"

try:
    from bs4 import BeautifulSoup as soup
except ImportError:
    print("Sisteminize öncelikle BeautifulSoup4 kurun.")
    sys.exit(1)


def searchWord(word):
    postData = {'kelime': word}
    req = Request(URL, urlencode(postData).encode("iso-8859-9"))

    try:
        result = urlopen(req).read()
    except HTTPError as e:
        print(e)
        sys.exit(-1)

    results = soup(result, "lxml").findAll(
        'table', attrs={
            'id': 'hor-minimalist-a'
        })
    if results:
        resultTable = results[0]
    else:
        print("%s sözlükte bulunamadı." % word)
        sys.exit(0)

    for td in resultTable.findAll('td'):
        text = td.text.strip()
        text = text.replace('"', '\n"', 1)
        print("%s\n" % text)


if __name__ == "__main__":
    if (len(sys.argv) != 2):
        print("Aramak için bir sözcük girin.")
    else:
        searchWord(sys.argv[1])
