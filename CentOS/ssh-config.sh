echo "===== Configure SSH ====="
PORT=0
# prompt for new port
while [[ $PORT < 22 || $PORT > 65535 ]]
do
	read -p "Enter new SSH port (22-65535):" PORT
done

# backup configuration
echo "...creating backup sshd_config in /etc/sshd/sshd_config.bak"
rm -f /etc/ssh/sshd_config.bak
cp -uf /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# update config
echo "...updating /etc/ssh/sshd_config options"
sed -e "s/\#Port /Port /g" -e "s/Port [0-9]\{2,5\}/Port $PORT/g" -e "s/\#PermitRootLogin /PermitRootLogin /g" -e "s/PermitRootLogin yes/PermitRootLogin without-password/g" /etc/ssh/sshd_config.bak > /etc/ssh/sshd_config

# update firewall settings
echo "...managing firewall ports"
semanage port -D -t ssh_port_t -p tcp
semanage port --add -t ssh_port_t -p tcp $PORT

# restart service
echo "...restarting service"
systemctl restart sshd

while [[ true ]]
do
	echo "Configuration complete!"
	echo "Before exiting the script, please try logging into SSH via port $PORT"
	echo "Was the test successful? (y/n):"
	read RESULT
	if [[ $RESULT == "y" ]] || [[ $RESULT == "Y" ]]
	then
		# everything works
		echo "Thanks for playing!"
		break
	fi
	if [[ $RESULT == "n" ]]
	then
		# restore previous settings
		rm -f /etc/ssh/sshd_config
		cp -uf /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
		systemctl restart sshd
		echo "Previous settings restored"
		break
	fi
done
echo "----- Complete -----"
