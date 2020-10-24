password=${1}
path=${2}
os_type=${3}
mysql_install(){
cat <<EFO>>/opt/neoistone/mysql_password
${password}
EFO
DB_Root_Password=`sh /opt/neoistone/mysql_password`
if [[ "${os_type}" == "centos7" ]]; then
cat <<EFO>>/etc/yum.repos.d/mariadb.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/${os_type}-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EFO
 elif [[ "${os_type}" == "rhel7" ]]; then
cat <<EFO>>/etc/yum.repos.d/mariadb.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/${os_type}-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EFO
 elif [[ "${os_type}" == "rhel8" ]]; then
cat <<EFO>>/etc/yum.repos.d/mariadb.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/${os_type}-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EFO
 elif [[ "${os_type}" == "centos8" ]]; then
cat <<EFO>>/etc/yum.repos.d/mariadb.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/${os_type}-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EFO
fi
yum install  -y MariaDB-server MariaDB-client
mysqld --print-defaults
systemctl start mariadb
systemctl enable mariadb
mysql -uroot <<MYSQL_SCRIPT
UPDATE mysql.user SET Password=PASSWORD('${DB_Root_Password}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
systemctl stop mariadb
rsync -av /var/lib/mysql ${MariaDB_Data_Dir}
mv /var/lib/mysql /var/lib/mysql.bak
cp /etc/my.cnf /etc/my.cnf.bak
echo <<EFO>>/etc/my.cnf
#generated neoistone
[client]
port		= 3306
socket		= ${MariaDB_Data_Dir}/mysql/mysql.sock

[mysqld]
port		= 3306
socket		= ${MariaDB_Data_Dir}/mysql/mysql.sock
user    = mysql
#bind-address = 0.0.0.0
datadir = ${MariaDB_Data_Dir}
log_error = ${neoistone}/logs/mariadb.err

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
server-id	= 1
expire_logs_days = 10

default_storage_engine = InnoDB
innodb_file_per_table = 1
innodb_data_home_dir = ${MariaDB_Data_Dir}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${MariaDB_Data_Dir}
innodb_buffer_pool_size = 16M
innodb_additional_mem_pool_size = 2M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout

[mariadb]
aria-encrypt-tables
encrypt-binlog
encrypt-tmp-disk-tables
encrypt-tmp-files
loose-innodb-encrypt-log
loose-innodb-encrypt-tables
EFO
systemctl start mariadb
systemctl enable mariadb
}
mysql_install
