#!/bin/bash
set -u
IP=$(hostname -I | tr ' ' '\n' | grep '^10\.86\.' | head -1)
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }

echo '=== NO.20 - VERIFY AUTOSTART / PERSISTENCE ==='
echo "Node IP: $IP"

echo
echo '--- IP address ---'
ip -br addr || true

echo
echo '--- Routes ---'
ip route || true

echo
echo '--- systemd availability ---'
if command -v systemctl >/dev/null 2>&1; then systemctl --version | head -1; else echo 'systemctl tidak tersedia'; fi

echo
echo '--- Running services/processes ---'
pgrep -a named || true
pgrep -a apache2 || true
pgrep -a nginx || true
pgrep -a php-fpm || true

echo
echo '--- Listening ports ---'
ss -lntp 2>/dev/null | grep -E ':53 |:80 |:443 ' || true

echo
echo '--- SysV init links ---'
ls -l /etc/rc2.d/S01named /etc/rc3.d/S01named /etc/rc4.d/S01named /etc/rc5.d/S01named 2>/dev/null || true
ls -l /etc/rc2.d/S01k45-netfilter /etc/rc3.d/S01k45-netfilter /etc/rc4.d/S01k45-netfilter /etc/rc5.d/S01k45-netfilter 2>/dev/null || true

echo
echo '--- Rootkit forwarding/NAT ---'
if [ "$IP" = '10.86.1.1' ] || ip addr show | grep -q '10.86.1.1/24'; then
  sysctl net.ipv4.ip_forward 2>/dev/null || true
  iptables -t nat -S POSTROUTING 2>/dev/null | grep MASQUERADE || true
fi

echo
echo '--- Service status ---'
for svc in named apache2 nginx php8.4-fpm; do
  if [ -x "/etc/init.d/$svc" ]; then
    echo "[$svc]"
    /etc/init.d/$svc status 2>&1 || true
  fi
done

echo
echo '--- DNS checks on DNS nodes ---'
if [ "$IP" = '10.86.5.2' ] || [ "$IP" = '10.86.5.3' ]; then
  dig @"$IP" k45.com SOA +short || true
  dig @"$IP" outbound.k45.com CNAME +short || true
fi

echo
echo 'NO.20 CHECK SELESAI.'
