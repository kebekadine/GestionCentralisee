#!/bin/bash

. param
. functions

nom=$( hostname -a )

if [ $( dpkg -s nis | grep -c "install ok installed" ) -ne 1 ]; then
	apt install nis
fi	

domaine=$( nisdomainname )

if [ $domaine != $DOMAIN_NIS ]; then
	rm /etc/defaultdomain
	touch /etc/defaultdomain
	add_line /etc/defaultdomain $DOMAIN_NIS
fi

if [ $nom = "serveur" ]; then
	echo "Configuration NIS côté serveur"	

	if [ $( dpkg -s nis | grep -c "install ok installed" ) -ne 1 ]; then
		apt install nis
	fi	

	serveurRemplace=$( replace_line /etc/default/nis "NISSERVER" "NISSERVER=master" )
	clientRemplace=$( replace_line /etc/default/nis "NISCLIENT" "NISCLIENT=false" )

	if [ $serveurRemplace -eq 0 ]; then 
		if [ $clientRemplace -eq 0 ]; then
			ypservModif=$( replace_line /etc/ypserv.securenets "0.0.0.0		0.0.0.0" "#0.0.0.0		0.0.0.0" )
			if [ $ypservModif -eq 0 ]; then
				if [ $( exist /etc/ypserv.securenets "255.255.255.0		192.168.56.0" ) -eq 1 ]; then
					add_line /etc/ypserv.securenets "255.255.255.0		192.168.56.0"
				fi	
				/usr/lib/yp/ypinit -m
				IFS=$'\n'
				for machine in $( cat $MACHINE_LISTE )
				do			
					clientip=$( echo $machine | cut -d ' ' -f 1 )
					ufw allow from $clientip			
				done
				systemctl restart rpcbind nis

				groupadd clients
				echo "Création utilisateur client01"
				adduser --home /home/clients/client01 --ingroup clients --shell /bin/bash --quiet --gecos "" client01
				echo "Création utilisateur client02"
				adduser --home /home/clients/client02 --ingroup clients --shell /bin/bash --quiet --gecos "" client02
				echo "Création utilisateur client03"
				adduser --home /home/clients/client03 --ingroup clients --shell /bin/bash --quiet --gecos "" client03
				
				cd /var/yp
				make
				echo "end"
			fi
		fi
	fi	
elif [[ $nom =~ "client" ]]; then
	echo "Configuration NIS côté client"

	#Modification du fichier /etc/yp.conf pour l'ajout du nom du serveur
	if [ $( exist /etc/yp.conf "domain" ) -eq 1 ]; then
		add_line /etc/yp.conf  "domain $DOMAIN_NIS server srvnis.$DOMAIN_NIS"
	else
		replace_line /etc/yp.conf "domain" "domain $DOMAIN_NIS server srvnis.$DOMAIN_NIS"
	fi
	
	config_ypserver="ypserver "$SERVEUR_NIS"."$DOMAIN_NIS

	if [ $( exist /etc/yp.conf $config_ypserver ) -eq 1 ]; then
		add_line /etc/yp.conf $config_ypserver
	fi

	replace_line /etc/nsswitch.conf "passwd" "passwd:         compat systemd nis"
	replace_line /etc/nsswitch.conf "group"  "group:          compat systemd nis"
	replace_line /etc/nsswitch.conf "shadow" "shadow:         compat nis"

	autorisation_rep_perso="session optional pam_mkhomedir.so skel=/etc/skel umask=007"

	if [ $( exist /etc/pam.d/common-session $autorisation_rep_perso ) -eq 1 ]; then
		add_line /etc/pam.d/common-session $config_ypserver
	fi
fi
