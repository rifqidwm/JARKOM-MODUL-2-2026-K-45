#!/bin/bash
# =====================================================
# JARKOM MODUL 2 2026 - K45
# Verifikasi menyeluruh soal 1 sampai 10
# =====================================================
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

which dig  >/dev/null 2>&1 || { apt update && apt install dnsutils -y; }
which curl >/dev/null 2>&1 || { apt update && apt install curl -y; }

say "1-3. Konektivitas dan akses keluar"
ping -c 2 10.86.5.1
ping -c 2 10.86.2.2
ping -c 2 google.com

say "4. Zona k45.com pada kedua name server"
dig @10.86.5.2 k45.com SOA +short
dig @10.86.5.3 k45.com SOA +short
dig k45.com +short

say "5. Domain per node"
for n in alpha beta gamma delta epsilon abbey penny prab tedd obladi desmond oblada molly; do
  printf "%-10s -> %s\n" "$n.k45.com" "$(dig $n.k45.com +short)"
done

say "6. Serial kedua name server harus sama"
echo "prab: $(dig @10.86.5.2 k45.com SOA +short | awk '{print $3}')"
echo "tedd: $(dig @10.86.5.3 k45.com SOA +short | awk '{print $3}')"

say "7. Endpoint vault, core, dan CNAME"
echo "vault  -> $(dig vault.k45.com +short | tr '\n' ' ')"
echo "core   -> $(dig core.k45.com +short | tr '\n' ' ')"
echo "www    -> $(dig www.k45.com +short | tr '\n' ' ')"
echo "static -> $(dig static.k45.com +short | tr '\n' ' ')"

say "8. Pencarian balik"
for ip in 10.86.3.2 10.86.4.2 10.86.5.4 10.86.5.5 10.86.5.6 10.86.5.7; do
  printf "%-12s -> %s\n" "$ip" "$(dig -x $ip +short)"
done

say "9. Web statis dengan autoindex"
curl -s http://vault.k45.com/arsip/ | grep -E "Index of|\.txt|Server at"

say "10. Web dinamis dengan URL bersih"
curl -s http://core.k45.com/ ; echo ""
curl -s http://core.k45.com/profil ; echo ""
