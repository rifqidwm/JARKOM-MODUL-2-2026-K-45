#!/bin/bash
# =====================================================
# JARKOM MODUL 2 2026 - K45
# Soal 9 - Web statis Apache dengan autoindex (area vault)
# =====================================================
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

case "$HOST" in
  obladi|desmond)
    say "$HOST: memasang Apache dan mengaktifkan autoindex"
apt update
apt install apache2 -y

mkdir -p /var/www/html/arsip
echo "Arsip $(hostname) - dokumen 1" > /var/www/html/arsip/dokumen1.txt
echo "Arsip $(hostname) - dokumen 2" > /var/www/html/arsip/dokumen2.txt
echo "Arsip $(hostname) - catatan"   > /var/www/html/arsip/catatan.txt

cat > /etc/apache2/conf-available/arsip.conf <<'EOF'
<Directory /var/www/html/arsip>
    Options +Indexes
    AllowOverride None
    Require all granted
</Directory>
EOF

a2enmod autoindex
a2enconf arsip
service apache2 restart

    say "Uji lokal"
    curl -s http://localhost/arsip/ | head -20
    ;;
  *)
    say "Verifikasi dari node $HOST melalui hostname"
    which curl >/dev/null 2>&1 || { apt update && apt install curl -y; }
    echo "--- vault.k45.com ---"
    curl -s http://vault.k45.com/arsip/ | grep -E "Index of|\.txt|Server at"
    echo "--- obladi.k45.com ---"
    curl -s http://obladi.k45.com/arsip/ | grep -E "Index of|\.txt|Server at"
    echo "--- desmond.k45.com ---"
    curl -s http://desmond.k45.com/arsip/ | grep -E "Index of|\.txt|Server at"
    ;;
esac
