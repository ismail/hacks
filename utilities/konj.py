#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from urllib.parse import urlencode, quote
from urllib.request import urlopen, Request
from bs4 import BeautifulSoup as soup
import sys

filtered_tenses = ["Perfekt", "Präteritum"]

def findKonjugation(string):
    req = Request("https://www.verbformen.de/konjugation/?w=%s" % quote(string) )
    s=soup(urlopen(req).read(), "lxml")

    for table in s.findAll('section', attrs={'class': 'rBox rBoxWht'}):
        div_id = table.find('div', attrs={'id': 'indikativ'})

        if div_id is not None:
            for column in table.findAll('div', attrs={'class': 'vTbl'}):
                tense = column.find('h3').text
                if tense in filtered_tenses:
                    print(f"-> {tense}")
                    for tr in column.findAll('tr'):
                        print(tr.text)
                    print("")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        try:
            while True:
                words = input("Was möchten Sie konjugieren? > ")
                findKonjugation(words)
        except KeyboardInterrupt:
            print("")
            sys.exit(0)
    else:
        findKonjugation(" ".join(sys.argv[1:]))
