#!/bin/sh
set -u

username=ismail@donmez.ws
password=
noip_host=donmez.ddns.net
he_host=sutoglan.i10z.com
ip=$(curl -s whatismyip.akamai.com)

if [ -z $password ]; then
    echo "Password can't be empty."
    exit 0
fi

curl -s -u $username:"$password" "http://dynupdate.no-ip.com/nic/update?hostname=$noip_host&myip=$ip" > /dev/null
curl -s "http://dyn.dns.he.net/nic/update?hostname=$he_host&password="$password"&myip=$ip" > /dev/null
