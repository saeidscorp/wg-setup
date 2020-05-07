#!/bin/bash

if [[ $1 == "up" ]]; then

    iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j LOG --log-prefix='[netfilter: "BitTorrent"] '
    iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
    iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j LOG --log-prefix='[netfilter: "BitTorrent protocol"] '
    iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
    iptables -A FORWARD -m string --algo bm --string "peer_id=" -j LOG --log-prefix='[netfilter: "peer_id="] '
    iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
    iptables -A FORWARD -m string --algo bm --string ".torrent" -j LOG --log-prefix='[netfilter: ".torrent"] '
    iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
    iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j LOG --log-prefix='[netfilter: "announce.php"] '
    iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
    iptables -A FORWARD -m string --algo bm --string "torrent" -j LOG --log-prefix='[netfilter: "torrent"] '
    iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
    iptables -A FORWARD -m string --algo bm --string "announce" -j LOG --log-prefix='[netfilter: "announce"] '
    iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
    iptables -A FORWARD -m string --algo bm --string "info_hash" -j LOG --log-prefix='[netfilter: "infohash"] '
    iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP

    iptables -A FORWARD -p tcp -m ipp2p --bit -j LOG --log-prefix='[netfilter: "ipp2p[tcp]"] '
    iptables -A FORWARD -p tcp -m ipp2p --bit -j DROP
    iptables -A FORWARD -p udp -m ipp2p --bit -j LOG --log-prefix='[netfilter: "ipp2p[udp]"] '
    iptables -A FORWARD -p udp -m ipp2p --bit -j DROP

elif [[ $1 == down ]]; then

    iptables -D FORWARD -m string --algo bm --string "BitTorrent" -j LOG --log-prefix='[netfilter: "BitTorrent"] '
    iptables -D FORWARD -m string --algo bm --string "BitTorrent" -j DROP
    iptables -D FORWARD -m string --algo bm --string "BitTorrent protocol" -j LOG --log-prefix='[netfilter: "BitTorrent protocol"] '
    iptables -D FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
    iptables -D FORWARD -m string --algo bm --string "peer_id=" -j LOG --log-prefix='[netfilter: "peer_id="] '
    iptables -D FORWARD -m string --algo bm --string "peer_id=" -j DROP
    iptables -D FORWARD -m string --algo bm --string ".torrent" -j LOG --log-prefix='[netfilter: ".torrent"] '
    iptables -D FORWARD -m string --algo bm --string ".torrent" -j DROP
    iptables -D FORWARD -m string --algo bm --string "announce.php?passkey=" -j LOG --log-prefix='[netfilter: "announce.php"] '
    iptables -D FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
    iptables -D FORWARD -m string --algo bm --string "torrent" -j LOG --log-prefix='[netfilter: "torrent"] '
    iptables -D FORWARD -m string --algo bm --string "torrent" -j DROP
    iptables -D FORWARD -m string --algo bm --string "announce" -j LOG --log-prefix='[netfilter: "announce"] '
    iptables -D FORWARD -m string --algo bm --string "announce" -j DROP
    iptables -D FORWARD -m string --algo bm --string "info_hash" -j LOG --log-prefix='[netfilter: "infohash"] '
    iptables -D FORWARD -m string --algo bm --string "info_hash" -j DROP

    iptables -D FORWARD -p tcp -m ipp2p --bit -j LOG --log-prefix='[netfilter: "ipp2p[tcp]"] '
    iptables -D FORWARD -p tcp -m ipp2p --bit -j DROP
    iptables -D FORWARD -p udp -m ipp2p --bit -j LOG --log-prefix='[netfilter: "ipp2p[udp]"] '
    iptables -D FORWARD -p udp -m ipp2p --bit -j DROP

fi
