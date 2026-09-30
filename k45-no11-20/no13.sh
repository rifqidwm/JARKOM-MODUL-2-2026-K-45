#!/bin/bash
set -e
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }

echo '=== NO.13 - CANONICAL REDIRECT ==='
case "$IP" in
10.86.4.2)
  cat > /etc/apache2/conf-available/k45-redirect.conf <<'CONF'
RewriteEngine On
RewriteCond %{HTTP_HOST} ^penny\.k45\.com$ [NC,OR]
RewriteCond %{HTTP_HOST} ^10\.86\.4\.2$ [NC]
RewriteRule ^/(.*)$ http://www.k45.com/$1 [R=301,L]
CONF
  a2enmod rewrite >/dev/null
  a2enconf k45-redirect >/dev/null
  apache2ctl configtest
  service apache2 restart
  echo 'Penny: 301 -> http://www.k45.com/'
  ;;
10.86.3.2)
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
  echo 'Abbey: 302 -> http://static.k45.com'
  ;;
*) echo 'Jalankan di Penny atau Abbey.'; exit 1;;
esac

echo 'NO.13 SELESAI.'
