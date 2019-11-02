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
debug = 0


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

    pronunciation = results[0]['telaffuz']
    other_languages = results[0]['lisan']
    combinations = results[0]['birlesikler']
    headline = []

    if pronunciation:
        headline.append(f"({pronunciation})")

    if other_languages:
        headline.append(other_languages)

    if len(headline):
        print(f"{', '.join(headline)}\n")

    if debug:
        import pprint
        pprint.pprint(results)

    index = 0
    for result in results:
        for meaning in result['anlamlarListe']:
            index += 1
            print(
                f"{index}. ({meaning['ozelliklerListe'][0]['tam_adi']}) {meaning['anlam']}"
            )
            try:
                for example in meaning['orneklerListe']:
                    print(f"\t→ {example['ornek']}", end='')
                    if example['yazar_id'] != '0':
                        print(f" — {example['yazar'][0]['tam_adi']}")
                    else:
                        print()
            except KeyError:
                pass

        if 'atasozu' in result:
            print("\nAtasözleri:")
            for saying in result['atasozu']:
                print(f"• {saying['madde']}")

    if combinations:
        print(f"\nBirleşik Kelimeler:\n{combinations}")


if __name__ == "__main__":
    if (len(sys.argv) != 2):
        print("Aramak için bir sözcük girin.")
    else:
        searchWord(sys.argv[1])
