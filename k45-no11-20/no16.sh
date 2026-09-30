#!/bin/bash
set -e
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
[ "$IP" = '10.86.1.2' ] || { echo 'No.16 dijalankan di Alpha (10.86.1.2).'; exit 1; }

echo '=== NO.16 - APACHE BENCH ==='
apt update
apt install apache2-utils -y
which ab
ab -V

echo '--- www.k45.com ---'
ab -n 250 -c 10 http://www.k45.com/

echo '--- static.k45.com ---'
ab -n 250 -c 10 http://static.k45.com/

echo 'NO.16 SELESAI.'
