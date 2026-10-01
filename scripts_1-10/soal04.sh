#!/bin/bash
# =====================================================
# JARKOM MODUL 2 2026 - K45
# Soal 4 - Zona k45.com pada prab (master) dan tedd (slave)
# =====================================================
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

case "$HOST" in
  prab)
    say "prab: memasang bind9"
    echo "nameserver 192.168.122.1" > /etc/resolv.conf
    apt update
    apt install bind9 dnsutils -y
    mkdir -p /etc/bind/zones

    say "Menulis named.conf.options"
cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders { 192.168.122.1; };
    dnssec-validation no;
};
EOF

    say "Menulis named.conf.local (master, transfer ke tedd)"
    cat > /etc/bind/named.conf.local <<'EOF'
zone "k45.com" {
    type master;
    file "/etc/bind/zones/db.k45.com";
    allow-transfer { 10.86.5.3; };
    also-notify { 10.86.5.3; };
    notify yes;
};
EOF

    say "Menulis berkas zona k45.com"
    cat > /etc/bind/zones/db.k45.com <<'EOF'
$TTL 604800
@   IN  SOA prab.k45.com. admin.k45.com. (
        2026092801
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
EOF

    say "Validasi dan menjalankan layanan"
    named-checkconf
    named-checkzone k45.com /etc/bind/zones/db.k45.com
    service named restart || service bind9 restart
    sleep 2

cat > /etc/resolv.conf <<'EOF'
nameserver 10.86.5.2
nameserver 10.86.5.3
nameserver 192.168.122.1
EOF

    say "Uji dari prab sendiri"
    dig @127.0.0.1 k45.com SOA +short
    dig @127.0.0.1 k45.com +short
    ;;

  tedd)
    say "tedd: memasang bind9"
    echo "nameserver 192.168.122.1" > /etc/resolv.conf
    apt update
    apt install bind9 dnsutils -y

    say "Menulis named.conf.options"
cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders { 192.168.122.1; };
    dnssec-validation no;
};
EOF

    say "Menulis named.conf.local (slave dari prab)"
    cat > /etc/bind/named.conf.local <<'EOF'
zone "k45.com" {
    type slave;
    masters { 10.86.5.2; };
    file "/var/cache/bind/db.k45.com";
};
EOF

    named-checkconf
    service named restart || service bind9 restart
    sleep 3

cat > /etc/resolv.conf <<'EOF'
nameserver 10.86.5.2
nameserver 10.86.5.3
nameserver 192.168.122.1
EOF

    say "Uji dari tedd sendiri"
    dig @127.0.0.1 k45.com SOA +short
    ;;

  *)
    say "Node biasa: memperbarui urutan resolver"
cat > /etc/resolv.conf <<'EOF'
nameserver 10.86.5.2
nameserver 10.86.5.3
nameserver 192.168.122.1
EOF
    cat /etc/resolv.conf
    which dig >/dev/null 2>&1 || { apt update && apt install dnsutils -y; }

    say "Uji resolusi"
    dig @10.86.5.2 k45.com SOA +short
    dig @10.86.5.3 k45.com SOA +short
    dig k45.com +short
    dig prab.k45.com +short
    ;;
esac
