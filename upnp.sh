#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

device=eth0
internal_port=22
external_port=2222

ipaddress=`ip address show dev $device | awk '/inet/ {sub(/\/.*$/,"",$2); print $2}'|head -1`
upnp_string=`upnpc -l | awk '/TCP  2222/ {print $3}'`

if [ x$upnp_string != x"$external_port->$ipaddress:$internal_port" ]; then
    upnpc -d $external_port TCP &> /dev/null
    upnpc -a $ipaddress $internal_port $external_port TCP &> /dev/null
fi
