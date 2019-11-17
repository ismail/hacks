#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import urllib.error
from urllib.parse import urlencode, quote
from urllib.request import urlopen, Request
from bs4 import BeautifulSoup as soup
import sys

url = "https://www.verbformen.de/konjugation/?w="
filtered_tenses = [
    "Präsens", "Präteritum", "Perfekt", "Imperativ", "Konjunktiv I",
    "Konjunktiv II", "Plusquam."
]


def findKonjugation(string):
    req = Request(
        f"{url}{quote(string)}",
        data=None,
        headers={
            'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36'
        })
    req.add_header('Referer', 'https://www.verbformen.de/konjugation/')

    try:
        s = soup(urlopen(req).read(), "lxml")
    except urllib.error.HTTPError as e:
        print("Error while searching: %s" % e)
        sys.exit(1)

    result = {}
    for tense in filtered_tenses:
        result[tense] = []

    for table in s.findAll('div', attrs={'class': 'rAufZu'}):
        for column in table.findAll('div', attrs={'class': 'vTbl'}):
            tense = column.find('h3').text
            if (tense in filtered_tenses) and not result[tense]:
                for tr in column.findAll('tr'):
                    result[tense].append(tr.text.strip())

    if result["Präsens"]:
        for tense in filtered_tenses:
            print(f"\033[1m{tense}\033[0m")
            print(" / ".join(result[tense]))
            print("")
        print(f"Quelle: {url}{quote(string)}\n")
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
