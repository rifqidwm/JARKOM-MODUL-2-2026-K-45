#!/bin/bash
set -e
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
[ "$IP" = '10.86.4.2' ] || { echo 'No.12 dijalankan di Penny (10.86.4.2).'; exit 1; }

echo '=== NO.12 - BASIC AUTH /admin ==='
apt install apache2 apache2-utils -y
mkdir -p /var/www/admin
cat > /var/www/admin/index.html <<'HTML'
<!DOCTYPE html><html><body><h1>ADMIN AREA</h1></body></html>
HTML

if [ ! -f /etc/apache2/.htpasswd ]; then
  echo 'File .htpasswd belum ada. Buat user prabs sekarang:'
  htpasswd -c /etc/apache2/.htpasswd prabs
elif ! htpasswd -v /etc/apache2/.htpasswd prabs >/dev/null 2>&1; then
  echo 'User prabs belum ada. Masukkan password untuk user prabs:'
  htpasswd /etc/apache2/.htpasswd prabs
fi

cat > /etc/apache2/conf-available/k45-admin.conf <<'CONF'
Alias /admin /var/www/admin
<Directory /var/www/admin>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require valid-user
    AuthType Basic
    AuthName "K45 Admin"
    AuthUserFile /etc/apache2/.htpasswd
</Directory>
CONF

a2enconf k45-admin >/dev/null
apache2ctl configtest
service apache2 restart

echo 'Cek: curl -I http://penny.k45.com/admin/'
echo 'NO.12 SELESAI.'
