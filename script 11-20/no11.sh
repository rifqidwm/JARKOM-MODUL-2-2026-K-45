#!/bin/bash
# No.11 - Reverse Proxy & Load Balancer
# Node  : Penny (10.86.4.2)  -> Apache, backend Obladi + Desmond
#         Abbey (10.86.3.2)  -> Nginx,  backend Oblada + Molly
# Urutan: jalankan PERTAMA di Penny dan Abbey (no12/13/15 butuh ini).
set -e
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
apt update || true

case "$IP" in
10.86.4.2)
  echo '[PENNY] Apache -> Obladi + Desmond'
  apt install apache2 -y
  a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers rewrite
  mkdir -p /etc/apache2/k45-penny.d

  cat > /etc/apache2/sites-available/reverse-proxy.conf <<'CONF'
<VirtualHost *:80>
    ServerName www.k45.com
    ServerAlias penny.k45.com 10.86.4.2

    ProxyPreserveHost On
    RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}

    <Proxy "balancer://vault">
        BalancerMember http://10.86.5.4
        BalancerMember http://10.86.5.5
        ProxySet lbmethod=byrequests
    </Proxy>

    # Tambahan no12 (/admin), no13 (redirect), no15 (/eternal) masuk lewat sini.
    # HARUS sebelum ProxyPass "/".
    IncludeOptional /etc/apache2/k45-penny.d/*.conf

    ProxyPass "/" "balancer://vault/"
    ProxyPassReverse "/" "balancer://vault/"

    ErrorLog ${APACHE_LOG_DIR}/vault-proxy-error.log
    CustomLog ${APACHE_LOG_DIR}/vault-proxy-access.log combined
</VirtualHost>
CONF

  a2dissite 000-default.conf >/dev/null 2>&1 || true
  a2ensite reverse-proxy.conf >/dev/null
  apache2ctl configtest
  service apache2 restart

  echo '--- Tes load balancing (harus gantian obladi/desmond) ---'
  for i in 1 2 3 4 5 6; do
    curl -s -H "Host: www.k45.com" http://10.86.4.2/arsip/dokumen1.txt
  done
  ;;

10.86.3.2)
  echo '[ABBEY] Nginx -> Oblada + Molly'
  apt install nginx -y
  mkdir -p /etc/nginx/k45-static.d

  cat > /etc/nginx/sites-available/default <<'CONF'
upstream core_backend {
    server 10.86.5.6;
    server 10.86.5.7;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name static.k45.com;

    # Tambahan no15 (/orion) masuk lewat sini, di server block YANG SAMA.
    include /etc/nginx/k45-static.d/*.conf;

    location / {
        proxy_pass http://core_backend;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
CONF

  nginx -t
  service nginx restart

  echo '--- Tes load balancing (harus gantian oblada/molly) ---'
  for i in 1 2 3 4 5 6; do
    curl -s -H "Host: static.k45.com" http://10.86.3.2/profil; echo
  done
  ;;

*) echo "No.11 dijalankan di Penny (10.86.4.2) atau Abbey (10.86.3.2). IP terdeteksi: $IP"; exit 1;;
esac

echo 'NO.11 SELESAI.'
