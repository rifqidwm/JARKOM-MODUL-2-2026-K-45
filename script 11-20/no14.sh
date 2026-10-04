#!/bin/bash
# No.14 - Access log mencatat IP client asli (X-Real-IP)
# Node  : Obladi (10.86.5.4) & Desmond (10.86.5.5) -> Apache
#         Oblada (10.86.5.6) & Molly  (10.86.5.7)  -> Nginx
# Jalankan di KEEMPAT node (script otomatis memilih sesuai IP).
set -e
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)

case "$IP" in
10.86.5.4|10.86.5.5)
  echo '[VAULT] Apache'
  cat > /etc/apache2/conf-available/k45-realip.conf <<'CONF'
LogFormat "%{X-Real-IP}i %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" realip
CONF
  a2enconf k45-realip >/dev/null
  # access.log pakai format realip (sama seperti README)
  sed -i 's#CustomLog ${APACHE_LOG_DIR}/access.log combined#CustomLog ${APACHE_LOG_DIR}/access.log realip#' \
    /etc/apache2/sites-available/000-default.conf
  grep -n 'CustomLog' /etc/apache2/sites-available/000-default.conf
  apache2ctl configtest
  service apache2 restart
  echo 'Cek log: tail -10 /var/log/apache2/access.log'
  ;;

10.86.5.6|10.86.5.7)
  echo '[CORE] Nginx'
  cat > /etc/nginx/conf.d/k45-realip.conf <<'CONF'
log_format realip '$http_x_real_ip - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" "$http_user_agent"';
CONF
  if ! grep -q 'access_log /var/log/nginx/access.log realip' /etc/nginx/sites-available/default; then
    sed -i '/server_name core\.k45\.com/a\    access_log /var/log/nginx/access.log realip;' /etc/nginx/sites-available/default
  fi
  grep -n 'access_log' /etc/nginx/sites-available/default
  nginx -t
  service nginx restart
  echo 'Cek log: tail -10 /var/log/nginx/access.log'
  ;;

*) echo "No.14 dijalankan di Obladi/Desmond/Oblada/Molly. IP terdeteksi: $IP"; exit 1;;
esac

echo 'Tes: dari Alpha jalankan  curl -s -H "Host: static.k45.com" http://10.86.3.2/profil  lalu cek log (harus 10.86.1.2).'
echo 'NO.14 SELESAI.'
