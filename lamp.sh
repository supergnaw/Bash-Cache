#!/bin/bash
echo "===== LAMP Install ====="

# 1.0
yum -y update
echo "Installing repos..."
yum -y install epel-release

# 1.1 apache
echo "Installing Apache..."
yum -y install httpd
systemctl enable httpd.service
systemctl start httpd.service
yum -y install mod_ssl

# 1.2 mariadb
echo "Installing MariaDB..."
yum -y install mariadb-server mariadb
systemctl enable mariadb
systemctl start mariadb

# 1.3 php
echo "Installing PHP, MySQL, and phpMyAdmin..."
yum -y install php php-mysql phpmyadmin

# 1.4 test/restart service
echo "Testing config..."
service httpd configtest
read -p "Testing complete. Restart httpd service? (y/n):" rstrt

if [[ "${rstrt}" == "Y" ]] || [[ "${rstrt}" == "y" ]] || [[ "${rstrt}" == "yes" ]]; then
	systemctl restart httpd.service
fi

# 1.5 configuring mysql
mysql_secure_installation

echo ""
echo "LAMP install complete!"
echo ""
