#!/bin/bash
# =====================================================
# JARKOM MODUL 2 2026 - K45
# Soal 2 - Jalur keluar melalui NAT (dijalankan di rootkit)
# =====================================================
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

if [ "$HOST" != "rootkit" ]; then
  echo "Script ini hanya untuk node rootkit."
  exit 1
fi

say "Memastikan antarmuka WAN eth0 memakai DHCP"
grep -q "iface eth0 inet dhcp" /etc/network/interfaces || cat >> /etc/network/interfaces <<'EOF'

auto eth0
iface eth0 inet dhcp
EOF
service networking restart

say "Mengaktifkan IP forwarding dan aturan MASQUERADE"
echo 1 > /proc/sys/net/ipv4/ip_forward
which iptables >/dev/null 2>&1 || { apt update && apt install iptables -y; }
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE -s 10.86.0.0/16 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.86.0.0/16

say "Aturan NAT aktif"
iptables -t nat -L POSTROUTING -n

say "Uji akses keluar"
ip a show eth0 | grep inet
ping -c 3 google.com
