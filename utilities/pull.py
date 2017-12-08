#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Laziness is virtue
# Copyright 2007-2015 İsmail Dönmez

import sys
import os

vcDict = \
    {
        ".gclient": "gclient sync",
        ".git/refs/remotes/git-svn": "git svn rebase",
        ".git": "git pull",
        ".svn": "svn up",
        ".hg": "hg pull -u -v",
        "CVS": "cvs -q -z3 update -dPA",
        ".bzr": "bzr pull",
        ".osc": "osc up",
    }

def log(string, isTTY=sys.stdout.isatty()):
    if isTTY:
        print("Updating \033[0;33m%s\033[0m" % string)
    else:
        print(string)

def doPull(directory):
    currentDirectory = os.getcwd()
    os.chdir(directory)

    for path in vcDict.keys():
        if os.path.exists(path):
            log(os.path.abspath(directory))
            sys.stdout.flush()
            os.system(vcDict[path])
            break

    os.chdir(currentDirectory)

if __name__ == "__main__":
    arglength = len(sys.argv)

    if arglength > 1:
        if sys.argv[1] == "--force":
            if arglength == 3:
                os.chdir(sys.argv[2])

            root = os.path.abspath(".")
            paths = sorted(set([os.path.join(root, x[0]) for x in os.walk(root)]))
            for path in paths:
                doPull(path)

            sys.exit(0)

        i = 0
        while i < arglength - 1:
            path = os.path.expanduser(sys.argv[i+1])
            if os.path.isdir(path):
                doPull(path)
            i += 1
    else:
        doPull(".")
