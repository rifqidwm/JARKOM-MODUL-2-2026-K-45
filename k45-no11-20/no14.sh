#!/bin/bash
set -e
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }

echo '=== NO.14 - REAL CLIENT IP ==='
case "$IP" in
10.86.5.4|10.86.5.5)
  apt install apache2 -y
  a2enmod remoteip >/dev/null
  cat > /etc/apache2/conf-available/k45-realip.conf <<'CONF'
RemoteIPHeader X-Real-IP
RemoteIPTrustedProxy 10.86.4.2
LogFormat "%a %l %u %t \"%r\" %>s %b" realip
CustomLog /var/log/apache2/realip_access.log realip
CONF
  a2enconf k45-realip >/dev/null
  apache2ctl configtest
  service apache2 restart
  echo 'Apache backend siap menerima X-Real-IP dari Penny.'
  ;;
10.86.5.6|10.86.5.7)
  apt install nginx -y
  cat > /etc/nginx/conf.d/k45-realip.conf <<'CONF'
log_format realip '$http_x_real_ip - $remote_user [$time_local] "$request" $status $body_bytes_sent';
CONF
  # Tambahkan access_log realip ke server config utama jika belum ada.
  if ! grep -Rqs 'access_log .*realip' /etc/nginx/sites-enabled /etc/nginx/conf.d; then
    cat > /etc/nginx/snippets/k45-realip-location.conf <<'CONF'
access_log /var/log/nginx/realip_access.log realip;
CONF
    sed -i '/location \/ {/a\        include /etc/nginx/snippets/k45-realip-location.conf;' /etc/nginx/sites-available/default 2>/dev/null || true
  fi
  nginx -t
  service nginx restart
  echo 'Nginx backend siap mencatat X-Real-IP.'
  ;;
*) echo 'No.14 dijalankan di Obladi/Desmond/Oblada/Molly.'; exit 1;;
esac

echo 'NO.14 SELESAI.'
