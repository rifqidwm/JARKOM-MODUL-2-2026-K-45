#!/bin/bash
# No.13 - Canonical Redirect
# Node  : Penny (10.86.4.2) -> 301 ke www.k45.com
#         Abbey (10.86.3.2) -> 302 ke static.k45.com
# Syarat: no11.sh sudah dijalankan di node yang sama.
set -e
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)

case "$IP" in
10.86.4.2)
  [ -e /etc/apache2/sites-enabled/reverse-proxy.conf ] || { echo 'Jalankan no11.sh dulu.'; exit 1; }
  a2enmod rewrite >/dev/null
  mkdir -p /etc/apache2/k45-penny.d
  # Ada di dalam <VirtualHost> (lewat IncludeOptional), jadi RewriteRule berlaku.
  cat > /etc/apache2/k45-penny.d/05-redirect.conf <<'CONF'
RewriteEngine On

RewriteCond %{HTTP_HOST} ^penny\.k45\.com$ [NC,OR]
RewriteCond %{HTTP_HOST} ^10\.86\.4\.2$ [NC]
RewriteRule ^/(.*)$ http://www.k45.com/$1 [R=301,L]
CONF
  apache2ctl configtest
  service apache2 restart
  echo '--- Tes ---'
  curl -sI -H "Host: penny.k45.com" http://10.86.4.2/ | head -3
  curl -sI http://10.86.4.2/ | head -3
  ;;

10.86.3.2)
  [ -e /etc/nginx/sites-enabled/default ] || { echo 'Jalankan no11.sh dulu.'; exit 1; }
  cat > /etc/nginx/conf.d/k45-redirect.conf <<'CONF'
server {
    listen 80;
    listen [::]:80;

    server_name abbey.k45.com 10.86.3.2;

    return 302 http://static.k45.com$request_uri;
}
CONF
  nginx -t
  service nginx restart
  echo '--- Tes ---'
  curl -sI -H "Host: abbey.k45.com" http://10.86.3.2/ | head -3
  curl -sI http://10.86.3.2/ | head -3
  ;;

*) echo "No.13 dijalankan di Penny (10.86.4.2) atau Abbey (10.86.3.2). IP terdeteksi: $IP"; exit 1;;
esac

echo 'NO.13 SELESAI.'
