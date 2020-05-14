#!/bin/bash

iface_name=$1
wg_port=$2
wg_address=$3
block_torrent=$4

tdir=$(mktemp -td wg-create-interface-XXXXXXXX)
cd $tdir

wg genkey | tee $tdir/prv | wg pubkey > $tdir/pub

prv=$(cat $tdir/prv)

cat <<- EOF > /etc/wireguard/$iface_name.conf
[Interface]
PrivateKey = $prv
Address = $wg_address
ListenPort = $wg_port

PostUp  = /etc/scripts/config-proxy.sh up no $block_torrent
PreDown = /etc/scripts/config-proxy.sh down no $block_torrent


EOF


# clean up the temp dirs
rm -rf $tdir
