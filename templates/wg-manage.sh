#!/bin/bash

pub_iface=#(pub_iface)
wg_iface=#(wg_iface)
subnet_prefix=#(subnet_prefix)
starting_ip=#(starting_ip)

prev_pwd=`pwd`
li_file=/etc/wireguard/last-ip
wg_conf_file=/etc/wireguard/$wg_iface.conf
tdir=$(mktemp -td wg-manage-XXXXXXXX)
cd $tdir

reset_ip () {
    sudo rm $li_file 2> /dev/null
    echo "Reset Successful."
}

die () {
    echo $1
    exit -1
}

add_peer () {

    # test if iface is up
    ip link show dev $wg_iface 2>/dev/null >/dev/null || die "Interface is not up!"

    name=$1
    device=$2
    ostype=$3

    pub=$(wg genkey | tee prv | wg pubkey)
    prv=$(cat prv)

    last_ip=`sudo cat $li_file 2> /dev/null`
    if [[ -z $last_ip ]]; then
        last_ip=$starting_ip
    fi
    new_ip_frag=$(($last_ip+1))
    new_ip=$subnet_prefix.$new_ip_frag

    cat <<- EOF > new_conf
	# $name - $device
	[Peer]
	PublicKey = $pub
	AllowedIPs = $new_ip/32
	
	EOF

    echo "Adding Peer to WG Interface..."
    sudo wg addconf $wg_iface new_conf

    echo -e "New Peer Config Looks Like Follows:\n"
    cat new_conf

    echo "Recording Last IP..."
    echo $new_ip_frag | sudo tee $li_file > /dev/null
    sudo bash -c "cat new_conf >> $wg_conf_file"

    server_pub=`sudo wg show $wg_iface public-key`
    server_ip=`sudo ip addr show dev $pub_iface | sed -nr 's/^\s*inet\s+([0-9.]+).*$/\1/p'`
    server_port=`sudo wg show $wg_iface listen-port`

    if [[ -z $ostype || $ostype != 'linux' ]]; then
	extra_iface_line="BlockDNS = true"
	extra_peer_line="AllowMulticast = false"
    fi

    user_conf_file=$name-$device.conf

    cat <<- EOF > $prev_pwd/$user_conf_file

	# This config file is known as "$user_conf_file" on the server

	[Interface]
	PrivateKey = $prv
	Address = $new_ip/16
	DNS = 1.1.1.1
	# MTU = 1323
	$extra_iface_line

	[Peer]
	PublicKey = $server_pub
	Endpoint = $server_ip:$server_port
	AllowedIPs = 0.0.0.0/0
	PersistentKeepalive = 25
	$extra_peer_line

	EOF

    echo "Done: File Created: $user_conf_file"

}

show_online () {
    local the_ips
    #the_ips=$(sudo wg | grep -A 2 -B 4 handshake | grep -E 'allowed ips: ' | sed -nr 's|.*10\.20\.1\.([0-9]+)/32|\1|p' | paste -sd '|')
    the_ips=$(sudo wg | grep -A 2 -B 4 'handshake' | grep -A 2 -B 4 -E ':( [1|2] minutes?,)? [0-9]+ seconds ago' | sed -nr 's|.*10\.20\.1\.([0-9]+)/32|\1|p' | paste -sd '|')
    sudo cat $wg_conf_file | grep -E "10\.20\.1\.($the_ips)\/" -B 4 | grep '#'
}

help () {

    echo -e "\nUsage:\n\twg-manage add_peer <user> <device> [linux|windows]\n"
    echo -e "\nUsage:\n\twg-manage show_online\n"
    
}

if [[ -z $1 ]]; then
    echo "No command specified!"
    help
    exit 1
fi

# invoke the desired function
$@

# clean up the temp dirs
rm -rf $tdir
