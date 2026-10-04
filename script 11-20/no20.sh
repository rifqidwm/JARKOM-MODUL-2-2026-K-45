#!/bin/bash
# No.20 - IP forwarding & NAT Rootkit tetap jalan setelah reboot
# Node  : Rootkit (10.86.1.1) saja
#   bash no20.sh       -> pasang persistence
#   (reboot)
#   bash no20.sh cek   -> verifikasi setelah reboot
set -e
[ "$EUID" -eq 0 ] || { echo 'Jalankan sebagai root.'; exit 1; }
ip -4 addr show | grep -q '10\.86\.1\.1/24' || { echo 'No.20 hanya di Rootkit (punya 10.86.1.1).'; exit 1; }

cek() {
  echo '--- Interface ---'; ip -br addr
  echo '--- Route ---';     ip route
  echo '--- IP forwarding ---'; sysctl net.ipv4.ip_forward
  echo '--- NAT ---'; iptables -t nat -L POSTROUTING -n -v --line-numbers
  echo '--- Autostart (rc2-rc5) ---'
  ls -l /etc/rc[2-5].d/*k45-netfilter
}

if [ "${1:-}" = 'cek' ]; then cek; exit 0; fi

# 1. IP forwarding persistent
cat > /etc/sysctl.d/99-k45-router.conf <<'CONF'
net.ipv4.ip_forward=1
CONF
sysctl --system | grep -E 'k45-router|ip_forward'
sysctl net.ipv4.ip_forward

# 2. Rule NAT (ditambah hanya kalau belum ada)
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE -s 10.86.0.0/16 2>/dev/null || \
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.86.0.0/16
iptables -t nat -L POSTROUTING -n -v --line-numbers

# 3. iptables-persistent (tanpa prompt) lalu simpan rule
apt update || true
DEBIAN_FRONTEND=noninteractive apt install iptables-persistent -y
mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4
ls -lh /etc/iptables/rules.v4
grep -n MASQUERADE /etc/iptables/rules.v4
netfilter-persistent reload

# 4. Autostart SysV init (Rootkit tidak punya systemctl)
cat > /etc/init.d/k45-netfilter <<'INIT'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          k45-netfilter
# Required-Start:    $network $remote_fs
# Required-Stop:     $remote_fs
# Should-Start:      $network
# Should-Stop:       $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Load K45 iptables rules
### END INIT INFO

case "$1" in
    start)
        /usr/sbin/netfilter-persistent start
        ;;
    stop)
        /usr/sbin/netfilter-persistent stop
        ;;
    restart)
        /usr/sbin/netfilter-persistent stop
        /usr/sbin/netfilter-persistent start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

exit 0
INIT
chmod +x /etc/init.d/k45-netfilter
update-rc.d k45-netfilter defaults
/etc/init.d/k45-netfilter start

cek
echo 'NO.20 SELESAI. Reboot Rootkit, lalu jalankan: bash no20.sh cek'
