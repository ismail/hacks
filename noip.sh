#!/bin/sh

username=ismail@donmez.ws
password=
host=.ddns.net
ip=`curl -s whatismyip.akamai.com`

curl -s -u $username:$password "http://dynupdate.no-ip.com/nic/update?hostname=$host&myip=$ip" > /dev/null
