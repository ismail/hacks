#! /usr/bin/env python
# -*- coding: utf-8 -*-

import socket
import sys
from threading import Thread

HOST=sys.argv[0]
PORT=sys.argv[1]
TORTURE_COUNT=250

def send_packet(thread_id):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((HOST, PORT))
    s.send("\0"*1024*1024);
    s.send("Here is your lucky number: %d" % thread_id)
    s.close()

if __name__ == "__main__":
    threads = []
    for i in range(0, TORTURE_COUNT):
        thread = Thread(target = send_packet, args = (i,))
        threads.append(thread)

    [t.start() for t in threads]
    [t.join() for t in threads]
