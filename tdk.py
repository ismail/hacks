#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Placed under public domain.
# 2006-2013 İsmail Dönmez <ismail@donmez.ws>

from urllib.parse import quote
from urllib.request import urlopen, Request
import re
import sys

try:
    from bs4 import BeautifulSoup as soup
except ImportError:
    print("Sisteminize öncelikle BeautifulSoup4 kurun.")
    sys.exit(1)

def tidyHTML(code, isResult=None):
    if isResult is None:
        isResult = True

    if isResult:
        code = code.replace("&nbsp;"," ")
        code = code.replace("<br>","")
        code = code.replace("<br />","")
        code = code.replace("<b>","")
        code = code.replace("</b>","")
        code = code.replace("<i>","")
        code = code.replace("</i>","")
        code = code.replace("&lt; ", "")
        code = code.replace("</font>","")
        code = re.sub("<font.*?>", "", code)
        code = re.sub("\s+"," ", code)
        code = code.replace('\u0093','')
        code = code.replace('\u0094','')
    else:
        code = code.replace('<span class="comics">', "")
        code = code.replace("</span>", "")

    return code

def searchWord(word):
    req = Request("http://tdkterim.gov.tr/bts/arama/?kategori=verilst&kelime=%s&ayn=tam" % quote(word, encoding="iso8859-9"))
    req.add_header('Referer', 'http://tdkterim.gov.tr/bts/arama/index.php')
    result = urlopen(req).read()

    resultTable = soup(result).findAll('p',attrs={'class' : 'thomicb'})
    refTable = soup(result).findAll('span',attrs={'class' : 'comics'})

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
            reference = tidyHTML(str(refTable[index]), isResult=False)
            print("%d. %s" % (index+1, result))
            print("(Referans: %s)\n" % reference)

if __name__ == "__main__":
    if (len(sys.argv) != 2):
        print("Aramak için bir sözcük girin.")
    else:
        searchWord(sys.argv[1])
