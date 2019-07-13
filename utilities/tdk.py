#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# 2019 İsmail Dönmez <ismail@i10z.com>

from urllib.parse import urlencode
from urllib.request import urlopen, Request
from urllib.error import HTTPError
import sys
import json

URL = "http://sozluk.gov.tr/gts"

def searchWord(word):
    try:
        parameters = {'ara': word}
        url = '{}?{}'.format(URL, urlencode(parameters))
        results = json.loads(urlopen(url).read())
    except HTTPError as e:
        print(e)
        sys.exit(-1)

    if "error" in results:
        print(results["error"])
        return

    for result in results:
        for meaning in result["anlamlarListe"]:
            print(f'• {meaning["anlam"]}')
            try:
                for example in meaning["orneklerListe"]:
                    print(f"\t→ {example['ornek']}", end='')
                    if example['yazar_id'] != '0':
                        print(f" — {example['yazar'][0]['tam_adi']}")
                    else:
                        print()
            except KeyError:
                pass

if __name__ == "__main__":
    if (len(sys.argv) != 2):
        print("Aramak için bir sözcük girin.")
    else:
        searchWord(sys.argv[1])
