#!/bin/sh

username=
password=
host=
ip=`curl -s whatismyip.akamai.com`

curl -u $username:$password "http://dynupdate.no-ip.com/nic/update?hostname=$host&myip=$ip"
