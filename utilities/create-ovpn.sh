#!/bin/bash

cat<<EOF
client
dev tun
proto udp
remote i10z.com 1194
resolv-retry infinite
nobind
persist-key
persist-tun

ns-cert-type server
auth SHA512
cipher AES-256-CBC
tls-cipher TLS-DHE-RSA-WITH-AES-256-CBC-SHA

comp-lzo
verb 3

EOF

cat<<EOF
<ca>
$(cat ca.crt)
</ca>

<cert>
$(sed -n '/-----BEGIN CERTIFICATE-----/,$p' $1.crt)
</cert>

<key>
$(cat $1.key)
</key>

key-direction 1
<tls-auth>
$(grep -vE ^# ta.key)
</tls-auth>
EOF

