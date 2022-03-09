#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Veuillez entrer le nom de la machine"
else
	if [ $(hostname) = $1".ubo.local" ]; then
		echo "Nom d'hôte correct"
	else
		echo "Nom d'hôte incorrect"
	fi
	echo
	echo "Configuration d'interfaces réseau"
	ifconfig
	echo
	echo "Configuration serveur DNS local"
	cat /etc/hosts
	
	printf "\nVérification de la connexion"
	if [ $1 = "serveur" ]; then
		ping client01
	else
		ping serveur	
	fi	
fi
