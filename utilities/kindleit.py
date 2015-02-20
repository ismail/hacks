#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from mailer import mail
import os
import subprocess
import sys

gmail_user = "ismail@donmez.ws"
gmail_pwd =  open("%s/.gpass" % os.environ["HOME"] ).readlines()[0].strip("\r\n")
subject = "convert"
recipient = "donmez@free.kindle.com"

if __name__ == "__main__":

    try:
        mail(gmail_user,
             gmail_pwd,
             recipient,
             subject,
             "",
             sys.argv[1])
    except IndexError:
        print("Usage: %s filename" % sys.argv[0])
