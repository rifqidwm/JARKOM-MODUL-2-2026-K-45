
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

say "Hostname"
hostname desmond
echo desmond > /etc/hostname
grep -q "127.0.1.1 desmond" /etc/hosts || echo "127.0.1.1 desmond" >> /etc/hosts

say "Alamat IP dan gateway"
cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
  address 10.86.5.5
  netmask 255.255.255.0
  gateway 10.86.5.1
EOF
service networking restart

say "Urutan resolver"
cat > /etc/resolv.conf <<'EOF'
nameserver 10.86.5.2
nameserver 10.86.5.3
nameserver 192.168.122.1
EOF

say "Web statis Apache dengan autoindex (soal 9)"
apt update
apt install apache2 -y

mkdir -p /var/www/html/arsip
echo "Arsip $(hostname) - dokumen 1" > /var/www/html/arsip/dokumen1.txt
echo "Arsip $(hostname) - dokumen 2" > /var/www/html/arsip/dokumen2.txt
echo "Arsip $(hostname) - catatan"   > /var/www/html/arsip/catatan.txt

cat > /etc/apache2/conf-available/arsip.conf <<'EOF'
<Directory /var/www/html/arsip>
    Options +Indexes
    AllowOverride None
    Require all granted
</Directory>
EOF

a2enmod autoindex
a2enconf arsip
service apache2 restart

say "Uji lokal"
curl -s http://localhost/arsip/ | head -20
