#!/bin/bash

## CONFIG
#pub_iface=$([[ -f /etc/wireguard/pub-iface ]] && echo /etc/wireguard/pub-iface || echo eth0)
pub_iface=eth0
wg_port=51820

mode=$1
ss=$2

[[ $ss == "" ]] && ss=no
[[ $ss == "ss" ]] && ss=yes

if [[ $mode == 'up' ]]; then

    # spin up

    /etc/scripts/block-torrent.sh up

    iptables -t nat -A POSTROUTING -o $pub_iface -j MASQUERADE
    iptables -t nat -A PREROUTING -i $pub_iface \! -f -p udp \! --dport $wg_port -m length --length 176 -m u32 --u32 "0 >> 22 & 0x3C @ 8 = 0x1000000" -j DNAT --to-destination :$wg_port
    sysctl -w net.ipv4.ip_forward=1

    if [[ $ss == 'yes' ]]; then
        ss-server -s 0.0.0.0 -p 443 -k '&9GK^hP!0y@QmsP$XeFQ' -m aes-128-gcm -U --plugin v2ray-plugin --plugin-opts "server" --reuse-port -t 120 &
        echo $! > /run/ss-server.pid
    fi

else                    
    # tear down

    /etc/scripts/block-torrent.sh down

    iptables -t nat -D POSTROUTING -o $pub_iface -j MASQUERADE || true
    iptables -t nat -D PREROUTING -i $pub_iface \! -f -p udp \! --dport $wg_port -m length --length 176 -m u32 --u32 "0 >> 22 & 0x3C @ 8 = 0x1000000" -j DNAT --to-destination :$wg_port || true

    if [[ $ss == 'yes' ]]; then
        kill $(cat /run/ss-server.pid) || true
        rm /run/ss-server.pid || true
    fi

fi
