#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys

if len(sys.argv) > 1:
    input_string = " ".join(sys.argv[1:])
    code = compile("from __future__ import division\nfrom math import *\nresult = %s" % input_string, '<string>', 'exec')
    ns = {}
    exec code in ns
    print(ns["result"])
else:
    print("No arguments given.")

