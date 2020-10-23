runpath=`pwd`
install_dir=`sh /opt/var`
systemctl stop neoistone
systemctl disable neoistone
rm -rf /etc/systemd/system/neoistone.service
rm -rf /var/www/html/*
rm -rf /etc/sysconfig/neoistone
rm -rf /bin/neoistone
rm -rf ${install_dir}
rm -rf /opt/var
userdel neoistone
firewall-cmd --zone=public --permanent --remove-service=http
firewall-cmd --zone=public --permanent --remove-service=https
firewall-cmd --reload
rm -rf ${runpath}/uninstall-neoistone.sh
