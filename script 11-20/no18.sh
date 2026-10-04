#!/bin/bash
# No.18 - Uji TTL 15 detik & cache DNS (abbey.k45.com)
#
# URUTAN:
#   1. Alpha : bash no18.sh setup     (pasang BIND sementara sebagai caching resolver)
#   2. Prab  : bash no18.sh ubah      (abbey -> 192.0.2.123, TTL 15, serial naik)
#   3. Alpha : bash no18.sh amati     (lihat TTL turun & IP baru; ulangi kalau perlu)
#   4. Prab  : bash no18.sh restore   (abbey balik 10.86.3.2 TTL 86400, serial naik)
#   5. Alpha : bash no18.sh hapus     (copot BIND sementara)
set -e
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
MODE=${1:-}
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

set_abbey() {     # $1=TTL  $2=IP
  grep -Eq '^abbey[[:space:]]+([0-9]+[[:space:]]+)?IN[[:space:]]+A[[:space:]]' "$ZONE" || { echo 'Record A abbey tidak ketemu.'; exit 1; }
  sed -i -E "s/^abbey[[:space:]]+([0-9]+[[:space:]]+)?IN[[:space:]]+A[[:space:]]+.*/abbey    $1    IN    A    $2/" "$ZONE"
  grep -n '^abbey' "$ZONE"
}

reload_named() {
  named-checkzone k45.com "$ZONE"
  pkill named || true
  sleep 2
  named
  sleep 2
}

show_both() {
  echo -n 'Prab: '; dig @10.86.5.2 k45.com SOA +short
  dig @10.86.5.2 abbey.k45.com A +noall +answer
  sleep 5
  echo -n 'Tedd: '; dig @10.86.5.3 k45.com SOA +short
  dig @10.86.5.3 abbey.k45.com A +noall +answer
}

case "$IP:$MODE" in
10.86.5.2:ubah)
  cp "$ZONE" "$ZONE.bak-q18"
  set_abbey 15 192.0.2.123
  bump_serial
  reload_named
  show_both
  echo 'Lanjut di Alpha: bash no18.sh amati'
  ;;

10.86.5.2:restore)
  # Serial HARUS naik lagi (jangan cp backup) supaya Tedd ikut balik.
  set_abbey 86400 10.86.3.2
  bump_serial
  reload_named
  show_both
  echo 'Lanjut di Alpha: bash no18.sh hapus'
  ;;

10.86.1.2:setup)
  apt update || true
  apt install bind9 -y
  cat > /etc/bind/named.conf.options <<'CONF'
options {
    directory "/var/cache/bind";

    listen-on { 10.86.1.2; };
    listen-on-v6 { none; };

    allow-query { 10.86.0.0/16; localhost; };

    recursion yes;

    forwarders {
        192.168.122.1;
    };
};
CONF
  cat > /etc/bind/named.conf.local <<'CONF'
zone "k45.com" {
    type forward;
    forward only;
    forwarders { 10.86.5.2; };
};
CONF
  named-checkconf
  pkill named 2>/dev/null || true
  sleep 1
  named
  sleep 2
  pgrep -a named
  dig @10.86.1.2 abbey.k45.com A +noall +answer
  echo 'Lanjut di Prab: bash no18.sh ubah'
  ;;

10.86.1.2:amati)
  for i in $(seq 1 20); do
    echo -n "[$i] "
    dig @10.86.1.2 abbey.k45.com A +noall +answer
    sleep 1
  done
  ;;

10.86.1.2:hapus)
  pkill named 2>/dev/null || true
  sleep 2
  apt remove bind9 bind9-utils dns-root-data -y
  pgrep -a named || echo 'BIND Alpha sudah tidak berjalan'
  ;;

*)
  echo "Pemakaian:"
  echo "  Alpha (10.86.1.2): bash no18.sh setup | amati | hapus"
  echo "  Prab  (10.86.5.2): bash no18.sh ubah  | restore"
  echo "IP terdeteksi: $IP, mode: '$MODE'"
  exit 1;;
esac

echo 'NO.18 SELESAI.'
