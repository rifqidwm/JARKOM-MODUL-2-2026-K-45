#!/bin/bash
# No.12 - Basic Auth /admin
# Node  : Penny (10.86.4.2) saja
# Syarat: no11.sh sudah dijalankan. Password diketik sendiri (tidak disimpan di script).
set -e
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
[ "$IP" = '10.86.4.2' ] || { echo 'No.12 hanya di Penny (10.86.4.2).'; exit 1; }
[ -e /etc/apache2/sites-enabled/reverse-proxy.conf ] || { echo 'Jalankan no11.sh dulu.'; exit 1; }

apt install apache2-utils -y

# User prabs: dibuat hanya kalau belum ada
if ! grep -qs '^prabs:' /etc/apache2/.htpasswd; then
  echo 'Masukkan password untuk user prabs:'
  if [ -f /etc/apache2/.htpasswd ]; then
    htpasswd /etc/apache2/.htpasswd prabs
  else
    htpasswd -c /etc/apache2/.htpasswd prabs
  fi
fi

mkdir -p /var/www/admin
cat > /var/www/admin/index.html <<'HTML'
<h1>Admin Area - Penny</h1>
<p>Selamat datang di halaman admin.</p>
HTML

mkdir -p /etc/apache2/k45-penny.d
cat > /etc/apache2/k45-penny.d/10-admin.conf <<'CONF'
ProxyPass "/admin" "!"

Alias /admin /var/www/admin

<Directory /var/www/admin>
    AuthType Basic
    AuthName "Admin Area"
    AuthUserFile /etc/apache2/.htpasswd
    Require user prabs
</Directory>
CONF

apache2ctl configtest
service apache2 restart

echo '--- Tanpa login (harus 401) ---'
curl -si -H "Host: www.k45.com" http://10.86.4.2/admin | head -3
echo 'Tes login: curl -i -u prabs -H "Host: www.k45.com" http://10.86.4.2/admin/   (harus 200)'
echo 'NO.12 SELESAI.'
