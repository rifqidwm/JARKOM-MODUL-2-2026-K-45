#!/bin/bash
# =====================================================
# JARKOM MODUL 2 2026 - K45
# Soal 8 - Reverse zone dan PTR
# =====================================================
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

case "$HOST" in
  prab)
    say "prab: mendeklarasikan tiga reverse zone sebagai master"
    grep -q "3.86.10.in-addr.arpa" /etc/bind/named.conf.local || cat >> /etc/bind/named.conf.local <<'EOF'

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

    say "Menulis berkas reverse zone"
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
    named-checkzone 3.86.10.in-addr.arpa /etc/bind/zones/db.10.86.3
    named-checkzone 4.86.10.in-addr.arpa /etc/bind/zones/db.10.86.4
    named-checkzone 5.86.10.in-addr.arpa /etc/bind/zones/db.10.86.5
    service named restart || service bind9 restart
    sleep 2
    ;;

  tedd)
    say "tedd: menarik ketiga reverse zone sebagai slave"
    grep -q "3.86.10.in-addr.arpa" /etc/bind/named.conf.local || cat >> /etc/bind/named.conf.local <<'EOF'

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
    ;;
esac

which dig >/dev/null 2>&1 || { apt update && apt install dnsutils -y; }

say "Verifikasi pencarian balik"
for ip in 10.86.3.2 10.86.4.2 10.86.5.4 10.86.5.5 10.86.5.6 10.86.5.7; do
  printf "%-12s -> %s\n" "$ip" "$(dig -x $ip +short)"
done

say "Verifikasi melalui tedd sebagai ns2"
dig @10.86.5.3 -x 10.86.5.7 +short
