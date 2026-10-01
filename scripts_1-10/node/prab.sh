
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

say "Hostname"
hostname prab
echo prab > /etc/hostname
grep -q "127.0.1.1 prab" /etc/hosts || echo "127.0.1.1 prab" >> /etc/hosts

say "Alamat IP dan gateway"
cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
  address 10.86.5.2
  netmask 255.255.255.0
  gateway 10.86.5.1
EOF
service networking restart

say "Resolver sementara untuk pemasangan paket"
echo "nameserver 192.168.122.1" > /etc/resolv.conf

say "Memasang bind9 (soal 4)"
apt update
apt install bind9 dnsutils -y
mkdir -p /etc/bind/zones

say "named.conf.options"
cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders { 192.168.122.1; };
    dnssec-validation no;
};
EOF

say "named.conf.local, zona forward dan tiga reverse zone (soal 4 dan 8)"
cat > /etc/bind/named.conf.local <<'EOF'
zone "k45.com" {
    type master;
    file "/etc/bind/zones/db.k45.com";
    allow-transfer { 10.86.5.3; };
    also-notify { 10.86.5.3; };
    notify yes;
};
zone "3.86.10.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.10.86.3";
    allow-transfer { 10.86.5.3; };
    also-notify { 10.86.5.3; };
    notify yes;
};
zone "4.86.10.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.10.86.4";
    allow-transfer { 10.86.5.3; };
    also-notify { 10.86.5.3; };
    notify yes;
};
zone "5.86.10.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.10.86.5";
    allow-transfer { 10.86.5.3; };
    also-notify { 10.86.5.3; };
    notify yes;
};
EOF

say "Berkas zona k45.com (soal 4, 5, dan 7)"
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

say "Berkas reverse zone (soal 8)"
cat > /etc/bind/zones/db.10.86.3 <<'EOF'
$TTL 604800
@   IN  SOA prab.k45.com. admin.k45.com. (
        2026092801 604800 86400 2419200 604800 )
@   IN  NS  prab.k45.com.
@   IN  NS  tedd.k45.com.
2   IN  PTR abbey.k45.com.
EOF

cat > /etc/bind/zones/db.10.86.4 <<'EOF'
$TTL 604800
@   IN  SOA prab.k45.com. admin.k45.com. (
        2026092801 604800 86400 2419200 604800 )
@   IN  NS  prab.k45.com.
@   IN  NS  tedd.k45.com.
2   IN  PTR penny.k45.com.
EOF

cat > /etc/bind/zones/db.10.86.5 <<'EOF'
$TTL 604800
@   IN  SOA prab.k45.com. admin.k45.com. (
        2026092801 604800 86400 2419200 604800 )
@   IN  NS  prab.k45.com.
@   IN  NS  tedd.k45.com.
4   IN  PTR obladi.k45.com.
5   IN  PTR desmond.k45.com.
6   IN  PTR oblada.k45.com.
7   IN  PTR molly.k45.com.
EOF

say "Validasi dan menjalankan layanan"
named-checkconf
named-checkzone k45.com /etc/bind/zones/db.k45.com
named-checkzone 3.86.10.in-addr.arpa /etc/bind/zones/db.10.86.3
named-checkzone 4.86.10.in-addr.arpa /etc/bind/zones/db.10.86.4
named-checkzone 5.86.10.in-addr.arpa /etc/bind/zones/db.10.86.5
service named restart || service bind9 restart
sleep 2

say "Urutan resolver akhir"
cat > /etc/resolv.conf <<'EOF'
nameserver 10.86.5.2
nameserver 10.86.5.3
nameserver 192.168.122.1
EOF

say "Uji"
dig @127.0.0.1 k45.com SOA +short
dig @127.0.0.1 k45.com +short
dig @127.0.0.1 vault.k45.com +short
dig @127.0.0.1 -x 10.86.5.4 +short
