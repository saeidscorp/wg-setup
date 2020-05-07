#!/bin/bash

if [[ $1 == "up" ]]; then

    iptables -N TORRENT
    
    iptables -A TORRENT -m string --algo bm --string "BitTorrent" -j LOG --log-prefix='[netfilter: "BitTorrent"] '
    iptables -A TORRENT -m string --algo bm --string "BitTorrent" -j DROP
    iptables -A TORRENT -m string --algo bm --string "BitTorrent protocol" -j LOG --log-prefix='[netfilter: "BitTorrent protocol"] '
    iptables -A TORRENT -m string --algo bm --string "BitTorrent protocol" -j DROP
    iptables -A TORRENT -m string --algo bm --string "peer_id=" -j LOG --log-prefix='[netfilter: "peer_id="] '
    iptables -A TORRENT -m string --algo bm --string "peer_id=" -j DROP
    iptables -A TORRENT -m string --algo bm --string ".torrent" -j LOG --log-prefix='[netfilter: ".torrent"] '
    iptables -A TORRENT -m string --algo bm --string ".torrent" -j DROP
    iptables -A TORRENT -m string --algo bm --string "announce.php?passkey=" -j LOG --log-prefix='[netfilter: "announce.php"] '
    iptables -A TORRENT -m string --algo bm --string "announce.php?passkey=" -j DROP
    iptables -A TORRENT -m string --algo bm --string "torrent" -j LOG --log-prefix='[netfilter: "torrent"] '
    iptables -A TORRENT -m string --algo bm --string "torrent" -j DROP
    iptables -A TORRENT -m string --algo bm --string "announce" -j LOG --log-prefix='[netfilter: "announce"] '
    iptables -A TORRENT -m string --algo bm --string "announce" -j DROP
    iptables -A TORRENT -m string --algo bm --string "info_hash" -j LOG --log-prefix='[netfilter: "infohash"] '
    iptables -A TORRENT -m string --algo bm --string "info_hash" -j DROP

    iptables -A TORRENT -p tcp -m ipp2p --bit -j LOG --log-prefix='[netfilter: "ipp2p[tcp]"] '
    iptables -A TORRENT -p tcp -m ipp2p --bit -j DROP
    iptables -A TORRENT -p udp -m ipp2p --bit -j LOG --log-prefix='[netfilter: "ipp2p[udp]"] '
    iptables -A TORRENT -p udp -m ipp2p --bit -j DROP
    
    iptables -A FORWARD -j TORRENT

elif [[ $1 == down ]]; then

    iptables -D FORWARD -j TORRENT
    iptables -F TORRENT
    iptables -X TORRENT

fi
