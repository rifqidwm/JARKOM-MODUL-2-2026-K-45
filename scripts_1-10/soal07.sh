#!/bin/bash
# =====================================================
# JARKOM MODUL 2 2026 - K45
# Soal 7 - Endpoint vault, core, dan CNAME
# =====================================================
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

if [ "$HOST" = "prab" ]; then
  say "prab: menulis ulang zona dengan endpoint web (serial dinaikkan)"
  cat > /etc/bind/zones/db.k45.com <<'EOF'
$TTL 604800
@   IN  SOA prab.k45.com. admin.k45.com. (
        2026092803
        604800
        86400
        2419200
        604800 )
;
@       IN  NS  prab.k45.com.
@       IN  NS  tedd.k45.com.
@       IN  A   10.86.4.2
prab    IN  A   10.86.5.2
tedd    IN  A   10.86.5.3
rootkit IN  A   10.86.5.1
alpha   IN  A   10.86.1.2
beta    IN  A   10.86.1.3
gamma   IN  A   10.86.1.4
delta   IN  A   10.86.2.2
epsilon IN  A   10.86.2.3
abbey   IN  A   10.86.3.2
penny   IN  A   10.86.4.2
obladi  IN  A   10.86.5.4
desmond IN  A   10.86.5.5
oblada  IN  A   10.86.5.6
molly   IN  A   10.86.5.7
vault   IN  A       10.86.5.4
vault   IN  A       10.86.5.5
core    IN  A       10.86.5.6
core    IN  A       10.86.5.7
www     IN  CNAME   penny.k45.com.
static  IN  CNAME   abbey.k45.com.
EOF

  named-checkzone k45.com /etc/bind/zones/db.k45.com
  service named restart || service bind9 restart
  sleep 2
fi

which dig >/dev/null 2>&1 || { apt update && apt install dnsutils -y; }

say "Verifikasi dari node $HOST"
echo "--- vault.k45.com (obladi dan desmond) ---"
dig vault.k45.com +short
echo "--- core.k45.com (oblada dan molly) ---"
dig core.k45.com +short
echo "--- www.k45.com (CNAME ke penny) ---"
dig www.k45.com +short
echo "--- static.k45.com (CNAME ke abbey) ---"
dig static.k45.com +short

echo ""
echo "Jalankan script ini pada dua klien berbeda, hasilnya harus konsisten."
