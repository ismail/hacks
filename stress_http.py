#!/usr/bin/env python3
# -*- coding: utf-8

from urllib.request import urlopen
from urllib.error import URLError
from threading import Thread
import sys

MAX_CONNECTIONS=int(sys.argv[2])
HOST=sys.argv[1]

def do_it(index):
    try:
        req = urlopen(HOST)
        req.readlines()
        req.close()
    except:
        print("Request %d failed" % index)

if __name__ == "__main__":
    threads = []
    for i in range(0, MAX_CONNECTIONS):
        t = Thread(target=do_it, args=(i,))
        threads.append(t)

    [t.start() for t in threads]
    [t.join() for t in threads]
