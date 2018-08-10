#!/bin/bash
# This script is used for creating virtual hosts on CentOS
# Created by alexnogard from http://alexnogard.com
# Improved by mattmezza from http://you.canmakethat.com
# Enhanced by supergnaw
# Feel free to modify it

##
# This will check if directory already exist then create it with path : /directory/you/choose/domain.com
# Set the ownership, permissions and create a test index.php file
# Create a vhost file domain in your /etc/httpd/conf.d/ directory.
# And add the new vhost to the hosts.
#
#
# Check if you execute the script as root user
if [ "$(whoami)" != 'root' ]; then
	echo "You have to execute this script as root user"
	echo "--------------------"
	exit 1;
fi

read -p "Enter the server name (without www.): " servn
read -p "Enter a CNAME (e.g. www, dev): " cname
read -p "Enter the user you want use (e.g. $USER): " usr
read -p "Enter the path of directory you want to use (e.g. /var/www/html/$cname.$servn/): " dir
read -p "Enter the port for the domain (e.g. 80): " port
read -p "Enter the listened IP for the server (e.g. *): " listen

# Input Validation
if [[ ${servn:0:4} == "www." ]]; then
	echo "Invalid server name: $servn"
	exit 1
fi
cname="${cname:=www}"
dir="${dir:=/var/www/html/$cname.$servn/}"
if [ "${dir: -1}" != "/" ]; then
	dir="$dir/"
fi
usr="${usr:=$USER}"
if [ -z "$usr" ]; then
	usr=$USER
else
	uid=id -u $usr &>/dev/null
	echo $uid
fi
port="${port:=80}"
if [ -z "$listen" ]; then
	listen="*"
fi

### Create New Website Directory ###
if ! mkdir -p "$dir"; then
	echo "Web directory already exists."
else
	echo "Web directory successfully created."
fi

# add default files
if [ ! -f "$dir/index.php" ]; then
	echo "<?php echo '<h1>$cname.$servn</h1>'; ?>" > "$dir/index.php"
	echo "<?php phpinfo(); ?>" > "/var/www/html/$cname.$servn/info.php"
fi

# do permissions
chown -R $usr:$usr $dir
chmod -R '755' $dir
mkdir "/var/log/httpd/$cname.$servn.log"

if [[ "${cname}" == "" ]]; then
	alias=$servn
else
	alias=$cname.$servn
fi

### Create Config Files ###
# http vhost
echo "#### $cname.$servn
<VirtualHost $listen:80>
	ServerName $servn
	ServerAlias $alias
	DocumentRoot $dir
	<Directory $dir>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		Allow from all
		Require all granted
	</Directory>
	ErrorLog /var/log/$cname.$servn-error.log
</VirtualHost>" > "/etc/httpd/conf.d/$cname.$servn.conf"
if ! echo -e "/etc/httpd/conf.d/$cname.$servn.conf"; then
	echo "Virtual host wasn't created!"
else
	echo "Virtual host created!"
fi

# https vhost and associated key
read -p "Create ssl virtual host (y/n)? " q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]] || [[ "${q}" == "Y" ]]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "/etc/httpd/conf.d/$cname.$servn.key" -out "/etc/httpd/conf.d/$cname.$servn.crt"
	if ! echo -e "/etc/httpd/conf.d/$cname.$servn.key"; then
		echo "Certificate key wasn't created!"
	else
		echo "Certificate key created!"
	fi
	if ! echo -e "/etc/httpd/conf.d/$cname.$servn.crt"; then
		echo "Certificate wasn't created!"
	else
		echo "Certificate created!"
	fi

	echo "#### ssl $cname.$servn
<VirtualHost $listen:443>
	SSLEngine on
	SSLCertificateFile /etc/httpd/conf.d/$cname.$servn.crt
	SSLCertificateKeyFile /etc/httpd/conf.d/$cname.$servn.key
	ServerName $servn
	ServerAlias $alias
	DocumentRoot $dir
	<Directory $dir>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		Allow from all
		Satisfy Any
	</Directory>
	ErrorLog /var/log/$cname.$servn-error.log
</VirtualHost>" > "/etc/httpd/conf.d/ssl.$cname.$servn.conf"
	if ! echo -e "/etc/httpd/conf.d/ssl.$cname.$servn.conf"; then
		echo "SSL Virtual host wasn't created !"
	else
		echo "SSL Virtual host created !"
	fi
fi

# Finalization
# manage hosts file
echo "127.0.0.1 $servn" >> /etc/hosts
if [ "$alias" != "$servn" ]; then
	echo "127.0.0.1 $alias" >> /etc/hosts
fi

# configuration testing
echo "Testing configuration..."
service httpd configtest

# restart service
read -p "Would you like me to restart the httpd service [y/n]? " q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]] || [[ "${q}" == "Y" ]]; then
	systemctl restart httpd
fi

echo "======================================"
echo "All works done! You should be able to see your website at http://$servn"
echo ""
echo "Share the love! <3"
echo "======================================"
# echo ""
# echo "Wanna contribute to improve this script? Found a bug? https://gist.github.com/mattmezza/2e326ba2f1352a4b42b8"
