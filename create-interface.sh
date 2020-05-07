#!/bin/bash

iface_name=wg
server_ip_sub=10.50.0.1/16

tdir=$(mktemp -td wg-add-interface-XXXXXXXX)
cd $tdir

wg genkey | tee $tdir/prv | wg pubkey > $tdir/pub

prv=$(cat $tdir/prv)

cat <<- EOF > /etc/wireguard/$iface_name.conf
[Interface]
PrivateKey = $prv
Address = $server_ip_sub
ListenPort = 51820

PostUp  = /etc/scripts/config-proxy.sh up
PreDown = /etc/scripts/config-proxy.sh down
EOF


# clean up the temp dirs
rm -rf $tdir
