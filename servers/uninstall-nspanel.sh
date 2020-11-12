#!/bin/bash
# Copyright (C) 2019 - 2020 Neoistone <hosting@neoistone.com>
# 
# This file is part of the NSPANEL script.
#
# NSPANEL is a powerful contorlpanel for the installation of 
# Apache + PHP + MySQL/MariaDB/ + Email Server + NSVRITUAL contorl panel .
# And all things will be done in a few minutes.
#
#
# This program is free software; you can't redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# NEOISTONE is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with NEOISTONE; if not, see <http://www.gnu.org/licenses/>.

# NEOISTONE(NSPANEL) is an open source conferencing system.  For more information see
#    http://nspanel.neoistone.com/.
#
# This vmacct.sh script automates many of the installation and configuration
# steps at
#    http://docs.neoistone.com/nspanel/installtion

# System Required:  Centos7-8 or rhel7-8
# Description:  Install LAMP(Linux + pache + PHP + MySQL/MariaDB/ + Email Server + NSVRITUAL contorl panel )
# Website:  https://www.neoistone.com
# Github:   https://github.com/neoistone/nspanel
curl_dir=`pwd`
clear
echo "|--------------------------------------------------------------------|"
echo "|       _  __ ____ ____   ____ ____ ______ ____   _  __ ____ NSPANEL |"
echo "|      / |/ // __// __ \ /  _// __//_  __// __ \ / |/ // __/         |"
echo "|     /    // _/ / /_/ /_/ / _\ \   / /  / /_/ //    // _/           |"
echo "|    /_/|_//___/ \____//___//___/  /_/   \____//_/|_//___/           |"
echo "|                                                                    |"
echo "|--------------------------------------------------------------------|" 
while true; do
read -e -p "Would you like to continue (y/n)? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;
    esac
done
systemctl stop nspanel
systemctl disable nspanel

rm -rf /opt/neoistone/nspanel/
rm -rf /var/log/nspanel/
rm -rf /var/cache/nspanel/
rm -rf /opt/neoistone/sbin/nspanel
rm -rf /opt/neoistone/pid/nspanel.pid
rm -rf /var/run/nspanel.lock
rm -rf /etc/ssl/nspanel
systemctl unmask nspanel
rm -rf /etc/systemd/system/nspanel.service
rm -rf /etc/sysconfig/nspanel
kill -9 nspanel
userdel nspanel
yum -y update
yum clean all
rm -rf ${curl_dir}/uninstall-nspanel.sh
