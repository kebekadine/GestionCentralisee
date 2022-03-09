#!/bin/bash

. functions
. param

nom=$(hostname -a)

if [ $nom = "serveur" ]; then	
	echo "Configuration serveur NFS côté serveur"
	systemctl enable nfs-server
	systemctl start nfs-server	

	mkdir -p /export/opt

	chown -R nobody:nogroup /export/opt
	chmod 777 /export/opt
	
	exportfs -a
	systemctl restart nfs-kernel-server
	ufw enable

	IFS=$'\n'
	for machine in $( cat $MACHINE_LISTE )
	do
		alias=$( echo $machine | cut -d ' ' -f 2 )
		mkdir -p  /export/home/$alias
		chown -R nobody:nogroup /export/home/$alias
		chmod 777 /export/home/$alias		
		if [ $(exist /etc/exports $alias) -eq 1 ]; then
			add_line /etc/exports $EXPORT_APP" "$alias"("$EXPORT_APP_OPT")"
			add_line /etc/exports $EXPORT_HOME/$alias" "$alias"("$EXPORT_HOME_OPT")"
	
			exportfs -a
		
			ip=$( echo $machine | cut -d ' ' -f 1 )
			ufw allow from $ip to any port nfs
		fi
	done
elif [[ $nom =~ "client" ]]; then
	echo "Configuration serveur NFS côté client"
	mkdir -p $MOUNT_HOME/$nom  
	mkdir -p $MOUNT_HOME$MOUNT_APP

	mount $SERVEUR_NFS:$EXPORT_HOME/$nom	$MOUNT_HOME/$nom
	mount $SERVEUR_NFS:$EXPORT_APP 		$MOUNT_HOME$MOUNT_APP

	if [ $(exist /etc/fstab $nom) -ne 0 ]; then
		add_line /etc/fstab  $SERVEUR_NFS":"$EXPORT_HOME/$nom"	"$MOUNT_HOME/$nom"	nfs	"$MOUNT_HOME_OPT"	0 0"
		add_line /etc/fstab  $SERVEUR_NFS":"$EXPORT_APP"	"$MOUNT_HOME"$MOUNT_APP	nfs	"$MOUNT_APP_OPT"	0 0"
	fi

fi
