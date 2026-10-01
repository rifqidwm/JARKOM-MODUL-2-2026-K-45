#!/bin/bash
# =====================================================
# JARKOM MODUL 2 2026 - K45
# Soal 1 - Pengalamatan IP dan default gateway
# =====================================================
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

case "$HOST" in
  rootkit)
    say "rootkit: IP statis pada eth1-eth5"
cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
  address 10.86.1.1
  netmask 255.255.255.0

auto eth2
iface eth2 inet static
  address 10.86.2.1
  netmask 255.255.255.0

auto eth3
iface eth3 inet static
  address 10.86.3.1
  netmask 255.255.255.0

auto eth4
iface eth4 inet static
  address 10.86.4.1
  netmask 255.255.255.0

auto eth5
iface eth5 inet static
  address 10.86.5.1
  netmask 255.255.255.0
EOF
service networking restart
    ;;
  alpha)
    say "alpha: IP 10.86.1.2 gateway 10.86.1.1"
    cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address 10.86.1.2
  netmask 255.255.255.0
  gateway 10.86.1.1
EOF
    service networking restart
    ;;
  beta)
    say "beta: IP 10.86.1.3 gateway 10.86.1.1"
    cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address 10.86.1.3
  netmask 255.255.255.0
  gateway 10.86.1.1
EOF
    service networking restart
    ;;
  gamma)
    say "gamma: IP 10.86.1.4 gateway 10.86.1.1"
    cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address 10.86.1.4
  netmask 255.255.255.0
  gateway 10.86.1.1
EOF
    service networking restart
    ;;
  delta)
    say "delta: IP 10.86.2.2 gateway 10.86.2.1"
    cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address 10.86.2.2
  netmask 255.255.255.0
  gateway 10.86.2.1
EOF
    service networking restart
    ;;
  epsilon)
    say "epsilon: IP 10.86.2.3 gateway 10.86.2.1"
    cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address 10.86.2.3
  netmask 255.255.255.0
  gateway 10.86.2.1
EOF
    service networking restart
    ;;
  abbey)
    say "abbey: IP 10.86.3.2 gateway 10.86.3.1"
    cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address 10.86.3.2
  netmask 255.255.255.0
  gateway 10.86.3.1
EOF
    service networking restart
    ;;
  penny)
    say "penny: IP 10.86.4.2 gateway 10.86.4.1"
    cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address 10.86.4.2
  netmask 255.255.255.0
  gateway 10.86.4.1
EOF
    service networking restart
    ;;
  prab)
    say "prab: IP 10.86.5.2 gateway 10.86.5.1"
    cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address 10.86.5.2
  netmask 255.255.255.0
  gateway 10.86.5.1
EOF
    service networking restart
    ;;
  tedd)
    say "tedd: IP 10.86.5.3 gateway 10.86.5.1"
    cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address 10.86.5.3
  netmask 255.255.255.0
  gateway 10.86.5.1
EOF
    service networking restart
    ;;
  obladi)
    say "obladi: IP 10.86.5.4 gateway 10.86.5.1"
    cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address 10.86.5.4
  netmask 255.255.255.0
  gateway 10.86.5.1
EOF
    service networking restart
    ;;
  desmond)
    say "desmond: IP 10.86.5.5 gateway 10.86.5.1"
    cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address 10.86.5.5
  netmask 255.255.255.0
  gateway 10.86.5.1
EOF
    service networking restart
    ;;
  oblada)
    say "oblada: IP 10.86.5.6 gateway 10.86.5.1"
    cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address 10.86.5.6
  netmask 255.255.255.0
  gateway 10.86.5.1
EOF
    service networking restart
    ;;
  molly)
    say "molly: IP 10.86.5.7 gateway 10.86.5.1"
    cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address 10.86.5.7
  netmask 255.255.255.0
  gateway 10.86.5.1
EOF
    service networking restart
    ;;
  *)
    echo "Hostname belum dikenali. Set hostname lebih dulu, lalu jalankan ulang."
    exit 1
    ;;
esac

say "Hasil"
ip a | grep -E "^[0-9]+: |inet "
