
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

say "Hostname"
hostname rootkit
echo rootkit > /etc/hostname
grep -q "127.0.1.1 rootkit" /etc/hosts || echo "127.0.1.1 rootkit" >> /etc/hosts

say "Alamat IP seluruh antarmuka (soal 1 dan 2)"
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

say "IP forwarding dan NAT (soal 2)"
echo 1 > /proc/sys/net/ipv4/ip_forward
which iptables >/dev/null 2>&1 || { apt update && apt install iptables -y; }
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE -s 10.86.0.0/16 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.86.0.0/16

say "Hasil"
ip a | grep -E "^[0-9]+: |inet "
ping -c 3 google.com
