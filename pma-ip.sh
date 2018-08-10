myip=`who am i | awk '{ print $5 }'`
myip=${myip:1:-1}
echo $myip

### Alias Management
grep 'Alias' "/etc/httpd/conf.d/phpMyAdmin.conf"
grep 'Alias \/\w\+ \/usr\/share\/phpMyAdmin' "/etc/httpd/conf.d/phpMyAdmin.conf"
read -p "Change alias? (y/n):" change
if [[ "${change}" == "y" ]] || [[ "${change}" == "Y" ]]; then
	read -p "New alias:" ali
	rm -f "/etc/httpd/conf.d/phpMyAdmin.conf.tmp"
	cp -uf "/etc/httpd/conf.d/phpMyAdmin.conf" "/etc/httpd/conf.d/phpMyAdmin.conf.tmp"
	sed -e "s/Alias \/\w\+ \/usr\/share\/phpMyAdmin/Alias \/$ali \/usr\/share\/phpMyAdmin/g" "/etc/httpd/conf.d/phpMyAdmin.conf.tmp" > "/etc/httpd/conf.d/phpMyAdmin.conf"
	rm -f "/etc/httpd/conf.d/phpMyAdmin.conf.tmp"
fi

### Control IP Addresses
grep '\(Require ip\|Allow from\) [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' "/etc/httpd/conf.d/phpMyAdmin.conf"
read -p "Replace all IP addresses with $myip? (y/n)" rep
if [[ "${rep}" == "y" ]] || [[ "${rep}" == "Y" ]]; then
	rm -f "/etc/httpd/conf.d/phpMyAdmin.conf.bak"
	cp -uf "/etc/httpd/conf.d/phpMyAdmin.conf" "/etc/httpd/conf.d/phpMyAdmin.conf.bak"
	rm -f "/etc/httpd/conf.d/phpMyAdmin.conf"
	sed -e "s/[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+/$myip/g" "/etc/httpd/conf.d/phpMyAdmin.conf.bak" > "/etc/httpd/conf.d/phpMyAdmin.conf"
	systemctl restart httpd.service
fi
read -p "Were all changes successful? (y/n)" rep
if [[ "${rep}" != "y" ]] || [[ "${rep}" != "Y" ]]; then
	rm -f "/etc/httpd/conf.d/phpMyAdmin.conf"
	cp -uf "/etc/httpd/conf.d/phpMyAdmin.conf.bak" "/etc/httpd/conf.d/phpMyAdmin.conf"
	systemctl restart httpd.service
fi
