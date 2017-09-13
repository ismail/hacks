#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from urllib.parse import urlencode, quote
from urllib.request import urlopen, Request
from bs4 import BeautifulSoup as soup
import sys

url = "https://www.verbformen.de/konjugation/?w="
filtered_tenses = ["Perfekt", "Präteritum"]

def findKonjugation(string):
    req = Request(f"{url}{quote(string)}")
    s=soup(urlopen(req).read(), "lxml")
    result = {}

    for table in s.findAll('section', attrs={'class': 'rBox rBoxWht'}):
        div_id = table.find('div', attrs={'id': 'indikativ'})

        if div_id is not None:
            for column in table.findAll('div', attrs={'class': 'vTbl'}):
                tense = column.find('h3').text
                if tense in filtered_tenses:
                    result[tense] = []
                    for tr in column.findAll('tr'):
                        result[tense].append(tr.text)
            break

    if len(result) >= 2:
        for tense in filtered_tenses:
            print(f"\n\033[1m{tense}\033[0m")
            print("\n".join(result[tense]))
            print("")
        print(f"Originalquelle: {url}{quote(string)}\n")
    else:
        print("No result found.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        try:
            while True:
                words = input("Was möchten Sie konjugieren? > ")
                findKonjugation(words)
        except (EOFError, KeyboardInterrupt):
            print("")
            sys.exit(0)
    else:
        findKonjugation(" ".join(sys.argv[1:]))
