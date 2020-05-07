#!/bin/bash

# ANSI colors for aesthetics

green=`tput setaf 10`
lush_green=`tput setaf 2`
normal=`tput sgr0`

# utility functions

function die () {
    echo $1 >&2
    exit 1
}

function prompt () {
    var=$1
    ptext=$2
    default=$3
    
    [[ ! -z $default ]] && dtext=" [default: $default]: " || dtext=": "
    
    while true; do
    
        read -p "${green}${ptext}${dtext}${normal}" uinput
        
        [[ ! -z $uinput ]] && break
        [[ ! -z $default ]] && uinput=$default && break
        
        echo -e "Invalid input\n"
    done
    
    echo -e "Selected value: ${uinput}\n"
    eval $var=$uinput
}



# gather all inputs first:

pub_iface=$(ip route | sed -nr 's/^default.* dev (\w+).*/\1/p')

echo -e "(Press enter -- leave empty -- to use default value)\n"

prompt pub_iface "Please enter the public interface with internet connectivity (if it differs from the auto-detected)" "$pub_iface"
prompt wg_iface "Please enter the desired name for WireGuard interface" "wg"
prompt wg_port "Please enter the desired port number for WireGuard to listen on" "51820"
prompt server_address "Please enter CIDR notation (including subnet range) for server address" "10.1.0.1/16"
prompt first_peer_address "Please enter the first peer's ip address" "10.1.1.1"
prompt block_torrent "Block torrent access via iptables rules (not sufficient, but better than nothing if need be) - \"yes\" or \"no\"" "yes"

subnet_prefix=$(echo "${first_peer_address}" | sed -nr 's/^(([0-9]+\.){3}).*$/\1/p')
subnet_prefix=${subnet_prefix:0:-1}

starting_ip=$(echo "${first_peer_address}" | sed -nr 's/^.*\.([0-9]+)\/.*$/\1/p')

# install packages:

sudo apt update || die "apt update failed"
sudo apt -y upgrade || die "apt upgrade failed"
(sudo apt-add-repository -y ppa:wireguard/wireguard && sudo apt update) || echo "Failed to add WireGuard repository" >&2
sudo apt -y install wireguard || die "Installation of WireGuard failed"

if [[ $block_torrent == "yes" ]]; then
    sudo apt -y install xtables-addons-common || echo "Couldn't install ipp2p support module (for torrent blocking)" >&2
fi


# install templated scripts into place:

sudo mkdir /etc/scripts
sudo cp templates/config-proxy.sh /etc/scripts
sudo cp templates/block-torrent.sh /etc/scripts

sed -ri "s/#\(pub_iface\)/${pub_iface}/" /etc/scripts/config-proxy.sh
sed -ri "s/#\(wg_port\)/${wg_port}/" /etc/scripts/config-proxy.sh


sudo cp templates/wg-manage.sh /usr/local/bin
sudo ln -s /usr/local/bin/wg-manage.sh /usr/local/bin/wg-manage

sed -ri "s/#\(pub_iface\)/${pub_iface}/p" /usr/local/bin/wg-manage.sh
sed -ri "s/#\(wg_iface\)/${wg_iface}/p" /usr/local/bin/wg-manage.sh
sed -ri "s/#\(subnet_prefix\)/${subnet_prefix}/p" /usr/local/bin/wg-manage.sh
sed -ri "s/#\(starting_ip\)/${starting_ip}/p" /usr/local/bin/wg-manage.sh


# create the interface first:

./create-interface.sh $wg_iface $wg_port $server_address $block_torrent

# then use it as a service (so we don't compromize the consistency of the system before successful tunnel configuration)

sudo cp templates/wireguard.service /etc/systemd/system
sed -ri "s/#\(wg_iface\)/${wg_iface}/p" /etc/systemd/system/wireguard.service

sudo systemctl daemon-reload
sudo systemctl start wireguard

echo -e "${lush_green}All set, enjoy :)\n{$normal}"
