#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Laziness is virtue
# Copyright 2007-2012 İsmail Dönmez <ismail@namtrac.org>
# Licensed under public domain

import sys
import os
from collections import OrderedDict

vcDict = OrderedDict([
    (".gclient", "gclient sync"),
    (".git/refs/remotes/git-svn" , "git svn rebase"),
    (".git" , "git pull"),
    (".svn" , "svn up"),
    (".hg"  , "hg pull -u -v"),
    ("CVS"  , "cvs -q -z3 update -dPA"),
    (".bzr" , "bzr pull"),
    (".osc" , "osc up"),
    ])

def doPull(directory):
    currentDirectory = os.getcwd()
    os.chdir(directory)

    for path in vcDict.keys():
        if os.path.exists(path):
            print "\033[1;31mUpdating %s\033[0m" % directory
            os.system(vcDict[path])
            break

    os.chdir(currentDirectory)

if __name__ == "__main__":
    arglength = len(sys.argv)

    if arglength > 1:
        i = 0
        while i < arglength - 1:
            path = sys.argv[i+1]
            if os.path.isdir(path):
                doPull(sys.argv[i+1])
            i += 1
    else:
        doPull(".")
