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

clear
echo "|--------------------------------------------------------------------|"
echo "|       _  __ ____ ____   ____ ____ ______ ____   _  __ ____ NSPANEL |"
echo "|      / |/ // __// __ \ /  _// __//_  __// __ \ / |/ // __/         |"
echo "|     /    // _/ / /_/ /_/ / _\ \   / /  / /_/ //    // _/           |"
echo "|    /_/|_//___/ \____//___//___/  /_/   \____//_/|_//___/           |"
echo "|                                                                    |"
echo "|--------------------------------------------------------------------|" 

# First we check if the user is 'root' before allowing installation to commence
if [ $UID -ne 0 ]; then
    echo "Installed failed! To install you must be logged in as 'root', please try again"
  exit 1
fi

# Lets check for some common control panels that we know will affect the installation/operating of Nspanel.
if [ -e /usr/local/cpanel ] || [ -e /usr/local/directadmin ] || [ -e /otp/nspanel/ ] || [ -e /usr/local/solusvm/www ] || [ -e /usr/local/home/admispconfig ] || [ -e /usr/local/lxlabs/kloxo ] ; then
    echo "You appear to have a control panel already installed on your server; This installer"
    echo "is designed to install and configure Nspanel on a clean OS installation only!"
    echo ""
    echo "Please re-install your OS before attempting to install using this script."
    exit
fi

if rpm -q php httpd mysql bind postfix dovecot; 
then
    echo "You appear to have a server with apache/mysql/bind/postfix already installed; "
    echo "This installer is designed to install and configure Nspanel on a clean OS "
    echo "installation only!"
    echo ""
    echo "Please re-install your OS before attempting to install using this script."
    exit
