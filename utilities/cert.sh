#!/bin/bash
set -euo pipefail

DAYS_TO_EXPIRE=7
EMAIL=ismail@i10z.com
KEYTYPE=rsa4096
WEBROOT=/havana

function renew
{
    [[ -z $1 ]] && echo "Please provide a domain" && return

    $(go env GOPATH)/bin/lego --accept-tos \
                              --key-type=$KEYTYPE \
                              --webroot=$WEBROOT \
                              --email=$EMAIL \
                              --domains $1 --domains www.$1 \
                              renew \
                              --days $DAYS_TO_EXPIRE \
                              --must-staple
}

renew donmez.uk
renew donmez.ws
renew i10z.com
