#!/bin/bash

. param
. functions

if [ $# -ne 1 ]; then
	echo "Veuillez entrer qu'un seul nom de machine"
else
	if [ $(exist $MACHINE_LISTE $1) -eq 1 ]; then
		echo "Nom de machine incorrect"
	else
		ip=$(grep $1 $MACHINE_LISTE | cut -d ' ' -f 1)
		echo $ip
		ifconfig $IF $ip
	

	net_file=/etc/netplan/01-network-manager-all.yaml
	rm $net_file
	touch $net_file
	add_line $net_file "# Let NetworkManager manage all devices on this system"
	add_line $net_file "network:"
	add_line $net_file "  version: 2"
	add_line $net_file "  renderer: NetworkManager"
	add_line $net_file "  ethernets:"
	add_line $net_file "    $IF:"
	add_line $net_file "      dhcp4: no"
	add_line $net_file "      addresses: [$ip/24"]
	add_line $net_file "      gateway4: 192.168.56.100"

	IFS=$'\n'
	for machine in $( cat $MACHINE_LISTE )
	do
		ip_ad=$( echo $machine | cut -d ' ' -f 1 )
		exist_ip=$( exist /etc/hosts $ip_ad )
		if [ $exist_ip -ne 0 ]; then
			alias=$( echo $machine | cut -d ' ' -f 2 )
			ligne=$ip_ad$'\t'$alias"."$DOMAINE_IP$'\t'$alias
			add_line /etc/hosts $ligne
		fi
	done

	hostname $1.$DOMAINE_IP
	echo $1.$DOMAINE_IP > /etc/hostname

	fi
fi
