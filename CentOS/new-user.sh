echo "===== Add New User ====="
read -p "Username: " usr
read -p "Give sudo permissions? (y/n): " SUDO
adduser $usr
passwd $usr
if [ $SUDO == 'y' ]
then
	gpasswd -a $usr wheel
fi
echo "----- Complete -----"
