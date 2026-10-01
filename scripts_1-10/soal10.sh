#!/bin/bash
# =====================================================
# JARKOM MODUL 2 2026 - K45
# Soal 10 - Web dinamis PHP-FPM dengan URL bersih (area core)
# =====================================================
set -u
say() { echo ""; echo "=== $* ==="; }
HOST=$(hostname)
echo "Node terdeteksi: $HOST"

case "$HOST" in
  oblada|molly)
    say "$HOST: memasang nginx dan PHP-FPM"
apt update
apt install nginx php-fpm -y

cat > /var/www/html/index.php <<'EOF'
<?php
echo "<h1>Beranda - " . gethostname() . "</h1>";
echo "<p>Area core, layanan web dinamis k45.com</p>";
echo "<a href='/profil'>Lihat Profil</a>";
?>
EOF

cat > /var/www/html/profil.php <<'EOF'
<?php
echo "<h1>Profil - " . gethostname() . "</h1>";
echo "<p>Halaman ini diakses tanpa akhiran .php</p>";
echo "<a href='/'>Kembali ke beranda</a>";
?>
EOF

# php-fpm dijalankan lebih dulu agar berkas socket terbentuk
service php8.4-fpm start >/dev/null 2>&1
service php8.4-fpm restart >/dev/null 2>&1
service php-fpm start >/dev/null 2>&1
service php-fpm restart >/dev/null 2>&1
sleep 2

PHPSOCK=$(ls /run/php/php*-fpm.sock 2>/dev/null | head -1)
if [ -z "$PHPSOCK" ]; then
  echo "socket belum terbentuk, menjalankan php-fpm secara langsung"
  /usr/sbin/php-fpm8.4 -D >/dev/null 2>&1
  sleep 2
  PHPSOCK=$(ls /run/php/php*-fpm.sock 2>/dev/null | head -1)
fi
echo "socket PHP-FPM: $PHPSOCK"

cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80 default_server;
    root /var/www/html;
    index index.php index.html;
    server_name core.k45.com oblada.k45.com molly.k45.com;

    location / {
        try_files \$uri \$uri/ @extensionless;
    }

    location @extensionless {
        rewrite ^(.*)\$ \$1.php last;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$PHPSOCK;
    }
}
EOF

nginx -t
service nginx restart

    say "Uji lokal"
    curl -s http://localhost/
    echo ""
    curl -s http://localhost/profil
    echo ""
    ;;
  *)
    say "Verifikasi dari node $HOST melalui hostname"
    which curl >/dev/null 2>&1 || { apt update && apt install curl -y; }
    echo "--- core.k45.com (beranda) ---"
    curl -s http://core.k45.com/
    echo ""
    echo "--- core.k45.com/profil (tanpa .php) ---"
    curl -s http://core.k45.com/profil
    echo ""
    echo "--- oblada.k45.com/profil ---"
    curl -s http://oblada.k45.com/profil
    echo ""
    echo "--- molly.k45.com/profil ---"
    curl -s http://molly.k45.com/profil
    echo ""
    ;;
esac
