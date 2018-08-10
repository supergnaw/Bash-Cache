echo "===== SSH Key Generator ====="
read -p "Type username for the new key:" usr
read -p "Input file name for new RSA key:" FILE
if [ -z "$FILE" ]
then
	DATE=`date +"%Y%m%d%H%M%S"`
	FILE="key_"$DATE
	echo "using default filename: $FILE"
fi
if [ $usr == "root" ]; then
	dir="/root/.ssh"
else
	dir="/home/$usr/.ssh"
fi
mkdir -p "$dir/"
touch "$dir/authorized_keys"
ssh-keygen -t rsa -f "$dir/$FILE"
cat "$dir/$FILE.pub" >> "$dir/authorized_keys"
chmod 600 "$dir/authorized_keys"
chmod 700 "$dir"
chown -R $usr:$usr "$dir"
systemctl restart sshd
echo "New key successfully generated and installed!"
echo "Please save your private key locally from $dir/$FILE"
read -p "View key now? (y/n):" view
view="${view:=y}"
if [[ "${view}" == "yes" ]] || [[ "${view}" == "y" ]] || [[ "${view}" == "Y" ]]; then
	vi $dir/$FILE
else
	echo "You can view your key at any time at the following location:"
	echo "  $dir/$FILE"
fi
echo "----- Key Generation Complete -----"
