#!/bin/bash

. param
. functions

nom=$( hostname -a )

if [ $nom = "serveur" ]; then
	echo "Test côté serveur"
	#Exécution de tests nis préconfigurés 
	yptest
		
elif [[ $nom =~ "client" ]]; then
	echo "Test côté client"	
	#Exécution de tests nis préconfigurés 
	yptest

	#Liste des utilisateurs définis sur le serveur NIS
	ypcat passwd
		
fi
