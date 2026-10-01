
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

say "Hostname"
hostname penny
echo penny > /etc/hostname
grep -q "127.0.1.1 penny" /etc/hosts || echo "127.0.1.1 penny" >> /etc/hosts

say "Alamat IP dan gateway"
cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
  address 10.86.4.2
  netmask 255.255.255.0
  gateway 10.86.4.1
EOF
service networking restart

say "Urutan resolver"
cat > /etc/resolv.conf <<'EOF'
nameserver 10.86.5.2
nameserver 10.86.5.3
nameserver 192.168.122.1
EOF

which dig  >/dev/null 2>&1 || { apt update && apt install dnsutils -y; }
which curl >/dev/null 2>&1 || { apt update && apt install curl -y; }

say "Uji"
ip a show eth0 | grep inet
ping -c 2 google.com
dig k45.com +short
