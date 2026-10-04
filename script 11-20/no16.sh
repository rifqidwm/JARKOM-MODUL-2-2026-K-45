#!/bin/bash
# No.16 - ApacheBench (250 request, concurrency 10)
# Node  : Alpha (10.86.1.2) saja
set -e
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
[ "$IP" = '10.86.1.2' ] || { echo 'No.16 hanya di Alpha (10.86.1.2).'; exit 1; }

# apt update boleh error (signature debian-security), paket tetap bisa terpasang
apt update || true
apt install apache2-utils -y
which ab
ab -V | head -1

echo '--- DNS ---'
getent hosts www.k45.com
getent hosts static.k45.com

echo '--- www.k45.com ---'
ab -n 250 -c 10 http://www.k45.com/

echo '--- static.k45.com ---'
ab -n 250 -c 10 http://static.k45.com/

echo 'NO.16 SELESAI.'
