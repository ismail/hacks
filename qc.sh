#!/usr/bin/python

import sys

if len(sys.argv) > 1:
    code = compile("from math import *\nresult = %s" % sys.argv[1], '<string>', 'exec')
    ns = {}
    exec code in ns
    print(ns["result"])
else:
    print("No arguments given.")

