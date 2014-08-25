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
cipher AES-256-CBC
comp-lzo
verb 3

EOF

cat<<EOF
<ca>
`cat ca.crt`
</ca>

<cert>
`cat $1.crt|grep -A 200 -- '-----BEGIN CERTIFICATE-----'`
</cert>

<key>
`cat $1.key`
</key>

key-direction 1
<tls-auth>
`cat ta.key|grep -vE ^#`
</tls-auth>
EOF

