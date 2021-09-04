#!/bin/bash
 
echo "Installing and configiring mariadb..."

rhel=`rpm -qa | grep redhat-release`
centos=`rpm --query centos-release`

server_ip=`curl cpanel.net/showip.cgi`

# First we check if the user is 'root' before allowing installation to commence
if [ "$UID" == "0" ]; then
     break;
else 
    _error "Installed failed! To install you must be logged in as 'root', please try again"
   exit 1
fi

_red(){
    printf '\033[1;31;31m%b\033[0m' "$1"
    printf "\n"
}

_green(){
    printf '\033[1;31;32m%b\033[0m' "$1"
}

_yellow(){
    printf '\033[1;31;33m%b\033[0m' "$1"
    printf "\n"
}

_printargs(){
    printf -- "%s" "$1"
    printf "\n"
}

_info(){
    _printargs "$@"
}

_error(){
    _red "$1"
    exit 
}

if [ "${rhel}" == "" ]; then
     if [ "${centos}" == "" ]; then
          echo "Nspanel support only centos 7 or rhel 7"
          exit;
      else
        os_version=`cat /etc/centos-release | tr -dc '0-9.'| cut -d \. -f1`
        os_name="centos"
     fi
 else
   os_version=`cat /etc/redhat-release | tr -dc '0-9.'| cut -d \. -f1` 
   os_name="readhat"
fi

if [ -e /opt/neoistone/mysql ] || [ -e /var/lib/mysql ] || [ -e /etc/my.cnf ] || [ -e /bin/mysql ] || [ -e /sbin/mysql ] || [ -e /usr/bin/mysql ]; then
       _error "mysql already install "
fi

if [ -e /etc/yum.repos.d/mariadb.repo ]; then
     rm -rf /etc/yum.repos.d/mariadb.repo
fi

if [ ! -e /opt/neoistone ]; then
     mkdir /opt/neoistone
fi

if [ -e /opt/sneoistone ]; then
     rm -rf /opt/sneoistone
fi

if [ ! -e /opt/neoistone/logs ]; then
    mkdir /opt/neoistone/logs
fi


MariaDB_Data_Dir="/opt/neoistone/"
cat <<EFO>>/etc/yum.repos.d/mariadb.repo
[mariadb]
name = Neoistone Data MariaDB
baseurl = http://yum.mariadb.org/10.5/${os_name}${os_version}-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EFO

yum clean all 
yum -y update 
yum install -y python3

if [ "${1}" == "" ]; then
        while true; do
           read -e -p "Enter your Mysql Root Password : " mysqlpwd
           if [ "${mysqlpwd}" == "" ]; then
                   exit;
                else 
                 break;
           fi
        done
else 
        mysqlpwd=${1}
fi

yum install  -y MariaDB-server MariaDB-client
sudo systemctl start mariadb

echo "${mysqlpwd}" >> /opt/sneoistone
chmod +x /opt/sneoistone
mysql -uroot <<MYSQL_SCRIPT
UPDATE mysql.user SET Password=PASSWORD('${mysqlpwd}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
systemctl stop mariadb

rsync -av /var/lib/mysql ${MariaDB_Data_Dir}

mv /etc/my.cnf /opt/neoistone/my.cnf.bak

cat <<EFO>> /etc/my.cnf
#generated neoistone
[client]
port            = 3306
socket          = ${MariaDB_Data_Dir}mysql/mysql.sock

[mysqld]
port            = 3306
socket          = ${MariaDB_Data_Dir}mysql/mysql.sock
user    = mysql
bind-address = ${server_ip}
datadir = ${MariaDB_Data_Dir}mysql
log_error = /opt/neoistone/logs/mariadb.log

skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 8M
tmp_table_size = 16M

#skip-networking
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id       = 1
expire_logs_days = 10

default_storage_engine = MyISAM

[mysqldump]
quick
max_allowed_packet = 16M


[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EFO

touch /opt/neoistone/logs/mariadb.log
firewall-cmd --zone=public --permanent --add-port=3306/tcp.

systemctl start mariadb
systemctl enable mariadb
clear
echo "-------------------------------------------------------------------------"
echo "|   Save Credentials Secure Place AND Don't Forgot can not share any one "
echo "|                                                                        "
echo "|   Mysql Root usernname  : root                                         "
echo "|   Mysql Root PASSWORD   : ${mysqlpwd}                                  "
echo "|   Mysql Port            : 3306                                         "
echo "|                                                                        "
echo "|   Thank Install Mariadb Powered by neoistone                           "
echo "|                                                                        "
echo "-------------------------------------------------------------------------"
