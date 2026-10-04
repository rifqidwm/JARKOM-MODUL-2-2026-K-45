#!/bin/bash
# No.17 - TXT record alpha..epsilon (isi TXT = nama hostnya)
# Node  : Prab (10.86.5.2) saja. Tedd (slave) ikut otomatis lewat zone transfer.
set -e
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
[ "$IP" = '10.86.5.2' ] || { echo 'No.17 hanya di Prab (10.86.5.2).'; exit 1; }

ZONE=${ZONE:-/etc/bind/zones/db.k45.com}

bump_serial() {   # serial ada di baris setelah baris SOA
  local ln old new
  ln=$(awk '/SOA/{print NR+1; exit}' "$ZONE")
  old=$(sed -n "${ln}p" "$ZONE" | awk '{print $1}')
  [[ "$old" =~ ^[0-9]+$ ]] || { echo "Serial SOA tidak terbaca: '$old'"; exit 1; }
  new=$((old+1))
  sed -i "${ln}s/${old}/${new}/" "$ZONE"
  echo "Serial SOA: $old -> $new"
}

cp "$ZONE" "$ZONE.bak-q17"

ADDED=0
for name in alpha beta gamma delta epsilon; do
  if ! grep -Eq "^${name}[[:space:]]+(.*[[:space:]])?TXT" "$ZONE"; then
    # TXT ditaruh tepat di bawah A record-nya
    sed -i "/^${name}[[:space:]].*[[:space:]]A[[:space:]]/a ${name}    IN    TXT    \"${name}\"" "$ZONE"
    ADDED=1
  fi
done

if [ "$ADDED" = 1 ]; then
  bump_serial
else
  echo 'TXT sudah ada semua, serial tidak diubah.'
fi

named-checkzone k45.com "$ZONE"

pkill named || true
sleep 2
named
sleep 2

echo '--- Serial & TXT ---'
echo -n 'Prab: '; dig @10.86.5.2 k45.com SOA +short
sleep 5
echo -n 'Tedd: '; dig @10.86.5.3 k45.com SOA +short
for h in alpha beta gamma delta epsilon; do
  echo "$h  prab=$(dig @10.86.5.2 $h.k45.com TXT +short)  tedd=$(dig @10.86.5.3 $h.k45.com TXT +short)"
done

echo 'NO.17 SELESAI.'
