runpath=`pwd`
wget https://raw.githubusercontent.com/neoistone/lempp/main/servers/neoistone.tar.gz
tar xvf neoistone.tar.gz
cd neoistone
useradd --system --home /var/cache/neoistone --shell /sbin/nologin --comment "neoistone user" --user-group neoistone
useradd neoistone
dir="/etc/neoistone"
[ -z "${1}" ] && dir="/etc/neoistone" || dir=${1}
if [[ -e ${dir} ]]; then
    echo "Already install in this server start service or uninstall webserver"
    break;
else
    mkdir ${dir}
fi
echo "install neoistone"
./configure   --user=neoistone --group=neoistone\
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
echo "unwanted file removing"
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
#copyright resverd by nginx
#modify neoistone
#this nginx webserver but some optimization php reduce the server response
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
    #thank you using neoistone control panel 
}
EFO
echo "writing root file"
cat <<EFO>> ${dir}/conf.d/root.conf
server {
    listen       80;
    server_name  localhost;
    root  /var/www/html;
    
    error_page 404 /var/www/html/404.html;
    error_page 500 502 503 504 /var/www/html/50x.html;

    location = /50x.html {
        root /var/www/html;
    }
}
EFO
mkdir /var/www
mkdir /var/www/html/
mkdir /var/www/html/.well-known
mkdir /var/www/html/.well-known/acme-challenge
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
cat <<EFO>> /opt/var
 echo ${dir}
EFO
chmod +x /opt/var
chown neoistone:neoistone /var/www/html/
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
rm -rf ${runpath}/neoistone 
rm -rf ${runpath}/neoistone.sh
rm -rf ${runpath}/neoistone.tar.gz
