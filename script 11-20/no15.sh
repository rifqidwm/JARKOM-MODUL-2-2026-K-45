#!/bin/bash
# No.15 - /eternal (PHP-FPM) di Penny, /orion (statis, PHP tidak jalan) di Abbey
# Node  : Penny (10.86.4.2) & Abbey (10.86.3.2)
# Syarat: no11.sh sudah dijalankan di node yang sama.
set -e
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
apt update || true

case "$IP" in
10.86.4.2)
  echo '[PENNY] /eternal -> PHP-FPM'
  [ -e /etc/apache2/sites-enabled/reverse-proxy.conf ] || { echo 'Jalankan no11.sh dulu.'; exit 1; }
  apt install apache2 php-fpm -y
  a2enmod proxy_fcgi setenvif >/dev/null

  for s in /etc/init.d/php*-fpm; do "$s" restart || true; done
  PHPSOCK=$(ls /run/php/php*-fpm.sock 2>/dev/null | head -1)
  [ -S "$PHPSOCK" ] || { echo 'Socket PHP-FPM tidak ketemu di /run/php/.'; exit 1; }
  echo "Socket PHP-FPM: $PHPSOCK"

  mkdir -p /var/www/eternal
  cat > /var/www/eternal/index.php <<'PHP'
<?php
echo "ETERNAL PHP BERHASIL";
?>
PHP
  chown -R www-data:www-data /var/www/eternal
  chmod -R 755 /var/www/eternal

  mkdir -p /etc/apache2/k45-penny.d
  cat > /etc/apache2/k45-penny.d/20-eternal.conf <<'CONF'
ProxyPass "/eternal/" "!"

Alias /eternal/ /var/www/eternal/

<Directory /var/www/eternal>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
    DirectoryIndex index.php index.html

    <FilesMatch "\.php$">
        SetHandler "proxy:unix:__PHPSOCK__|fcgi://localhost/"
    </FilesMatch>
</Directory>
CONF
  sed -i "s#__PHPSOCK__#$PHPSOCK#" /etc/apache2/k45-penny.d/20-eternal.conf

  apache2ctl configtest
  apache2ctl -k graceful
  sleep 1
  echo '--- Tes /eternal/ (harus: ETERNAL PHP BERHASIL) ---'
  curl -s http://localhost/eternal/; echo
  ;;

10.86.3.2)
  echo '[ABBEY] /orion -> statis'
  grep -q 'k45-static.d' /etc/nginx/sites-available/default || { echo 'Jalankan no11.sh dulu.'; exit 1; }
  # Sisa dari versi lama (server block terpisah) bikin "/" berhenti diproxy -> hapus
  rm -f /etc/nginx/conf.d/orion.conf

  mkdir -p /var/www/orion
  cat > /var/www/orion/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Orion</title>
</head>
<body>
    <h1>ORION STATIC BERHASIL</h1>
</body>
</html>
HTML
  cat > /var/www/orion/test.php <<'PHP'
<?php
echo "PHP INI TIDAK BOLEH DIEKSEKUSI";
?>
PHP
  chown -R www-data:www-data /var/www/orion
  chmod -R 755 /var/www/orion

  # Di-include ke server block static.k45.com (BUKAN server block baru)
  mkdir -p /etc/nginx/k45-static.d
  cat > /etc/nginx/k45-static.d/orion.conf <<'CONF'
location ^~ /orion/ {
    root /var/www;
    index index.html;
    try_files $uri $uri/ =404;
}
CONF

  nginx -t
  nginx -s reload 2>/dev/null || service nginx restart
  sleep 1
  echo '--- /orion/ (harus ORION STATIC BERHASIL) ---'
  curl -s -H "Host: static.k45.com" http://127.0.0.1/orion/
  echo '--- /orion/test.php (harus tampil source PHP, tidak dieksekusi) ---'
  curl -s -H "Host: static.k45.com" http://127.0.0.1/orion/test.php
  echo '--- / harus tetap diproxy ke oblada/molly ---'
  curl -s -H "Host: static.k45.com" http://127.0.0.1/; echo
  ;;

*) echo "No.15 dijalankan di Penny (10.86.4.2) atau Abbey (10.86.3.2). IP terdeteksi: $IP"; exit 1;;
esac

echo 'NO.15 SELESAI.'
