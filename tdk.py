#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Placed under public domain.
# 2006-2012 İsmail Dönmez <ismail@namtrac.org>

try:
    from urllib2 import urlopen, Request
except ImportError:
    from urllib.request import urlopen, Request
import re
import sys

try:
    from bs4 import BeautifulSoup as soup
except ImportError:
    try:
        from BeautifulSoup import BeautifulSoup as soup
    except ImportError:
        print("Sisteminize öncelikle BeautifulSoup kurun")
        sys.exit(1)

def tidyHTML(code):
    code = code.replace("&nbsp;"," ")
    code = code.replace("<br>","")
    code = code.replace("<br />","")
    code = code.replace("<i>","")
    code = code.replace("</i>","")
    code = re.sub("<font.*?>", "", code)
    code = code.replace("</font>","")
    code = re.sub("\s+"," ", code)
    return code

def searchWord(word):
    req = Request("http://tdkterim.gov.tr/bts/arama/?kategori=verilst&kelime=%s&ayn=tam" % word)
    req.add_header('Referer', 'http://tdkterim.gov.tr/bts/arama/index.php')
    result = urlopen(req).read()

    resultTable = soup(result).findAll('p',attrs={'class' : 'thomicb'})

    if not len(resultTable):
        print("%s sözlükte bulunamadı." % word)
        return

    for index in range(len(resultTable)):
        result = re.findall("<p class=\"thomicb\">(.*?)</p>", str(resultTable[index]))[0]
        result = tidyHTML(result)
        if result.find("Aşağıdaki sözlerden birini mi aramak istediniz?") >= 0:
            print("%s sözlükte bulunamadı." % word)
            return
        else:
            print("%d. %s" % (index+1, tidyHTML(result)))

if __name__ == "__main__":
    if (len(sys.argv) != 2):
        print("Aramak için bir sözcük girin.")
    else:
        searchWord(sys.argv[1])
