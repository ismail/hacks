#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email import encoders

import os
import sys
import smtplib

gmail_user = "ismail@i10z.com"
gmail_pwd = open("%s/.gpass" % os.environ["HOME"]).readlines()[0].strip("\r\n")
subject = "convert"
recipient = "donmez@free.kindle.com"


def mail(username, password, to, subject, text, attach):
    msg = MIMEMultipart()

    msg['From'] = username
    msg['To'] = to
    msg['Subject'] = subject

    msg.attach(MIMEText(text))

    part = MIMEBase('application', 'octet-stream')
    part.set_payload(open(attach, 'rb').read())
    encoders.encode_base64(part)
    part.add_header('Content-Disposition',
                    'attachment; filename="%s"' % os.path.basename(attach))
    msg.attach(part)

    mailServer = smtplib.SMTP("smtp.gmail.com", 587)
    mailServer.ehlo()
    mailServer.starttls()
    mailServer.ehlo()
    mailServer.login(username, password)
    mailServer.sendmail(username, to, msg.as_string())
    mailServer.quit()


if __name__ == "__main__":

    try:
        mail(gmail_user, gmail_pwd, recipient, subject, "", sys.argv[1])
    except IndexError:
        print("Usage: %s filename" % sys.argv[0])
