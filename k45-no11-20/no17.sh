#!/bin/bash
set -e
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
[ "$IP" = '10.86.5.2' ] || { echo 'No.17 dijalankan di Prab (10.86.5.2).'; exit 1; }

echo '=== NO.17 - TXT RECORDS ==='
ZONE=/etc/bind/db.k45.com
cp "$ZONE" "$ZONE.bak-script-no17"
for name in alpha beta gamma delta epsilon; do
  if ! grep -Eq "^${name}[[:space:]]+IN[[:space:]]+TXT" "$ZONE"; then
    sed -i "/^abbey[[:space:]]/i ${name}    IN    TXT    \"${name}\"" "$ZONE"
  fi
done
# Naikkan serial hanya jika TXT baru ditambahkan sejak script terakhir.
if ! grep -Eq '^alpha[[:space:]]+IN[[:space:]]+TXT' "$ZONE" || ! grep -Eq '^epsilon[[:space:]]+IN[[:space:]]+TXT' "$ZONE"; then
  echo 'TXT gagal ditambahkan.'; exit 1
fi
named-checkzone k45.com "$ZONE"
pkill named || true
sleep 2
named
sleep 2
for n in alpha beta gamma delta epsilon; do dig @10.86.5.2 "$n.k45.com" TXT +short; done

echo 'CATATAN: Jika TXT baru ditambahkan pada zone yang sudah lama serialnya, naikkan serial SOA secara manual sesuai state terakhir sebelum deploy ulang.'
echo 'NO.17 SELESAI.'
