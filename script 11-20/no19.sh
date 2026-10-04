#!/bin/bash
# No.19 - CNAME outbound.k45.com -> http.badssl.com
# Node  : Prab (10.86.5.2) -> konfigurasi
#         Alpha (10.86.1.2) -> pengujian (dig + curl)
set -e
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
ZONE=${ZONE:-/etc/bind/db.k45.com}

bump_serial() {
  local ln old new
  ln=$(awk '/SOA/{print NR+1; exit}' "$ZONE")
  old=$(sed -n "${ln}p" "$ZONE" | awk '{print $1}')
  [[ "$old" =~ ^[0-9]+$ ]] || { echo "Serial SOA tidak terbaca: '$old'"; exit 1; }
  new=$((old+1))
  sed -i "${ln}s/${old}/${new}/" "$ZONE"
  echo "Serial SOA: $old -> $new"
}

case "$IP" in
10.86.5.2)
  cp "$ZONE" "$ZONE.bak-q19"
  if grep -Eq '^outbound[[:space:]]' "$ZONE"; then
    echo 'Record outbound sudah ada, tidak ditambah lagi.'
  else
    sed -i '/^abbey[[:space:]].*[[:space:]]A[[:space:]]/a outbound    IN    CNAME    http.badssl.com.' "$ZONE"
    bump_serial
  fi
  grep -n '^outbound' "$ZONE"
  named-checkzone k45.com "$ZONE"

  pkill named || true
  sleep 2
  named
  sleep 2

  echo -n 'Prab: '; dig @10.86.5.2 k45.com SOA +short
  dig @10.86.5.2 outbound.k45.com CNAME +noall +answer
  sleep 5
  echo -n 'Tedd: '; dig @10.86.5.3 k45.com SOA +short
  dig @10.86.5.3 outbound.k45.com CNAME +noall +answer
  echo 'Lanjut di Alpha: bash no19.sh'
  ;;

10.86.1.2)
  echo '--- CNAME ---'
  dig outbound.k45.com CNAME +noall +answer
  echo '--- A (ikut CNAME) ---'
  dig outbound.k45.com A +noall +answer
  echo '--- HTTP via outbound.k45.com (bisa 503 Web Page Blocked = filter jaringan, bukan salah DNS) ---'
  curl -sI --max-time 10 http://outbound.k45.com/ | head -3 || true
  echo '--- HTTP langsung http.badssl.com ---'
  curl -sI --max-time 10 http://http.badssl.com/ | head -3 || true
  ;;

*) echo "No.19: Prab (10.86.5.2) untuk konfigurasi, Alpha (10.86.1.2) untuk uji. IP terdeteksi: $IP"; exit 1;;
esac

echo 'NO.19 SELESAI.'
