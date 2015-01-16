#!/bin/sh

username=ismail@donmez.ws
password=
noip_host=donmez.ddns.net
he_host=sutoglan.i10z.com
ip=$(curl -s whatismyip.akamai.com)

curl -s -u $username:"$password" "http://dynupdate.no-ip.com/nic/update?hostname=$noip_host&myip=$ip" > /dev/null
curl "http://dyn.dns.he.net/nic/update?hostname=$he_host&password="$password"&myip=$ip" > /dev/null
