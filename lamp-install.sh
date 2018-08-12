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
# special shoutout to this tutorial for making this a reality:
#	http://www.configserverfirewall.com/linux-tutorials/install-phpmyadmin-centos-7/
# for phpma verions go to
#	https://www.phpmyadmin.net/downloads/
curl -O https://files.phpmyadmin.net/phpMyAdmin/4.8.2/phpMyAdmin-4.8.2-all-languages.tar.gz
tar -zxvf phpMyAdmin-4.8.2-all-languages.tar.gz --directory /usr/share
mv phpMyAdmin-4.8.2-all-languages phpmyadmin
echo 'Alias /phpMyAdmin /usr/share/phpmyadmin
Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin/>
    AddDefaultCharset UTF-8

    <IfModule mod_authz_core.c>
      # Apache 2.4
      <RequireAny>
        Require all granted
        Require ip 127.0.0.1
        Require ip ::1
      </RequireAny>
    </IfModule>
    <IfModule !mod_authz_core.c>
      # Apache 2.2
      Order Deny,Allow
      Deny from All
      Allow from 127.0.0.1
      Allow from ::1
    </IfModule>
</Directory>

<Directory /usr/share/phpmyadmin/setup/>
    <IfModule mod_authz_core.c>
      # Apache 2.4
      <RequireAny>
        Require ip 127.0.0.1
        Require ip ::1
      </RequireAny>
    </IfModule>
    <IfModule !mod_authz_core.c>
      # Apache 2.2
      Order Deny,Allow
      Deny from All
      Allow from 127.0.0.1
      Allow from ::1
    </IfModule>
</Directory>

# These directories do not require access over HTTP - taken from the original
# phpmyadmin upstream tarball
#
<Directory /usr/share/phpmyadmin/libraries/>
    Order Deny,Allow
    Deny from All
    Allow from None
</Directory>

<Directory /usr/share/phpmyadmin/setup/lib/>
    Order Deny,Allow
    Deny from All
    Allow from None
</Directory>

<Directory /usr/share/phpmyadmin/setup/frames/>
    Order Deny,Allow
    Deny from All
    Allow from None
</Directory>' > /etc/httpd/conf.d/phpmyadmin.conf

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
