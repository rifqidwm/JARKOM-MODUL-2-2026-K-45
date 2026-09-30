#!/bin/bash
set -e
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
[ "$IP" = '10.86.5.2' ] || { echo 'No.19 dijalankan di Prab (10.86.5.2).'; exit 1; }

ZONE=/etc/bind/db.k45.com
BACKUP="$ZONE.bak-script-no19"

echo '=== NO.19 - OUTBOUND CNAME ==='
cp "$ZONE" "$BACKUP"
if ! grep -Eq '^outbound[[:space:]]+IN[[:space:]]+CNAME[[:space:]]+http\.badssl\.com\.$' "$ZONE"; then
  sed -i '/^abbey[[:space:]]/a outbound    IN    CNAME    http.badssl.com.' "$ZONE"
  SERIAL=$(awk '/SOA/{getline; print $1; exit}' "$ZONE")
  NEW_SERIAL=$((SERIAL+1))
  sed -i "0,/$SERIAL/s//$NEW_SERIAL/" "$ZONE"
fi
named-checkzone k45.com "$ZONE"
pkill named || true; sleep 2; named; sleep 2

echo 'CNAME:'
dig @10.86.5.2 outbound.k45.com CNAME +short

echo 'Full DNS:'
dig @10.86.5.2 outbound.k45.com A +noall +answer

echo 'HTTP:'
curl -I --max-time 10 http://outbound.k45.com/ || true

echo 'NO.19 SELESAI.'
