#!/bin/bash
set -euo pipefail

DAYS_TO_EXPIRE=14
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

echo -n "Installing certificates... "

(
cd ~/.lego/certificates
for i in i10z.com donmez.uk donmez.ws; do
    echo -n "$i "
    cp $i.key $i.crt /etc/nginx/ssl/$i
done
)

echo
echo "Done. Please restart nginx."
