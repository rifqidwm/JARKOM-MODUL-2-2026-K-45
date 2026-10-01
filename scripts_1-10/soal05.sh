#!/bin/bash
# =====================================================
# JARKOM MODUL 2 2026 - K45
# Soal 5 - Penamaan Entitas dan domain per node
# =====================================================
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

# Bagian 1: hostname. Jalankan dengan argumen nama node bila hostname belum sesuai.
TARGET="${1:-$HOST}"
case "$TARGET" in
  rootkit|alpha|beta|gamma|delta|epsilon|abbey|penny|prab|tedd|obladi|desmond|oblada|molly)
    say "Menetapkan hostname: $TARGET"
    hostname "$TARGET"
    echo "$TARGET" > /etc/hostname
    grep -q "127.0.1.1 $TARGET" /etc/hosts || echo "127.0.1.1 $TARGET" >> /etc/hosts
    hostname
    ;;
  *)
    echo "Nama node tidak dikenal: $TARGET"
    echo "Contoh: ./soal05-hostname-domain.sh alpha"
    exit 1
    ;;
esac

# Bagian 2: A record seluruh node, hanya dijalankan di prab
if [ "$TARGET" = "prab" ]; then
  say "prab: menulis ulang zona dengan A record seluruh node (serial dinaikkan)"
  cat > /etc/bind/zones/db.k45.com <<'EOF'
$TTL 604800
@   IN  SOA prab.k45.com. admin.k45.com. (
        2026092802
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
EOF

  named-checkzone k45.com /etc/bind/zones/db.k45.com
  service named restart || service bind9 restart
  sleep 2
  say "Uji beberapa domain node"
  dig @127.0.0.1 alpha.k45.com +short
  dig @127.0.0.1 molly.k45.com +short
  dig @127.0.0.1 abbey.k45.com +short
else
  say "Uji resolusi domain node"
  which dig >/dev/null 2>&1 && {
    dig alpha.k45.com +short
    dig molly.k45.com +short
    dig abbey.k45.com +short
  }
fi
