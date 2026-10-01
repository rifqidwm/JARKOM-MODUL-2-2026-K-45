
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

say "Hostname"
hostname tedd
echo tedd > /etc/hostname
grep -q "127.0.1.1 tedd" /etc/hosts || echo "127.0.1.1 tedd" >> /etc/hosts

say "Alamat IP dan gateway"
cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
  address 10.86.5.3
  netmask 255.255.255.0
  gateway 10.86.5.1
EOF
service networking restart

say "Resolver sementara untuk pemasangan paket"
echo "nameserver 192.168.122.1" > /etc/resolv.conf

say "Memasang bind9 (soal 4)"
apt update
apt install bind9 dnsutils -y

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

say "named.conf.local, seluruh zona sebagai slave (soal 4 dan 8)"
cat > /etc/bind/named.conf.local <<'EOF'
zone "k45.com" {
    type slave;
    masters { 10.86.5.2; };
    file "/var/cache/bind/db.k45.com";
};
zone "3.86.10.in-addr.arpa" {
    type slave;
    masters { 10.86.5.2; };
    file "/var/cache/bind/db.10.86.3";
};
zone "4.86.10.in-addr.arpa" {
    type slave;
    masters { 10.86.5.2; };
    file "/var/cache/bind/db.10.86.4";
};
zone "5.86.10.in-addr.arpa" {
    type slave;
    masters { 10.86.5.2; };
    file "/var/cache/bind/db.10.86.5";
};
EOF

named-checkconf
service named restart || service bind9 restart
sleep 3

say "Urutan resolver akhir"
cat > /etc/resolv.conf <<'EOF'
nameserver 10.86.5.2
nameserver 10.86.5.3
nameserver 192.168.122.1
EOF

say "Uji zone transfer (soal 6)"
dig @127.0.0.1 k45.com SOA +short
dig @10.86.5.2 k45.com AXFR | head -30
ls -l /var/cache/bind/db.k45.com
