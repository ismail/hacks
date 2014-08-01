#!/usr/bin/env python3
# -*- coding: utf-8

from urllib.request import urlopen
from urllib.error import URLError
from threading import Thread
import sys

MAX_CONNECTIONS=int(sys.argv[2])
HOST=sys.argv[1]

failures = 0

def do_it(index):
    global failures

    try:
        req = urlopen(HOST)
        req.readlines()
        req.close()
    except:
        failures += 1

if __name__ == "__main__":
    threads = []
    for i in range(0, MAX_CONNECTIONS):
        t = Thread(target=do_it, args=(i,))
        threads.append(t)

    [t.start() for t in threads]
    [t.join() for t in threads]

    if failures:
        print("%d%% of requests failed" % (float(failures)/MAX_CONNECTIONS*100))
    else:
        print("All requests succesfull!")

