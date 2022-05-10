#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# 2022 İsmail Dönmez <ismail@i10z.com>

from urllib.parse import urlencode
from urllib.request import urlopen, Request
from urllib.error import HTTPError
from textwrap import wrap

import json
import pprint
import sys


URL = "http://sozluk.gov.tr/gts"
debug = 0


def searchWord(words):
    try:
        parameters = {"ara": " ".join(words)}
        url = "{}?{}".format(URL, urlencode(parameters))
        req = Request(
            url,
            headers={
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36"
            },
        )
        results = json.loads(urlopen(req).read())
    except HTTPError as e:
        print(e)
        sys.exit(-1)

    if debug:
        pprint.pprint(results)

    if "error" in results:
        print(results["error"])
        return

    pronunciation = results[0]["telaffuz"]
    other_languages = results[0]["lisan"]
    combinations = results[0]["birlesikler"]
    headline = []

    if pronunciation:
        headline.append(f"({pronunciation})")

    if other_languages:
        # Looks like there is mac-roman encoded stuff inside?!
        # 0x90 0x00EA # LATIN SMALL LETTER E WITH CIRCUMFLEX
        other_languages = other_languages.replace("\x90", "ê")

        headline.append(other_languages)

    if len(headline):
        print(f"{', '.join(headline)}\n")

    index = 0
    sayings = []
    for result in results:
        for meaning in result["anlamlarListe"]:
            index += 1

            try:
                word_type = ", ".join(
                    [x["tam_adi"] for x in meaning["ozelliklerListe"]]
                )
                print(f"{index}. ({word_type}) {meaning['anlam']}")
            except KeyError:
                print(f"{index}. {meaning['anlam']}")

            try:
                for example in meaning["orneklerListe"]:
                    print(f"\t→ {example['ornek']}", end="")
                    if example["yazar_id"] != "0":
                        print(f" — {example['yazar'][0]['tam_adi']}")
                    else:
                        print()
            except KeyError:
                pass

        if "atasozu" in result:
            sayings.extend(result["atasozu"])

    if sayings:
        print("\nAtasözleri:")
        for saying in sayings:
            print(f"• {saying['madde']}")

    if combinations:
        print(f"\nBirleşik Kelimeler:\n")
        for combination in wrap(combinations, 80):
            print(combination)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Aramak için bir sözcük girin.")
    else:
        searchWord(sys.argv[1:])
