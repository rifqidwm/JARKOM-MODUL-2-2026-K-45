#!/bin/bash
# =====================================================
# JARKOM MODUL 2 2026 - K45
# Soal 3 - Routing internal dan resolver awal
# =====================================================
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

if [ "$HOST" = "rootkit" ]; then
  say "rootkit: memastikan forwarding aktif"
  echo 1 > /proc/sys/net/ipv4/ip_forward
  say "Tabel routing"
  ip route
  echo "Resolver rootkit dibiarkan mengikuti NAT."
  exit 0
fi

say "Menetapkan resolver awal 192.168.122.1"
echo "nameserver 192.168.122.1" > /etc/resolv.conf
cat /etc/resolv.conf

which ping >/dev/null 2>&1 || { apt update && apt install iputils-ping -y; }

say "Uji komunikasi lintas segmen"
ping -c 2 10.86.1.1
ping -c 2 10.86.5.2
say "Uji akses keluar"
ping -c 2 google.com
