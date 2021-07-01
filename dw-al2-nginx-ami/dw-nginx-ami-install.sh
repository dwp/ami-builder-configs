#! /bin/bash -v
# capture userdata output 
#exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Executables (Nginx) are pre-installed by Packer into the AMI. 
#

#Generate a self-signed cert & private key for NGINX SSL/TLS
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/certs/nginx.key -out /etc/ssl/certs/nginx.crt \
    -subj "/C=GB/ST=Greater London/L=London/O=DWP/CN=dca-dev-test.dwpcloud.uk"

#Replace NGINX DEFAULT config file with new config.
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.backup 

cat << 'EOF' > /etc/nginx/conf.d/default.conf
server {
    listen 443 ssl;
   # server_name ${MyDoiDomain};
    # Nginx Health check
     location /status {
        stub_status;
        allow all;
     }

    # Added modsecurity module
     modsecurity on;
     modsecurity_rules_file  /etc/nginx/modsec/main.conf;
    
    ssl_certificate     /etc/ssl/certs/nginx.crt;
    ssl_certificate_key /etc/ssl/certs/nginx.key;

    # DWP Hardening START
        # SSL protocols TLS v1~TLSv1.2 are allowed. Disabed SSLv3
            ssl_protocols  TLSv1.1 TLSv1.2;

        # enables server-side protection from BEAST attacks
            ssl_prefer_server_ciphers on;

        # Disabled insecure ciphers suite. For example, MD5, DES, RC4, PSK
        #After ITHC Report :ssl_ciphers "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4:@STRENGTH";
            ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
        # Only GET, Post, PUT are allowed In this case, it does not accept other HTTP method such as HEAD, DELETE, SEARCH, TRACE 
            if ($request_method !~ ^(GET|PUT|POST)$ ) {
                return 444;
            }
    # DWP Hardening END

    location / {
        #URL to send requests to. Doesn't handle the PORT on redirects.
        proxy_pass https://${MyAppAlbZone}:8443/;


    }
}
EOF

#Replace NGINX.config with new config.
#include "$host" in log file at /var/log/nginx/access.log 
#and forward headers
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup 

cat << 'EOF' > /etc/nginx/nginx.conf
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;
# Added modsecurity module
load_module modules/ngx_http_modsecurity_module.so;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$host" "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    #ßsendfile        on;
    #tcp_nopush     on;

    #gzip  on;

    # DWP Hardening START

        # Size Limits & Buffer Overflows 
        # the size may be configured based on the needs. 
        client_body_buffer_size  250000K;
        client_header_buffer_size 1000k;
        client_max_body_size 250000k;
        large_client_header_buffers 2 1000k;
        
        # Therefore, the version number should be removed for every http response.
        server_tokens off;

        # Timeouts definition 
        client_body_timeout   10;
        client_header_timeout 10;
        keepalive_timeout     5 5;
        send_timeout          10;
        
        #HTTP secure Header	 
        add_header X-Frame-Options SAMEORIGIN;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=31536000; includeSubdomains;";   

    # DWP Hardening END

    include /etc/nginx/conf.d/*.conf;
}

EOF

# ModSecurity Setting 
cat << 'EOF' > /etc/nginx/modsec/main.conf
Include /etc/nginx/modsec/modsecurity.conf
Include /etc/nginx/modsec/owasp-modsecurity-crs/crs-setup.conf
Include /etc/nginx/modsec/owasp-modsecurity-crs/rules/*.conf
EOF

# changing configuration file for ModSecurity (Disabled because Pega application got 403 Error)
#sed -i 's/SecRuleEngine DetectionOnly/#SecRuleEngine DetectionOnly/g' /etc/nginx/modsec/modsecurity.conf
#sed -i '/^#SecRuleEngine DetectionOnly/ a SecRuleEngine On' /etc/nginx/modsec/modsecurity.conf

# Modsecurity logs switched off 
sed -i 's/SecAuditEngine RelevantOnly/SecAuditEngine Off/g' /etc/nginx/modsec/modsecurity.conf



#NGINX FIX NGINX fails to start when Tomcat/Pega us unavailable - START

cd /root
cat << 'EOF' > scripts/start_nginx.sh
if ! pgrep -x "nginx" >/dev/null
then
    echo `date +"%Y-%m-%d %T"`; echo -n " nginx is not running, attempting to start... "; echo -n
    systemctl start nginx
    systemctl status nginx
else
    echo 'Nginx is Running at' `date +"%Y-%m-%d %T"`;
fi

EOF

chmod +x scripts/start_nginx.sh 
crontab -l | { cat; echo "* * * * * /root/scripts/start_nginx.sh | tee -a /var/log/start_nginx.sh.log"; } | crontab -

#NGINX FIX NGINX fails to start when Tomcat/Pega us unavailable - END





# Checking Nginx configuration and version
nginx -t
nginx -v
#Start NGINX
systemctl daemon-reload
systemctl enable nginx
systemctl start nginx
systemctl status nginx

# start filebeat and Node_exporter
systemctl start filebeat
systemctl status filebeat
systemctl start node_exporter
systemctl status node_exporter

# start GROK exporter
 #systemctl start nginx_grok
 #systemctl status nginx_grok

# File permissions changed  for Kibana purpose
chmod -R 755 /var/log

#Open Linux firewall  
setenforce 0 #SELinux blocks firewall config, so disable temporarily
# Nginx Port
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
# Grok exporter ports
sudo firewall-cmd --zone=public --add-port=9144/tcp --permanent
sudo firewall-cmd --zone=public --add-port=9145/tcp --permanent
# Node exporter 
sudo firewall-cmd --zone=public --add-port=9100/tcp --permanent
# Alertmanager etc
sudo firewall-cmd --zone=public --add-port=9090/tcp --permanent
sudo firewall-cmd --zone=public --add-port=9091/tcp --permanent
sudo firewall-cmd --zone=public --add-port=9106/tcp --permanent

sudo firewall-cmd --reload
sudo systemctl restart firewalld
sudo setenforce 1


