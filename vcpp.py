#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
from urllib import parse, request
import sys


def compileCode(code):
    req = request.Request("http://webcompiler.cloudapp.net/")
    data = request.urlopen(req)
    soup = BeautifulSoup(data)
    eventValidation = soup.find('input', attrs={'id': '__EVENTVALIDATION'}).get('value')
    viewState = soup.find('input', attrs={'id': '__VIEWSTATE'}).get('value')

    params = parse.urlencode({
        "__VIEWSTATE": viewState,
        "__EVENTVALIDATION": eventValidation,
        "Button1": "►",
        "execute": "on",
        "TextBoxArgument": "",
        "TextBoxOutputLatest": "",
        "TextBoxSource": code,
    })

    headers = {
        "Content-type": "application/x-www-form-urlencoded",
        "Accept": "text/html",
        "Origin": "http://webcompiler.cloudapp.net",
        "Referer": "http://webcompiler.cloudapp.net/"
    }

    req = request.Request("http://webcompiler.cloudapp.net/",
                          params.encode("utf-8"),
                          headers)
    data = request.urlopen(req).read()
    soup = BeautifulSoup(data)
    result = soup.find('textarea', attrs={'id': 'TextBoxOutputLatest'})
    print(result.contents[0])


if __name__ == "__main__":
    data = "".join(sys.stdin.readlines())
    compileCode(data.encode("utf-8"))
