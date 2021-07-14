#!/bin/bash
echo " ===== Bash Server Interface 1.0 ====="
echo " [1] - LAMP Install"
echo " [2] - SSH Config"
echo " [3] - User RSA Keys"
echo " [4] - Virtual Host Configurator"
echo " [5] - phpMySQL Configuration"
echo " [6] - Watch HTTP Error Log"
echo " [0] - Exit"
echo "------------------------------------------"
menu=0
while [[ $menu < 1 ]] || [[ $menu > 5 ]]
do
	read -p " Enter menu option ($menu):" menu
done
exit 1
