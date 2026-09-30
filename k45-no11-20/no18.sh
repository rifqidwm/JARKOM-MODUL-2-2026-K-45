#!/bin/bash
set -e
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
[ "$IP" = '10.86.5.2' ] || { echo 'No.18 konfigurasi utama dijalankan di Prab (10.86.5.2).'; exit 1; }

ZONE=/etc/bind/db.k45.com
BACKUP="$ZONE.bak-script-no18"
OLD='10.86.3.2'
NEW='192.0.2.123'

echo '=== NO.18 - DNS TTL/CACHE TEST ==='
cp "$ZONE" "$BACKUP"

# Pastikan state awal normal.
sed -i -E 's/^(abbey)[[:space:]]+[0-9]+[[:space:]]+IN[[:space:]]+A[[:space:]]+.*/abbey    86400    IN    A    10.86.3.2/' "$ZONE"

SERIAL=$(awk '/SOA/{getline; print $1; exit}' "$ZONE")
NEW_SERIAL=$((SERIAL+1))
sed -i "0,/$SERIAL/s//$NEW_SERIAL/" "$ZONE"
named-checkzone k45.com "$ZONE"
pkill named || true; sleep 2; named; sleep 2

echo 'State normal sebelum perubahan:'
dig @10.86.5.2 abbey.k45.com A +noall +answer

# Ubah menjadi fake/documentation IP dengan TTL 15 detik.
sed -i -E 's/^(abbey)[[:space:]]+[0-9]+[[:space:]]+IN[[:space:]]+A[[:space:]]+.*/abbey    15    IN    A    192.0.2.123/' "$ZONE"
SERIAL2=$((NEW_SERIAL+1))
sed -i "0,/$NEW_SERIAL/s//$SERIAL2/" "$ZONE"
named-checkzone k45.com "$ZONE"
pkill named || true; sleep 2; named; sleep 2

echo 'State setelah perubahan:'
dig @10.86.5.2 abbey.k45.com A +noall +answer
sleep 16

echo 'Setelah TTL 15 detik:'
dig @10.86.5.2 abbey.k45.com A +noall +answer

# RESTORE WAJIB ke koordinat normal.
cp "$BACKUP" "$ZONE"
named-checkzone k45.com "$ZONE"
pkill named || true; sleep 2; named; sleep 2

echo 'State RESTORE:'
dig @10.86.5.2 abbey.k45.com A +noall +answer

echo 'NO.18 SELESAI DAN STATE ABBEY SUDAH NORMAL KEMBALI.'
echo 'Catatan: fase cached-old vs new TTL harus diuji melalui resolver caching seperti Alpha; script ini menjaga perubahan master dan restore.'
