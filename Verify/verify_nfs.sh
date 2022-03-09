#!/bin/bash

. param
. functions

nom=$( hostname -a )

if [ $nom = "serveur" ]; then
	echo "Test côté serveur"
	#liste ensemble des dossiers partagés avec les permissions
	exportfs -v
	#liste des clients connectés au serveur
	netstat | grep :nfs
	cd /export/home/client01
	pwd
	touch file1.txt
	touch file2.txt
	ls -l
		
elif [[ $nom =~ "client" ]]; then
	echo "Test côté client"
	#liste si un point de montage nfs est monté
	mount | grep nfs
	mount -a
	cd /home/serveur/client01
	pwd
	ls -l
fi