exit 
fi
echo "+----------------------------------------------------------------------
| Copyright © 2019-2022 Neoistone(https://www.neoistone.com) All rights reserved.
+----------------------------------------------------------------------
| The AdminPanel URL will be https://SERVER_IP:2087 when installed.
+----------------------------------------------------------------------
| The UserPanel URL will be https://SERVER_IP:2083 when installed.
+----------------------------------------------------------------------
| The Webmail URL will be https://SERVER_IP:2096 when installed.
+----------------------------------------------------------------------"
rhel=`rpm -qa | grep redhat-release`
centos=`rpm --query centos-release`
if [[ "${rhel}" == "" ]]; then
        if [[ "${centos}" == "package centos-release is not installed" ]]; then
                echo "This OS Not supporte Nspanel support version are the cento7-8/rhel7-8"
                exit;
         else
         	centos_version=`cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1`
         	if [[ "${centos_version}"  == "7" ]]; then
         		os_type="centos${centos_version}"
         		os_version="${centos_version}"
         		os_name="centos"
         	 elif [[ "${centos_version}"  == "8" ]]; then
         		os_type="centos${centos_version}"
         		os_version="${centos_version}"
         		os_name="centos"
         	 else
         	  echo "This OS Not supporte Nspanel support version are the cento7-8/rhel7-8"
         	  exit;
         	fi
        fi
 else
  rhel_versio=`cat /etc/redhat-release | tr -dc '0-9.'|cut -d \. -f1`
  status=`subscription-manager list | egrep -i 'Status:         Subscribed'`
  if [[ "${rhel_versio}"  == "7" ]]; then
  	     if[ "${status}" == "Status:         Subscribed" ]; then
             os_type="rhel${rhel_versio}"
             os_version="${rhel_versio}"
             os_name="rhel"
         else
           exit;
  	     fi
  elif [[ "${rhel_versio}"  == "8" ]]; then
           if[ "${status}" == "Status:         Subscribed" ]; then
             os_type="rhel${rhel_versio}"
             os_version="${rhel_versio}"
             os_name="rhel"
           else
            exit;
  	       fi
  else
    echo "This OS Not supporte Nspanel support version are the cento7-8/rhel7-8"
    os_type="not found "
    os_version="0"
    os_name="not found"
    exit;
  fi
fi
cur_dir=`pwd`
# ***************************************
# * Common installer functions          *
# ***************************************
# Generates random passwords fro the 'nspanel' account as well as Postfix and MySQL root account.
passwordgen() {
         l=$1
           [ "$l" == "" ] && l=16
          tr -dc A-Za-z0-9 < /dev/urandom | head -c ${l} | xargs
}
hostnamectl set-hostname ${1}
# Gathering System Information
fqdn=`/bin/hostname`
publicip=`curl -4 icanhazip.com`
cpu_count=`cat /proc/cpuinfo |grep -c processor`
cpu_full=`cat /proc/cpuinfo |egrep -i 'model name'`
server_technology=`dmidecode | egrep -i 'name'`
ram_count=`echo $(($(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE) / (1024 * 1024)))`
architecture=`$(getconf WORD_BIT)`
swap=$( free -m | awk '/Swap/ {print $2}' )
tram_count=$( expr ram_count + $swap )
requirements_dispaly(){
        echo "|-------------------------------------------------------------------|"
		echo "| Operating        : Centos7-8 or Rhel7-8                           |"
		echo "| Memory           : 2GB                                            |"
		echo "| Disk Space	     : 50GB                                           |"
		echo "| Architecture     : 64Bit.                                         |"
		echo "| processor        : Intel E3(core2) 1.5GH.                         |"
		echo "|                                                                   |"
		echo "| RECOMMEND VPS HOSTING AWS OR GOOGLE ClOUD & Neoistone vps Hosting |"
		echo "| Neoistone Hosting : https://neoistone.in/vps-hosting/?r=nspanel   |" 
		echo "| Aws               : https://aws.amazon.com                        |"
		echo "| Google Cloud      : https://cloud.google.com                      |"
		echo "|                                                                   |"
		echo "|-------------------------------------------------------------------|"
}

if [ "${cpu_count}" == "0" ] || [ "${cpu_count}" == "" ] || [ "${cpu_count}" == "1" ]; then
	 requirements_dispaly
 elif [[ "${ram_count}" == "1024" ]]; then
 	requirements_dispaly
 elif [[ "${architecture}" == "32" ]]; then
 	requirements_dispaly
fi
check_command_exist(){
    local cmd="$1"
    if eval type type > /dev/null 2>&1; then
        eval type "$cmd" > /dev/null 2>&1
    elif command > /dev/null 2>&1; then
        command -v "$cmd" > /dev/null 2>&1
    else
        which "$cmd" > /dev/null 2>&1
    fi
    rt=$?
    if [ ${rt} -ne 0 ]; then
        _error "$cmd is not installed, please install it and try again."
    fi
}
# functions 
download_file(){
    local cur_dir=$(pwd)
    if [ -s "$1" ]; then
        _info "$1 [found]"
    else
        _info "$1 not found, download now..."
        wget --no-check-certificate -cv -t3 -T60 -O ${1} ${2}
        if [ $? -eq 0 ]; then
            _info "$1 download completed..."
        else
            rm -f "$1"
            _info "$1 download failed, retrying download from secondary url..."
            wget --no-check-certificate -cv -t3 -T60 -O "$1" "${download_root_url}${1}"
            if [ $? -eq 0 ]; then
                _info "$1 download completed..."
            else
                _error "Failed to download $1, please download it to ${cur_dir} directory manually and try again."
            fi
        fi
    fi
}
# port checker
port_cheker(){
	checker=`netstat -plnt | grep ${1} | awk '{print $6}'`
	if [[ ${checker} == "LISTEN" ]]; then
		return 1;
	else
	 return 0;
	fi
}
 requirements_install(){
   yum install -y zip unzip zlib zlib-devel pcre  pecl openssl-devel openssl perl cmake make curl wget apr gcc git tree  gcc-c++  openssl-devel  bison  screen  gc  gcc++  gcc  pecl-devel pcre-devel socat epel-release nano net-tools pcre-devel libtool yum-presto vim html2text sed gawk ntp firewalld mod_ssl openssh
   yum update -y bash
   yum groupinstall "Development Tools" -y 
   wget https://neoistone-main.000webhostapp.com/centos-7.sh && sh centos-7.sh && rm -rf centos-7.sh
   yum remove -y httpd
   yum install -y pdns pdns-backend-mysql
 }
 neoistone_installtion(){
   download_file https://raw.githubusercontent.com/neoistone/lempp/main/servers/neoistone.tar.gz
   tar xvf neoistone.tar.gz
   cd neoistone
   useradd --system --home /var/cache/neoistone --shell /sbin/nologin --comment "neoistone user" --user-group neoistone
   dir="/opt/neoistone/webserver"
    ./configure --user=neoistone --group=neoistone\
               --prefix=${dir}\
               --with-http_gzip_static_module\
               --with-http_stub_status_module\
               --with-http_ssl_module\
               --with-pcre\
               --with-file-aio\
               --with-http_realip_module\
               --without-http_scgi_module\
               --without-http_uwsgi_module\
               --with-http_realip_module\
               --with-stream\
               --sbin-path=${dir}/bin\
               --conf-path=${dir}/neoistone.conf\
               --pid-path=${dir}/neoistone.pid
    make && make install
    rm -rf ${dir}/nginx.conf.default ${dir}/mime.types.default ${dir}/uwsgi_params.default ${dir}/scgi_params.default ${dir}/fastcgi_params.default ${dir}/fastcgi.conf.default
    mkdir ${dir}/conf.d
    if [[ -e /bin/neoistone ]]; then
          rm -rf /bin/neoistone
    fi
    echo "neoistone command registering"
    cat <<EFO>> /bin/neoistone
      echo "Neoistone Power by Nginx"
      echo "Neoistone 0.1.2"
      echo "All Copyright Reserved by nginx"
EFO
chmod +x /bin/neoistone
echo "unwanted file removing"
rm -rf /var/www/html
mv ${dir}/html /var/www/html
rm -rf ${dir}/html
rm -rf ${dir}/neoistone.conf
rm -rf ${dir}/fastcgi.conf
rm -rf ${dir}/mime.types
rm -rf ${dir}/proxy.conf
echo "writing configure fastcgi file"
cat <<EFO>> ${dir}/fastcgi.conf
#copyright resverd by nginx
#modify neoistone
#nginx some change do this webserver 
#neoistone version 0.0.2
fastcgi_param  SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
fastcgi_param  QUERY_STRING       \$query_string;
fastcgi_param  REQUEST_METHOD     \$request_method;
fastcgi_param  CONTENT_TYPE       \$content_type;
fastcgi_param  CONTENT_LENGTH     \$content_length;
fastcgi_param  SCRIPT_NAME        \$fastcgi_script_name;
fastcgi_param  REQUEST_URI        \$request_uri;
fastcgi_param  DOCUMENT_URI       \$document_uri;
fastcgi_param  DOCUMENT_ROOT      \$document_root;
fastcgi_param  SERVER_PROTOCOL    \$server_protocol;
fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx/\$nginx_version;
fastcgi_param  REMOTE_ADDR        \$remote_addr;
fastcgi_param  REMOTE_PORT        \$remote_port;
fastcgi_param  SERVER_ADDR        \$server_addr;
fastcgi_param  SERVER_PORT        \$server_port;
fastcgi_param  SERVER_NAME        \$server_name;
fastcgi_index  index.php;
fastcgi_param  REDIRECT_STATUS    200;
EFO
echo "writing configure mime file"
cat <<EFO>> ${dir}/mime.types
#copyright resverd by nginx
#modify neoistone
#nginx some change do this webserver 
#neoistone version 0.0.2
types {
  text/html                             html htm shtml;
  text/ns                               ns;
  text/css                              css;
  text/xml                              xml rss;
  image/gif                             gif;
  image/jpeg                            jpeg jpg;
  application/x-javascript              js;
  text/plain                            txt;
  text/x-component                      htc;
  text/mathml                           mml;
  image/png                             png;
  image/x-icon                          ico;
  image/x-jng                           jng;
  image/vnd.wap.wbmp                    wbmp;
  application/java-archive              jar war ear;
  application/mac-binhex40              hqx;
  application/pdf                       pdf;
  application/x-cocoa                   cco;
  application/x-java-archive-diff       jardiff;
  application/x-java-jnlp-file          jnlp;
  application/x-makeself                run;
  application/x-perl                    pl pm;
  application/x-pilot                   prc pdb;
  application/x-rar-compressed          rar;
  application/x-redhat-package-manager  rpm;
  application/x-sea                     sea;
  application/x-shockwave-flash         swf;
  application/x-stuffit                 sit;
  application/x-tcl                     tcl tk;
  application/x-x509-ca-cert            der pem crt;
  application/x-xpinstall               xpi;
  application/zip                       zip;
  application/octet-stream              deb;
  application/octet-stream              bin exe dll;
  application/octet-stream              dmg;
  application/octet-stream              eot;
  application/octet-stream              iso img;
  application/octet-stream              msi msp msm;
  audio/mpeg                            mp3;
  audio/x-realaudio                     ra;
  video/mpeg                            mpeg mpg;
  video/quicktime                       mov;
  video/x-flv                           flv;
  video/x-msvideo                       avi;
  video/x-ms-wmv                        wmv;
  video/x-ms-asf                        asx asf;
  video/x-mng                           mng;
}
EFO
echo "writing configure proxy file"
cat <<EFO>> ${dir}/proxy.conf
#copyright resverd by nginx
#modify neoistone
#nginx some change do this webserver 
#neoistone version 0.0.2
proxy_redirect          off;
proxy_set_header        Host            \$host;
proxy_set_header        X-Real-IP       \$remote_addr;
proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
client_max_body_size    1024m;
client_body_buffer_size 128k;
proxy_connect_timeout   90;
proxy_send_timeout      90;
proxy_read_timeout      90;
proxy_buffers           32 4k;
EFO
echo "writing configure file"
cat <<EFO>> ${dir}/neoistone.conf
#copyright resverd by nginx neoistone
#this nginx webserver but some optimization php loading reduce time
#neoistone version 0.0.2
user  neoistone;
error_log  logs/error.log;
pid        logs/neoistone.pid;
worker_processes auto;
worker_rlimit_nofile 65535;
events {
    multi_accept on;
    use epoll;
    worker_connections 65535;
}
http {
    include    mime.types;
    include    proxy.conf;
    include    fastcgi.conf;
    default_type  application/octet-stream;
    index    index.htm index.html index.php index.php7 home.php home.php7 home.html home.htm home.cgi index.cgi;
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
   
    access_log  logs/access.log  main;
    charset     utf-8;
    sendfile    on;
    tcp_nopush  on;
    tcp_nodelay          on;
    types_hash_max_size  2048;
    server_names_hash_bucket_size 1024;
    client_body_timeout            30s; # Use 5s for high-traffic sites
    client_header_timeout          30s; # Use 5s for high-traffic sites
    open_file_cache                max=200000 inactive=20s;
    open_file_cache_errors         on;
    open_file_cache_min_uses       2;
    open_file_cache_valid          30s;
    port_in_redirect               off;
    reset_timedout_connection      on;
    server_name_in_redirect        off;
    server_names_hash_max_size     1024;
    server_tokens                  off;
    # Limits
    limit_req_log_level  warn;
    limit_req_zone       \$binary_remote_addr zone=login:10m rate=10r/m;
    # SSL
    ssl_session_timeout  1d;
    ssl_session_cache    shared:SSL:10m;
    ssl_session_tickets  off;
    keepalive_timeout  65;
    # gzip
    gzip              on;
    gzip_vary         on;
    gzip_proxied      any;
    gzip_comp_level   6;
    gzip_types        text/plain text/css text/xml application/json application/javascript application/rss+xml application/atom+xml image/svg+xml;
    # Mozilla Intermediate configuration
    ssl_protocols        TLSv1.2 TLSv1.3;
    ssl_ciphers          ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    # OCSP Stapling
    ssl_stapling         on;
    ssl_stapling_verify  on;
    resolver             1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4 9.9.9.9 208.67.222.222 208.67.220.220 8.26.56.26 valid=60s;
    resolver_timeout     2s;
    # security headers
     add_header X-Frame-Options           "SAMEORIGIN" always;
     add_header X-XSS-Protection          "1; mode=block" always;
     add_header X-Content-Type-Options    "nosniff" always;
     add_header Referrer-Policy           "no-referrer-when-downgrade" always;
     add_header Content-Security-Policy   "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
     add_header X-Nginx-Cache-Status     \$upstream_cache_status;
    
    include    conf.d/*.conf;
    include    conf.d/*/*.conf;
}
EFO
echo "writing root file"
cat <<EFO>> ${dir}/conf.d/root.conf
server {
    listen       80;
    server_name  localhost;
    root  /var/neoistone/defualt;
    
    error_page 404 /var/neoistone/defualt/404.html;
    error_page 500 502 503 504 /var/neoistone/defualt/50x.html;
    location = /50x.html {
        root /var/neoistone/defualt/html;
    }
}
EFO
mkdir /var/neoistone
mkdir /var/neoistone/defualt/
mkdir /var/neoistone/defualt/.well-known
mkdir /var/neoistone/defualt/.well-known/acme-challenge
if [[ -e /etc/systemd/system/neoistone.service ]]; then
  rm -rf /etc/systemd/system/neoistone.service
fi
cat <<EFO>> /etc/sysconfig/neoistone
# Command line options to use when starting nginx
#CLI_OPTIONS=""
EFO
cat <<EFO>> /etc/systemd/system/neoistone.service
[Unit]
Description=Neoistone offical webserver
Documentation=https://www.neoistone.com
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target
[Service]
Type=forking
EnvironmentFile=/etc/sysconfig/neoistone
ExecStartPre=${dir}/bin -t -c ${dir}/neoistone.conf
ExecStart=${dir}/bin -c ${dir}/neoistone.conf
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s TERM \$MAINPID
[Install]
WantedBy=multi-user.target
EFO
cat <<EFO>> /var/lib/neoistone
 echo ${dir}
EFO
chmod +x /var/lib/neoistone
chown neoistone:neoistone /var/neoistone/defualt/
yum install -y firewalld
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --zone=public --add-service=http
firewall-cmd --zone=public --add-service=https
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload
systemctl restart neoistone
systemctl enable neoistone
rm -rf ${cur_dir}/neoistone 
rm -rf ${cur_dir}/neoistone.sh
rm -rf ${cur_dir}/neoistone.tar.gz
 }
 mysql_install(){
   download_file https://raw.githubusercontent.com/neoistone/lempp/main/servers/mysql.sh
   password=`passwordgen`
   sh mysql.sh ${password} ${1}
   rm -rf mysql.sh
 }
 require_dir(){
 	mkdir /opt/neoistone/
 	mkdir /opt/neoistone/webserver
 	mkdir /opt/neoistone/mysql_data
 	mkdir /var/log/neoistone/
 	mkdir /var/neoistone
 	mkdir /var/neoistone/default
 	mkdir /var/neoistone/kitscart
 }
 phpsecure(){
 	yum install -y epel-release yum-utils
 	yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
 	yum-config-manager --enable remi-php ${1}
 	yum install -y php php-mysqlnd php5-bcmath php-cli php-common php-ctype php-devel php-embedded php-enchant php-fpm php-gd php-hash php-intl php-json php-ldap php-mbstring php-mysql php-odbc php-pdo php-pecl-jsonc phpu-pecl-memcache php-pgsql php-phar php-process php-pspell php-openssl php-recode php-snmp php-soap php-xml php-xmlrpc php-zlib php-zip php-opcache php-mcrypt php-curl
 	curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/bin --filename=composer
 	composer global require "phpunit/phpunit=4.3.*"
 	composer global require "phpunit/php-invoker"
 	composer global require "phpunit/dbunit": ">=1.2"
 	composer global require "phpunit/phpunit-selenium": ">=1.2"
 	sed -i 's/^user = apache/user = neoistone/i' /etc/php-fpm.d/www.conf
 	sed -i 's/^group = apache/group = neoistone/i' /etc/php-fpm.d/www.conf
 	sed -i 's/^listen = 127.0.0.1:9000/listen = /var/run/php-fpm/php-fpm.sock;/i' /etc/php-fpm.d/www.conf
 	sed -i 's/^;listen.owner = nobody/listen.owner = neoistone/i' /etc/php-fpm.d/www.conf
 	sed -i 's/^;listen.group = nobody/listen.group = neoistone/i' /etc/php-fpm.d/www.conf
 	sed -i 's/^;listen.mode = 0666/listen.mode = 0666/i' /etc/php-fpm.d/www.conf
 	systemctl start php-fpm
 }
 require_dir
 requirements_install 
 neoistone_installtion
 mysql_install /opt/neoistone/mysql_data
 phpsecure ${2}
