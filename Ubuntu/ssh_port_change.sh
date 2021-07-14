# Check for su
if [ `whoami` != root ]; then
    echo "Please run this script as root or using sudo"
    exit
fi

# Banners are fun
echo -e "\n +---------------------------------+"
echo " |   Bash-Cache: SSH Port Change   |"
echo " | github.com/supergnaw/Bash-Cache |"
echo -e " +---------------------------------+\n"

# Get old port number for firewall updates and such
OLD_PORT="$(grep -e 'Port ' /etc/ssh/sshd_config | cut -d' ' -f 2)"

# Show current configuration
echo -e "\n___ Current Config ___"
echo "Current Port:" $OLD_PORT
echo "Firewall Rules:"
echo "To                         Action      From"
echo "--                         ------      ----"
ufw status | grep -e "^${OLD_PORT} "

# Prompt for new SSH port
echo -e "\n___ New Config ___"
read -p "New SSH Port: " NEW_PORT
while (( $NEW_PORT < 1 || $NEW_PORT > 65535 )); do
  echo "Error: enter a valid port number"
  read -p "New SSH Port: " NEW_PORT
done
echo -e "\n___ Processing Changes ___"

# Backup SSH config
echo "Making sshd_config backup (/etc/ssh/sshd_config.bak)..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Parse config and change port number
echo "Modifying SSH port number..."
sed "s/#\?Port [0-9]\+/Port ${NEW_PORT}/gIm" /etc/ssh/sshd_config.bak > sshd_config
mv sshd_config /etc/ssh/sshd_config

# Reload SSH configuration
echo "Reloading SSH daemon..."
systemctl restart sshd

# Modify firewall rules for SSH
echo "Updating firewall rules..."
ufw delete allow $OLD_PORT
ufw allow $NEW_PORT

# Show new configuration
echo -e "\n___ Final Configuration ___"
echo "--- Service ---"
systemctl status sshd | grep -e "[Aa]ctive" | cut -d' ' -f 6-16
systemctl status sshd | grep -e " listening on " | cut -d' ' -f 6-11
echo "--- Firewall ---"
echo "To                         Action      From"
echo "--                         ------      ----"
ufw status | grep -e "^${NEW_PORT} "
