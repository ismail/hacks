#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup as soup
from rich.console import Console
from rich.table import Table
import urllib.error
from urllib.parse import urlencode, quote
from urllib.request import urlopen, Request
import sys

url = "https://www.verbformen.de/konjugation/?w="
filtered_tenses = ["Präsens", "Präteritum", "Perfekt"]


def findKonjugation(string):
    req = Request(
        f"{url}{quote(string)}",
        data=None,
        headers={
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.109 Safari/537.36"
        },
    )
    req.add_header("Referer", "https://www.verbformen.de/konjugation/")

    try:
        s = soup(urlopen(req).read(), "lxml")
    except urllib.error.HTTPError as e:
        print("Error while searching: %s" % e)
        sys.exit(1)

    result = {}
    for tense in filtered_tenses:
        result[tense] = []

    for table in s.findAll("div", attrs={"class": "rAufZu"}):
        for column in table.findAll("div", attrs={"class": "vTbl"}):
            header = column.find("h2") or column.find("h3")
            tense = header.text
            if (tense in filtered_tenses) and not result[tense]:
                for tr in column.findAll("tr"):
                    result[tense].append(tr.text.strip())

    if result["Präsens"]:
        table = Table()

        for tense in filtered_tenses:
            table.add_column(tense, justify="left", style="magenta", no_wrap=True)

        for i in range(0, len(result["Präsens"])):
            row = []
            for tense in filtered_tenses:
                row.append(result[tense][i])
            table.add_row(*row)

        console = Console()
        console.print(table)
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
