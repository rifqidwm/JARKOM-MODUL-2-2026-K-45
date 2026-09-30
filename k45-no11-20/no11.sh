#!/bin/bash
set -e
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
if [ "$EUID" -ne 0 ]; then echo 'Jalankan sebagai root.'; exit 1; fi

echo "=== NO.11 - REVERSE PROXY / LOAD BALANCER ==="

case "$IP" in
10.86.4.2)
  echo '[PENNY] Apache -> Obladi + Desmond'
  apt install apache2 -y
  a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers rewrite
  cat > /etc/apache2/sites-available/penny-reverse.conf <<'CONF'
<VirtualHost *:80>
    ServerName www.k45.com
    ServerAlias penny.k45.com 10.86.4.2

    ProxyPreserveHost On
    RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}

    ProxyPass "/admin" "!"
    ProxyPass "/eternal" "!"

    <Proxy "balancer://vault">
        BalancerMember "http://10.86.5.4/"
        BalancerMember "http://10.86.5.5/"
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPass "/" "balancer://vault/"
    ProxyPassReverse "/" "balancer://vault/"
</VirtualHost>
CONF
  a2ensite penny-reverse.conf >/dev/null
  apache2ctl configtest
  service apache2 restart
  ;;
10.86.3.2)
  echo '[ABBEY] Nginx -> Oblada + Molly'
  apt install nginx -y
  cat > /etc/nginx/sites-available/default <<'CONF'
upstream core_backend {
    server 10.86.5.6;
    server 10.86.5.7;
}

server {
    listen 80;
    listen [::]:80;
    server_name static.k45.com;

    location / {
        proxy_pass http://core_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
CONF
  nginx -t
  service nginx restart
  ;;
*) echo "IP node $IP tidak cocok untuk No.11. Jalankan di Penny (10.86.4.2) atau Abbey (10.86.3.2)."; exit 1;;
esac

echo 'NO.11 SELESAI.'
