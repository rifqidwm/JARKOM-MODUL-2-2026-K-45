#!/bin/bash
# =====================================================
# JARKOM MODUL 2 2026 - K45
# Soal 6 - Verifikasi zone transfer prab ke tedd
# =====================================================
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

which dig >/dev/null 2>&1 || { apt update && apt install dnsutils -y; }

say "Serial SOA pada prab"
dig @10.86.5.2 k45.com SOA +short

say "Serial SOA pada tedd"
dig @10.86.5.3 k45.com SOA +short

echo ""
echo "Kedua nilai Serial di atas harus sama."

if [ "$HOST" = "tedd" ]; then
  say "tedd: menarik seluruh isi zona dari master"
  dig @10.86.5.2 k45.com AXFR

  say "Berkas salinan zona di tedd"
  ls -l /var/cache/bind/db.k45.com
else
  echo ""
  echo "Untuk bukti AXFR dan berkas salinan, jalankan script ini di node tedd."
fi
