#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Placed under public domain.
# 2014 İsmail Dönmez <ismail@donmez.ws>

from bs4 import BeautifulSoup
from urllib import error, parse, request
import sys

url="http://webcompiler.cloudapp.net/"

def compileCode(code, opts=None):
    req = request.Request(url)

    if opts is None:
        opts = ""

    try:
        data = request.urlopen(req)
    except error.HTTPError as e:
        print("Error while trying to connect %s: %s" % (url, e))
        sys.exit(-1)

    soup = BeautifulSoup(data, "lxml")
    eventValidation = soup.find('input', attrs={'id': '__EVENTVALIDATION'}).get('value')
    viewState = soup.find('input', attrs={'id': '__VIEWSTATE'}).get('value')

    params = parse.urlencode({
        "__VIEWSTATE": viewState,
        "__EVENTVALIDATION": eventValidation,
        "TextBoxCompilerArgs": opts,
        "Button1": "►",
        "execute": "on",
        "TextBoxArgument": "",
        "TextBoxOutputLatest": "",
        "TextBoxSource": code,
    })

    headers = {
        "Accept": "text/html",
        "Content-type": "application/x-www-form-urlencoded",
        "Origin": "http://webcompiler.cloudapp.net",
        "Referer": "http://webcompiler.cloudapp.net/",
        "User-Agent": "Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko"
    }

    req = request.Request("http://webcompiler.cloudapp.net/",
                          params.encode("utf-8"),
                          headers)

    try:
        data = request.urlopen(req).read()
    except error.HTTPError as e:
        print("Error while trying to connect %s: %s" % (url, e))
        sys.exit(-1)

    soup = BeautifulSoup(data, "lxml")
    result = soup.find('textarea', attrs={'id': 'TextBoxOutputLatest'})
    print(result.contents[0])


if __name__ == "__main__":
    opts = None
    if len(sys.argv) >= 2:
        opts = " ".join(sys.argv[1:])

    data = "".join(sys.stdin.readlines())
    compileCode(data.encode("utf-8"), opts)
