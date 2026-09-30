#!/bin/bash
set -e
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }

echo '=== NO.15 - PHP / ETERNAL DAN STATIC / ORION ==='
case "$IP" in
10.86.4.2)
  apt install apache2 php-fpm -y
  mkdir -p /var/www/eternal
  cat > /var/www/eternal/index.php <<'PHP'
<?php
echo "ETERNAL PHP BERHASIL";
?>
PHP
  cat > /etc/apache2/conf-available/k45-eternal.conf <<'CONF'
ProxyPass "/eternal/" "!"
Alias /eternal/ /var/www/eternal/
<Directory /var/www/eternal>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
    DirectoryIndex index.php index.html
    <FilesMatch "\.php$">
        SetHandler "proxy:unix:/run/php/php8.4-fpm.sock|fcgi://localhost/"
    </FilesMatch>
</Directory>
CONF
  a2enmod proxy_fcgi setenvif >/dev/null
  a2enconf k45-eternal >/dev/null
  apache2ctl configtest
  service php8.4-fpm restart 2>/dev/null || service php-fpm restart
  service apache2 restart
  curl -s http://localhost/eternal/
  ;;
10.86.3.2)
  apt install nginx -y
  mkdir -p /var/www/orion
  cat > /var/www/orion/index.html <<'HTML'
<!DOCTYPE html>
<html><head><title>Orion</title></head><body><h1>ORION STATIC BERHASIL</h1></body></html>
HTML
  cat > /var/www/orion/test.php <<'PHP'
<?php
echo "PHP INI TIDAK BOLEH DIEKSEKUSI";
?>
PHP
  cat > /etc/nginx/conf.d/k45-orion.conf <<'CONF'
server {
    listen 80;
    listen [::]:80;
    server_name static.k45.com;
    location ^~ /orion/ {
        root /var/www;
        index index.html;
        try_files $uri $uri/ =404;
    }
}
CONF
  nginx -t
  service nginx restart
  echo
  curl -s http://localhost/orion/
  echo
  echo 'PHP source check:'
  curl -s http://localhost/orion/test.php
  echo
  ;;
*) echo 'No.15 dijalankan di Penny dan Abbey.'; exit 1;;
esac

echo 'NO.15 SELESAI.'
