#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Laziness is virtue
# Copyright 2007-2015 İsmail Dönmez

import sys
import os
import subprocess
from collections import OrderedDict

vcDict = OrderedDict([
    (".gclient", "gclient sync"),
    (".git/refs/remotes/git-svn", "git svn rebase"),
    (".git", "git pull"),
    (".svn", "svn up"),
    (".hg", "hg pull -u -v"),
    ("CVS", "cvs -q -z3 update -dPA"),
    (".bzr", "bzr pull"),
    (".osc", "osc up"),
])

def log(string):
    if sys.stdout.isatty():
        print(f"Updating \033[0;33m{string}\033[0m")
    else:
        print(string)

def doPull(directory):
    currentDirectory = os.getcwd()
    os.chdir(directory)

    for path, command in vcDict.items():
        if os.path.exists(path):
            log(os.path.abspath("."))
            sys.stdout.flush()
            subprocess.run(command, shell=True, check=True)
            break

    os.chdir(currentDirectory)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1] in ["-r", "--recursive"]:
            start_dir = "."
            if len(sys.argv) == 3:
                start_dir = sys.argv[2]
            
            os.chdir(start_dir)
            root = os.path.abspath(".")
            paths = sorted(list(set([x[0] for x in os.walk(root)])))
            for path in paths:
                doPull(path)

            sys.exit(0)

        for arg in sys.argv[1:]:
            path = os.path.expanduser(arg)
            if os.path.isdir(path):
                doPull(path)
    else:
        doPull(".")