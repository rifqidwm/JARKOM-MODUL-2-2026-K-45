# JARKOM MODUL 2 2026 - K45

## Anggota

| Nama                         | NRP        |
| -------------                | ---------- |
| Abhista Athallah Dyfan       | 5027251006 |
| Rifqi Dwi Muslim             | 5027251077 |

---

## Topologi (GNS3)
 
Seluruh node host memakai **satu image Docker Debian yang sama** (DebiNet). Switch memakai **Ethernet switch** bawaan GNS3, dan gerbang internet memakai node **NAT** bawaan GNS3. Ikon yang berbeda-beda pada soal hanya simbol kosmetik, bukan jenis node yang berbeda.
 
**Daftar node:**
 
| Jumlah | Jenis node       | Node                                                                                                 |
| ------ | ---------------- | ---------------------------------------------------------------------------------------------------- |
| 14     | Docker (DebiNet) | rootkit, alpha, beta, gamma, delta, epsilon, abbey, penny, prab, tedd, obladi, desmond, oblada, molly |
| 7      | Ethernet switch  | Switch1, Switch2, Switch3, Switch4, Switch5, Switch6, Switch7                                        |
| 1      | NAT              | NAT                                                                                                  |
 
**rootkit diset memiliki 6 network adapter (eth0-eth5)** lewat Configure node dalam keadaan node berhenti. Node lain cukup 1 adapter (eth0, default).
 
**Daftar link:**
 
| Dari (node/eth) | Ke                             |
| --------------- | ------------------------------ |
| rootkit eth0    | NAT                            |
| rootkit eth1    | Switch6                        |
| rootkit eth2    | Switch7                        |
| rootkit eth3    | Switch4                        |
| rootkit eth4    | Switch5                        |
| rootkit eth5    | Switch1                        |
| Switch6         | alpha, beta, gamma             |
| Switch7         | delta, epsilon                 |
| Switch4         | abbey                          |
| Switch5         | penny                          |
| Switch1         | Switch2, Switch3               |
| Switch2         | prab, tedd                     |
| Switch3         | obladi, desmond, oblada, molly |
 
![](assets/topologi.png)
 
---
 
## Rancangan Pengalamatan IP
 
**Prefix kelompok: `10.86.x.x`**, domain kelompok: **`k45.com`**.
 
rootkit merentang ke **5 switch utama**, tiap switch menjadi satu subnet `/24`.
 
| Segmen (Switch)     | Subnet        | Gateway (di rootkit) | Node di segmen ini                         |
| ------------------- | ------------- | -------------------- | ------------------------------------------ |
| Switch6             | 10.86.1.0/24  | 10.86.1.1            | alpha, beta, gamma                         |
| Switch7             | 10.86.2.0/24  | 10.86.2.1            | delta, epsilon                             |
| Switch4             | 10.86.3.0/24  | 10.86.3.1            | abbey                                      |
| Switch5             | 10.86.4.0/24  | 10.86.4.1            | penny                                      |
| Switch1 → Switch2/3 | 10.86.5.0/24  | 10.86.5.1            | prab, tedd, obladi, desmond, oblada, molly |
 
**Alamat IP per node:**
 
| Node    | IP          | Netmask       | Gateway   | Peran                   |
| ------- | ----------- | ------------- | --------- | ----------------------- |
| rootkit | multi eth   | 255.255.255.0 | -         | Router / NAT            |
| alpha   | 10.86.1.2   | 255.255.255.0 | 10.86.1.1 | Client (pengamat)       |
| beta    | 10.86.1.3   | 255.255.255.0 | 10.86.1.1 | Client (pengamat)       |
| gamma   | 10.86.1.4   | 255.255.255.0 | 10.86.1.1 | Client (pengamat)       |
| delta   | 10.86.2.2   | 255.255.255.0 | 10.86.2.1 | Client (eksekutor)      |
| epsilon | 10.86.2.3   | 255.255.255.0 | 10.86.2.1 | Client (eksekutor)      |
| abbey   | 10.86.3.2   | 255.255.255.0 | 10.86.3.1 | Reverse proxy (statis)  |
| penny   | 10.86.4.2   | 255.255.255.0 | 10.86.4.1 | Reverse proxy (dinamis) |
| prab    | 10.86.5.2   | 255.255.255.0 | 10.86.5.1 | DNS ns1 (master)        |
| tedd    | 10.86.5.3   | 255.255.255.0 | 10.86.5.1 | DNS ns2 (slave)         |
| obladi  | 10.86.5.4   | 255.255.255.0 | 10.86.5.1 | Web statis (vault)      |
| desmond | 10.86.5.5   | 255.255.255.0 | 10.86.5.1 | Web statis (vault)      |
| oblada  | 10.86.5.6   | 255.255.255.0 | 10.86.5.1 | Web dinamis (core)      |
| molly   | 10.86.5.7   | 255.255.255.0 | 10.86.5.1 | Web dinamis (core)      |
 
**Pemetaan interface di rootkit:**
 
| Interface | Terhubung ke | IP        |
| --------- | ------------ | --------- |
| eth0      | NAT (WAN)    | dhcp      |
| eth1      | Switch6      | 10.86.1.1 |
| eth2      | Switch7      | 10.86.2.1 |
| eth3      | Switch4      | 10.86.3.1 |
| eth4      | Switch5      | 10.86.4.1 |
| eth5      | Switch1      | 10.86.5.1 |
 
---
 
## Urutan Pengerjaan
 
Seluruh konfigurasi dijalankan lewat **console tiap node** dan dijalankan berurutan seperti berikut, karena tiap tahap bergantung pada tahap sebelumnya:
 
1. **rootkit** dikonfigurasi lebih dulu (IP semua interface, forwarding, NAT), karena semua node lain membutuhkan jalur keluar untuk mengunduh paket.
2. **Node host** diberi IP, gateway, hostname, dan resolver awal.
3. **prab** dibangun sebagai DNS master, lalu **tedd** sebagai slave.
4. Resolver seluruh node non-router diarahkan ke prab, tedd, lalu 192.168.122.1.
5. **obladi, desmond** dijalankan sebagai web statis, **oblada, molly** sebagai web dinamis.
Verifikasi tiap tahap dilakukan sebelum lanjut ke tahap berikutnya. Untuk menjalankan seluruh konfigurasi sekaligus per node, lihat bagian **Blok Konfigurasi Lengkap per Node** di bagian akhir dokumen.
 
---
 
## Laporan
 
### Soal 1 - Pengalamatan IP dan Default Gateway
 
**Diminta:** menetapkan IP address dan *default gateway* untuk seluruh Entitas, mulai dari operator (alpha, beta, gamma), penjaga *directory* (prab, tedd), gerbang penyaring (abbey, penny), hingga *repository* (obladi, desmond, oblada, molly), sesuai prefix IP kelompok.
 
**Di rootkit**, tetapkan IP statis pada kelima interface yang mengarah ke switch:
 
```sh
cat <<'EOF' > /etc/network/interfaces
auto eth1
iface eth1 inet static
  address 10.86.1.1
  netmask 255.255.255.0
 
auto eth2
iface eth2 inet static
  address 10.86.2.1
  netmask 255.255.255.0
 
auto eth3
iface eth3 inet static
  address 10.86.3.1
  netmask 255.255.255.0
 
auto eth4
iface eth4 inet static
  address 10.86.4.1
  netmask 255.255.255.0
 
auto eth5
iface eth5 inet static
  address 10.86.5.1
  netmask 255.255.255.0
EOF
 
service networking restart
```
 
**Di tiap node host**, tetapkan IP statis beserta gateway segmennya. Blok berikut dijalankan di setiap node dengan **mengubah baris pertama saja** sesuai node yang sedang dikonfigurasi:
 
```sh
HOST=alpha; IP=10.86.1.2; GW=10.86.1.1
 
cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address $IP
  netmask 255.255.255.0
  gateway $GW
EOF
 
service networking restart
```
 
Nilai baris pertama untuk tiap node:
 
| Node    | Baris pertama                              |
| ------- | ------------------------------------------ |
| alpha   | `HOST=alpha; IP=10.86.1.2; GW=10.86.1.1`   |
| beta    | `HOST=beta; IP=10.86.1.3; GW=10.86.1.1`    |
| gamma   | `HOST=gamma; IP=10.86.1.4; GW=10.86.1.1`   |
| delta   | `HOST=delta; IP=10.86.2.2; GW=10.86.2.1`   |
| epsilon | `HOST=epsilon; IP=10.86.2.3; GW=10.86.2.1` |
| abbey   | `HOST=abbey; IP=10.86.3.2; GW=10.86.3.1`   |
| penny   | `HOST=penny; IP=10.86.4.2; GW=10.86.4.1`   |
| prab    | `HOST=prab; IP=10.86.5.2; GW=10.86.5.1`    |
| tedd    | `HOST=tedd; IP=10.86.5.3; GW=10.86.5.1`    |
| obladi  | `HOST=obladi; IP=10.86.5.4; GW=10.86.5.1`  |
| desmond | `HOST=desmond; IP=10.86.5.5; GW=10.86.5.1` |
| oblada  | `HOST=oblada; IP=10.86.5.6; GW=10.86.5.1`  |
| molly   | `HOST=molly; IP=10.86.5.7; GW=10.86.5.1`   |
 
**Verifikasi:**
 
```sh
ip a                      # di rootkit: eth1-eth5 memegang 10.86.x.1
ip a                      # di node host: eth0 memegang IP sesuai tabel
ping -c 2 10.86.1.1       # dari alpha ke gateway segmennya
```
 
![](assets/soal1-rootkit-ip.png)
![](assets/soal1-client-ip.png)
 
---
 
### Soal 2 - Jalur keluar melalui NAT
 
**Diminta:** membuka jalur menuju NAT dengan memastikan antarmuka WAN pada router rootkit aktif, lalu mengonfigurasi NAT agar meneruskan lalu lintas keluar bagi seluruh alamat internal.
 
**Di rootkit**, tambahkan antarmuka WAN yang mengambil alamat dari DHCP NAT:
 
```sh
cat <<'EOF' >> /etc/network/interfaces
 
auto eth0
iface eth0 inet dhcp
EOF
 
service networking restart
```
 
Aktifkan *IP forwarding* dan aturan *masquerade*:
 
```sh
echo 1 > /proc/sys/net/ipv4/ip_forward
 
which iptables >/dev/null 2>&1 || (apt update && apt install iptables -y)
 
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE -s 10.86.0.0/16 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.86.0.0/16
```
 
Penjelasan aturan `iptables`:
 
- `-t nat` : tabel NAT untuk translasi alamat pada lalu lintas keluar
- `-A POSTROUTING` : aturan diterapkan pada paket yang akan meninggalkan sistem
- `-o eth0` : antarmuka keluar, yaitu yang mengarah ke NAT
- `-j MASQUERADE` : alamat sumber paket diganti dengan alamat eth0 rootkit
- `-s 10.86.0.0/16` : hanya berlaku bagi paket yang berasal dari subnet internal kelompok
**Catatan:** `ip_forward` dan aturan `iptables` bersifat *runtime*, keduanya dijalankan kembali setiap kali node rootkit dinyalakan.
 
**Verifikasi:**
 
```sh
ip a                      # eth0 mendapat alamat 192.168.122.x dari NAT
ping -c 3 google.com      # dari rootkit
```
 
![](assets/soal2-rootkit-inet.png)
 
---
 
### Soal 3 - Sinkronisasi antar divisi dan resolver awal
 
**Diminta:** memastikan seluruh Entitas dapat saling terhubung dan berkomunikasi lintas jalur (routing internal via rootkit berfungsi), serta setiap host non-router menambahkan resolver `192.168.122.1` pada `/etc/resolv.conf` agar akses pengunduhan paket tersedia sejak awal. Resolver Google tidak digunakan.
 
Routing internal berjalan otomatis setelah rootkit memegang alamat di semua segmen (soal 1) dan *forwarding* aktif (soal 2), sehingga tiap segmen dapat menjangkau segmen lain melalui rootkit.
 
**Di tiap node non-router**, tetapkan resolver awal:
 
```sh
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```
 
**Verifikasi** dari alpha, mencakup komunikasi lintas segmen dan akses keluar:
 
```sh
ping -c 3 10.86.2.2       # delta, segmen berbeda
ping -c 3 10.86.5.2       # prab, segmen berbeda
ping -c 3 google.com      # akses keluar melalui rootkit
```
 
![](assets/soal3-ping-antar-subnet.png)
![](assets/soal3-client-inet.png)
 
---
 
### Soal 4 - Zona k45.com pada prab (ns1) dan tedd (ns2)
 
**Diminta:** pada node **prab**, membangun zona `k45.com` sebagai *authoritative* dengan SOA yang menunjuk ke `prab.k45.com`, menambahkan catatan NS untuk `prab.k45.com` dan `tedd.k45.com`, membuat A record untuk keduanya, serta A record *apex* `k45.com` yang mengarah ke gerbang aplikasi dinamis (**penny**). Fitur *notify* dan *allow-transfer* ke tedd diaktifkan, dan *forwarders* diarahkan ke `192.168.122.1`. Pada node **tedd**, zona `k45.com` ditarik dari master dan dijawab secara *authoritative*. Setelah itu urutan resolver pada seluruh Entitas non-router diperbarui menjadi IP **prab**, IP **tedd**, lalu `192.168.122.1`.
 
**Di prab**, pasang bind9 dan siapkan direktori zona:
 
```sh
apt update
apt install bind9 dnsutils -y
mkdir -p /etc/bind/zones
```
 
Berkas `/etc/bind/named.conf.options`:
 
```sh
cat <<'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders { 192.168.122.1; };
    dnssec-validation no;
};
EOF
```
 
Berkas `/etc/bind/named.conf.local`, mendeklarasikan zona sebagai master sekaligus mengizinkan transfer ke tedd:
 
```sh
cat <<'EOF' > /etc/bind/named.conf.local
zone "k45.com" {
    type master;
    file "/etc/bind/zones/db.k45.com";
    allow-transfer { 10.86.5.3; };
    also-notify { 10.86.5.3; };
    notify yes;
};
EOF
```
 
Berkas zona `/etc/bind/zones/db.k45.com`:
 
```sh
cat <<'EOF' > /etc/bind/zones/db.k45.com
$TTL 604800
@   IN  SOA prab.k45.com. admin.k45.com. (
        2026092801  ; Serial
        604800      ; Refresh
        86400       ; Retry
        2419200     ; Expire
        604800 )    ; Negative Cache TTL
;
@       IN  NS  prab.k45.com.
@       IN  NS  tedd.k45.com.
@       IN  A   10.86.4.2
prab    IN  A   10.86.5.2
tedd    IN  A   10.86.5.3
EOF
```
 
Baris `@ IN A 10.86.4.2` adalah A record *apex*, mengarahkan `k45.com` ke **penny** sebagai gerbang aplikasi dinamis.
 
Validasi lalu jalankan layanan:
 
```sh
named-checkconf
named-checkzone k45.com /etc/bind/zones/db.k45.com
service named restart || service bind9 restart
```
 
**Di tedd**, pasang bind9 dan deklarasikan zona sebagai slave:
 
```sh
apt update
apt install bind9 dnsutils -y
 
cat <<'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders { 192.168.122.1; };
    dnssec-validation no;
};
EOF
 
cat <<'EOF' > /etc/bind/named.conf.local
zone "k45.com" {
    type slave;
    masters { 10.86.5.2; };
    file "/var/cache/bind/db.k45.com";
};
EOF
 
named-checkconf
service named restart || service bind9 restart
```
 
**Perbarui urutan resolver di seluruh node non-router**, termasuk prab dan tedd sendiri:
 
```sh
cat <<'EOF' > /etc/resolv.conf
nameserver 10.86.5.2
nameserver 10.86.5.3
nameserver 192.168.122.1
EOF
```
 
**Verifikasi:**
 
```sh
dig @10.86.5.2 k45.com SOA +short   # prab menjawab sebagai authoritative
dig @10.86.5.3 k45.com SOA +short   # tedd menjawab dengan serial yang sama
dig k45.com +short                  # 10.86.4.2 (penny)
dig prab.k45.com +short             # 10.86.5.2
```
 
![](assets/soal4-prab-soa.png)
![](assets/soal4-tedd-slave.png)
 
---
 
### Soal 5 - Penamaan Entitas dan domain per node
 
**Diminta:** menamai seluruh Entitas (*hostname*) sesuai glosarium dan memverifikasi setiap host mengenali *hostname* tersebut secara *system-wide*, serta membuat domain untuk masing-masing node sesuai namanya (contoh `alpha.k45.com`) dengan IP masing-masing. Node prab dan tedd dikecualikan karena sudah dibuat pada soal sebelumnya.
 
**Di tiap node**, tetapkan *hostname*. Blok berikut dijalankan pada setiap node dengan mengganti nilai `HOST` sesuai nama node:
 
```sh
HOST=alpha
 
hostname $HOST
echo $HOST > /etc/hostname
grep -q "127.0.1.1 $HOST" /etc/hosts || echo "127.0.1.1 $HOST" >> /etc/hosts
```
 
Nilai `HOST` untuk tiap node: `rootkit`, `alpha`, `beta`, `gamma`, `delta`, `epsilon`, `abbey`, `penny`, `prab`, `tedd`, `obladi`, `desmond`, `oblada`, `molly`.
 
**Di prab**, tambahkan A record seluruh node ke berkas zona. Berkas ditulis ulang secara utuh dengan **nilai Serial dinaikkan** menjadi `2026092802`:
 
```sh
cat <<'EOF' > /etc/bind/zones/db.k45.com
$TTL 604800
@   IN  SOA prab.k45.com. admin.k45.com. (
        2026092802
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
EOF
 
named-checkzone k45.com /etc/bind/zones/db.k45.com
service named restart || service bind9 restart
```
 
**Nilai Serial dinaikkan setiap kali berkas zona diubah**, karena tedd hanya menarik salinan baru bila Serial pada master lebih besar daripada salinan yang dipegangnya.
 
**Verifikasi:**
 
```sh
hostname                        # dijalankan di beberapa node berbeda
dig alpha.k45.com +short        # 10.86.1.2
dig molly.k45.com +short        # 10.86.5.7
dig abbey.k45.com +short        # 10.86.3.2
```
 
![](assets/soal5-hostname.png)
![](assets/soal5-hostname-gamma.png)
![](assets/soal5-dig-per-node.png)
 
---
 
### Soal 6 - Zone transfer prab ke tedd
 
**Diminta:** memastikan *zone transfer* berjalan dan tedd telah menerima salinan zona terbaru dari prab, dengan nilai Serial SOA pada keduanya harus sama.
 
Bandingkan Serial pada kedua server:
 
```sh
dig @10.86.5.2 k45.com SOA +short
dig @10.86.5.3 k45.com SOA +short
```
 
**Di tedd**, tarik seluruh isi zona dari master dan pastikan berkas salinan terbentuk:
 
```sh
dig @10.86.5.2 k45.com AXFR
ls -l /var/cache/bind/db.k45.com
```
 
Permintaan AXFR hanya dilayani untuk alamat yang terdaftar pada `allow-transfer`, sehingga perintah tersebut dijalankan dari tedd, bukan dari node client.
 
![](assets/soal6-serial-sama.png)
![](assets/soal6-axfr-tedd.png)
 
---
 
### Soal 7 - Endpoint area vault, area core, dan CNAME
 
**Diminta:** abbey dan penny sebagai gerbang utama, obladi dan desmond sebagai web statis, oblada dan molly sebagai web dinamis. Pada zona `k45.com` ditambahkan A record untuk `vault.k45.com` (IP obladi dan desmond) serta `core.k45.com` (IP oblada dan molly), ditambah CNAME `www.k45.com` → `penny.k45.com` dan `static.k45.com` → `abbey.k45.com`. Verifikasi dilakukan dari dua klien berbeda dan hasilnya harus konsisten.
 
**Di prab**, tulis ulang berkas zona dengan tambahan *endpoint* web dan **Serial dinaikkan** menjadi `2026092803`:
 
```sh
cat <<'EOF' > /etc/bind/zones/db.k45.com
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
 
named-checkzone k45.com /etc/bind/zones/db.k45.com
service named restart || service bind9 restart
```
 
`vault` dan `core` masing-masing memiliki dua A record, sehingga permintaan ke nama tersebut dijawab bergantian ke kedua node anggotanya.
 
**Verifikasi dari dua klien berbeda**, misalnya alpha dan delta. Kedua klien harus menghasilkan tujuan yang sama:
 
```sh
dig vault.k45.com +short     # 10.86.5.4 dan 10.86.5.5
dig core.k45.com +short      # 10.86.5.6 dan 10.86.5.7
dig www.k45.com +short       # penny.k45.com. lalu 10.86.4.2
dig static.k45.com +short    # abbey.k45.com. lalu 10.86.3.2
```
 
![](assets/soal7-vault-core.png)
![](assets/soal7-cname-2klien.png)
 
---
 
### Soal 8 - Reverse zone dan PTR
 
**Diminta:** pada **prab (ns1)** dideklarasikan *reverse zone* untuk segmen tempat abbey, penny, area vault, dan area core berada. Pada **tedd (ns2)** *reverse zone* tersebut ditarik sebagai *slave*, dengan PTR untuk keempat hostname tersebut agar pencarian balik alamat IP mengembalikan hostname yang benar dan dijawab secara *authoritative*.
 
Node yang dimaksud tersebar pada tiga segmen, sehingga dibuat **tiga reverse zone**:
 
- abbey berada di `10.86.3.0/24` → zona `3.86.10.in-addr.arpa`
- penny berada di `10.86.4.0/24` → zona `4.86.10.in-addr.arpa`
- area vault dan area core berada di `10.86.5.0/24` → zona `5.86.10.in-addr.arpa`
**Di prab**, tambahkan deklarasi ketiga zona. Perintah memakai `>>` agar zona `k45.com` yang sudah ada tidak tertimpa:
 
```sh
cat <<'EOF' >> /etc/bind/named.conf.local
 
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
```
 
Berkas ketiga zona, dengan angka di kolom kiri merupakan oktet terakhir alamat IP:
 
```sh
cat <<'EOF' > /etc/bind/zones/db.10.86.3
$TTL 604800
@   IN  SOA prab.k45.com. admin.k45.com. (
        2026092801 604800 86400 2419200 604800 )
@   IN  NS  prab.k45.com.
@   IN  NS  tedd.k45.com.
2   IN  PTR abbey.k45.com.
EOF
 
cat <<'EOF' > /etc/bind/zones/db.10.86.4
$TTL 604800
@   IN  SOA prab.k45.com. admin.k45.com. (
        2026092801 604800 86400 2419200 604800 )
@   IN  NS  prab.k45.com.
@   IN  NS  tedd.k45.com.
2   IN  PTR penny.k45.com.
EOF
 
cat <<'EOF' > /etc/bind/zones/db.10.86.5
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
```
 
Validasi dan jalankan ulang layanan:
 
```sh
named-checkconf
named-checkzone 3.86.10.in-addr.arpa /etc/bind/zones/db.10.86.3
named-checkzone 4.86.10.in-addr.arpa /etc/bind/zones/db.10.86.4
named-checkzone 5.86.10.in-addr.arpa /etc/bind/zones/db.10.86.5
service named restart || service bind9 restart
```
 
**Di tedd**, tarik ketiga zona sebagai slave:
 
```sh
cat <<'EOF' >> /etc/bind/named.conf.local
 
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
```
 
**Verifikasi:**
 
```sh
dig -x 10.86.3.2 +short              # abbey.k45.com.
dig -x 10.86.4.2 +short              # penny.k45.com.
dig -x 10.86.5.4 +short              # obladi.k45.com.
dig -x 10.86.5.5 +short              # desmond.k45.com.
dig -x 10.86.5.6 +short              # oblada.k45.com.
dig -x 10.86.5.7 +short              # molly.k45.com.
dig @10.86.5.3 -x 10.86.5.7 +short   # tedd juga menjawab
```
 
![](assets/soal8-ptr-prab.png)



![](assets/soal8-ptr-tedd.png)
 
---
 
### Soal 9 - Web statis dengan autoindex pada area vault
 
**Diminta:** menjalankan layanan web statis pada hostname di node **area vault** menggunakan Apache, membuka direktori `/arsip/` dan mengaktifkan fitur **autoindex (directory listing)** pada konfigurasi Apache sehingga seluruh daftar berkas di dalamnya dapat ditelusuri langsung dari browser. Akses pengujian dilakukan melalui hostname, bukan IP address.
 
Blok berikut dijalankan di **obladi** dan **desmond**, isinya identik:
 
```sh
apt update
apt install apache2 -y
 
mkdir -p /var/www/html/arsip
echo "Arsip $(hostname) - dokumen 1" > /var/www/html/arsip/dokumen1.txt
echo "Arsip $(hostname) - dokumen 2" > /var/www/html/arsip/dokumen2.txt
echo "Arsip $(hostname) - catatan"   > /var/www/html/arsip/catatan.txt
 
cat <<'EOF' > /etc/apache2/conf-available/arsip.conf
<Directory /var/www/html/arsip>
    Options +Indexes
    AllowOverride None
    Require all granted
</Directory>
EOF
 
a2enmod autoindex
a2enconf arsip
service apache2 restart
```
 
`Options +Indexes` adalah bagian yang membuat isi direktori ditampilkan sebagai daftar ketika tidak ada berkas indeks di dalamnya.
 
**Verifikasi** dari node client, seluruhnya melalui hostname:
 
```sh
curl http://vault.k45.com/arsip/
curl http://obladi.k45.com/arsip/
curl http://desmond.k45.com/arsip/
```
 
Pengujian melalui browser dibuka pada alamat `http://vault.k45.com/arsip/`.
 
![](assets/soal9-autoindex-browser.png)




![](assets/soal9-curl-vault.png)
 
---
 
### Soal 10 - Web dinamis PHP-FPM dengan URL bersih pada area core
 
**Diminta:** menjalankan layanan web dinamis (PHP-FPM) pada hostname di node **area core** menggunakan nginx, membuat aplikasi sederhana yang memuat halaman **beranda** dan halaman **profil**, serta menerapkan aturan *rewrite* pada server sehingga akses ke `/profil` berfungsi dengan URL bersih (**tanpa akhiran .php**). Akses pengujian dilakukan melalui hostname.
 
Blok berikut dijalankan di **oblada** dan **molly**, isinya identik. Nama *socket* PHP-FPM dideteksi otomatis agar sesuai dengan versi yang terpasang:
 
```sh
apt update
apt install nginx php-fpm -y
 
cat <<'EOF' > /var/www/html/index.php
<?php
echo "<h1>Beranda - " . gethostname() . "</h1>";
echo "<p>Area core, layanan web dinamis k45.com</p>";
echo "<a href='/profil'>Lihat Profil</a>";
?>
EOF
 
cat <<'EOF' > /var/www/html/profil.php
<?php
echo "<h1>Profil - " . gethostname() . "</h1>";
echo "<p>Halaman ini diakses tanpa akhiran .php</p>";
echo "<a href='/'>Kembali ke beranda</a>";
?>
EOF
 
PHPSOCK=$(ls /run/php/php*-fpm.sock | head -1)
 
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
service php8.4-fpm restart 2>/dev/null || service php-fpm restart 2>/dev/null || true
service nginx restart
```
 
Mekanisme URL bersih berada pada dua blok lokasi. Permintaan yang tidak cocok dengan berkas apa pun dilempar ke `@extensionless`, lalu di sana ditulis ulang dengan menambahkan akhiran `.php` secara internal, sehingga `/profil` dilayani oleh `profil.php` tanpa terlihat pada URL.
 
**Verifikasi** melalui hostname:
 
```sh
curl http://core.k45.com/
curl http://core.k45.com/profil
curl http://oblada.k45.com/profil
curl http://molly.k45.com/profil
```
 
![](assets/soal10-beranda.png)
![](assets/soal10-profil-cleanurl.png)
 
---
 
## Blok Konfigurasi Lengkap per Node
 
Bagian ini memuat seluruh konfigurasi tiap node dalam satu blok utuh, mencakup soal 1 sampai 10. Blok dijalankan pada console node yang bersangkutan dan dapat dijalankan berulang kali tanpa efek samping.
 
**Urutan menjalankan: rootkit → prab → tedd → node host → node web.** rootkit didahulukan karena node lain membutuhkan jalur keluar untuk mengunduh paket, dan prab didahulukan sebelum node yang memakai nama domain.
 
### rootkit
 
```sh
hostname rootkit
echo rootkit > /etc/hostname
grep -q "127.0.1.1 rootkit" /etc/hosts || echo "127.0.1.1 rootkit" >> /etc/hosts
 
cat <<'EOF' > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp
 
auto eth1
iface eth1 inet static
  address 10.86.1.1
  netmask 255.255.255.0
 
auto eth2
iface eth2 inet static
  address 10.86.2.1
  netmask 255.255.255.0
 
auto eth3
iface eth3 inet static
  address 10.86.3.1
  netmask 255.255.255.0
 
auto eth4
iface eth4 inet static
  address 10.86.4.1
  netmask 255.255.255.0
 
auto eth5
iface eth5 inet static
  address 10.86.5.1
  netmask 255.255.255.0
EOF
 
service networking restart
 
echo 1 > /proc/sys/net/ipv4/ip_forward
which iptables >/dev/null 2>&1 || (apt update && apt install iptables -y)
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE -s 10.86.0.0/16 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.86.0.0/16
 
ping -c 2 google.com
```
 
### prab (DNS master, zona forward dan reverse)
 
```sh
hostname prab
echo prab > /etc/hostname
grep -q "127.0.1.1 prab" /etc/hosts || echo "127.0.1.1 prab" >> /etc/hosts
 
cat <<'EOF' > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.86.5.2
  netmask 255.255.255.0
  gateway 10.86.5.1
EOF
service networking restart
 
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install bind9 dnsutils -y
mkdir -p /etc/bind/zones
 
cat <<'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders { 192.168.122.1; };
    dnssec-validation no;
};
EOF
 
cat <<'EOF' > /etc/bind/named.conf.local
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
 
cat <<'EOF' > /etc/bind/zones/db.k45.com
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
 
cat <<'EOF' > /etc/bind/zones/db.10.86.3
$TTL 604800
@   IN  SOA prab.k45.com. admin.k45.com. (
        2026092801 604800 86400 2419200 604800 )
@   IN  NS  prab.k45.com.
@   IN  NS  tedd.k45.com.
2   IN  PTR abbey.k45.com.
EOF
 
cat <<'EOF' > /etc/bind/zones/db.10.86.4
$TTL 604800
@   IN  SOA prab.k45.com. admin.k45.com. (
        2026092801 604800 86400 2419200 604800 )
@   IN  NS  prab.k45.com.
@   IN  NS  tedd.k45.com.
2   IN  PTR penny.k45.com.
EOF
 
cat <<'EOF' > /etc/bind/zones/db.10.86.5
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
 
named-checkconf
named-checkzone k45.com /etc/bind/zones/db.k45.com
service named restart || service bind9 restart
 
cat <<'EOF' > /etc/resolv.conf
nameserver 10.86.5.2
nameserver 10.86.5.3
nameserver 192.168.122.1
EOF
 
dig @127.0.0.1 k45.com +short
```
 
### tedd (DNS slave)
 
```sh
hostname tedd
echo tedd > /etc/hostname
grep -q "127.0.1.1 tedd" /etc/hosts || echo "127.0.1.1 tedd" >> /etc/hosts
 
cat <<'EOF' > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.86.5.3
  netmask 255.255.255.0
  gateway 10.86.5.1
EOF
service networking restart
 
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update
apt install bind9 dnsutils -y
 
cat <<'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders { 192.168.122.1; };
    dnssec-validation no;
};
EOF
 
cat <<'EOF' > /etc/bind/named.conf.local
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
 
cat <<'EOF' > /etc/resolv.conf
nameserver 10.86.5.2
nameserver 10.86.5.3
nameserver 192.168.122.1
EOF
 
dig @127.0.0.1 k45.com SOA +short
```
 
### Node client (alpha, beta, gamma, delta, epsilon, abbey, penny)
 
Blok berikut dijalankan di setiap node client dengan **mengganti baris pertama saja**:
 
```sh
HOST=alpha; IP=10.86.1.2; GW=10.86.1.1
 
hostname $HOST
echo $HOST > /etc/hostname
grep -q "127.0.1.1 $HOST" /etc/hosts || echo "127.0.1.1 $HOST" >> /etc/hosts
 
cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address $IP
  netmask 255.255.255.0
  gateway $GW
EOF
service networking restart
 
cat > /etc/resolv.conf <<EOF
nameserver 10.86.5.2
nameserver 10.86.5.3
nameserver 192.168.122.1
EOF
 
which dig >/dev/null 2>&1 || (apt update && apt install dnsutils -y)
```
 
| Node    | Baris pertama                              |
| ------- | ------------------------------------------ |
| alpha   | `HOST=alpha; IP=10.86.1.2; GW=10.86.1.1`   |
| beta    | `HOST=beta; IP=10.86.1.3; GW=10.86.1.1`    |
| gamma   | `HOST=gamma; IP=10.86.1.4; GW=10.86.1.1`   |
| delta   | `HOST=delta; IP=10.86.2.2; GW=10.86.2.1`   |
| epsilon | `HOST=epsilon; IP=10.86.2.3; GW=10.86.2.1` |
| abbey   | `HOST=abbey; IP=10.86.3.2; GW=10.86.3.1`   |
| penny   | `HOST=penny; IP=10.86.4.2; GW=10.86.4.1`   |
 
### Node web statis (obladi, desmond)
 
Ganti baris pertama sesuai node: `HOST=obladi; IP=10.86.5.4` atau `HOST=desmond; IP=10.86.5.5`.
 
```sh
HOST=obladi; IP=10.86.5.4
 
hostname $HOST
echo $HOST > /etc/hostname
grep -q "127.0.1.1 $HOST" /etc/hosts || echo "127.0.1.1 $HOST" >> /etc/hosts
 
cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address $IP
  netmask 255.255.255.0
  gateway 10.86.5.1
EOF
service networking restart
 
cat > /etc/resolv.conf <<EOF
nameserver 10.86.5.2
nameserver 10.86.5.3
nameserver 192.168.122.1
EOF
 
apt update
apt install apache2 -y
 
mkdir -p /var/www/html/arsip
echo "Arsip $(hostname) - dokumen 1" > /var/www/html/arsip/dokumen1.txt
echo "Arsip $(hostname) - dokumen 2" > /var/www/html/arsip/dokumen2.txt
echo "Arsip $(hostname) - catatan"   > /var/www/html/arsip/catatan.txt
 
cat <<'EOF' > /etc/apache2/conf-available/arsip.conf
<Directory /var/www/html/arsip>
    Options +Indexes
    AllowOverride None
    Require all granted
</Directory>
EOF
 
a2enmod autoindex
a2enconf arsip
service apache2 restart
 
curl -s http://localhost/arsip/ | head -20
```
 
### Node web dinamis (oblada, molly)
 
Ganti baris pertama sesuai node: `HOST=oblada; IP=10.86.5.6` atau `HOST=molly; IP=10.86.5.7`.
 
```sh
HOST=oblada; IP=10.86.5.6
 
hostname $HOST
echo $HOST > /etc/hostname
grep -q "127.0.1.1 $HOST" /etc/hosts || echo "127.0.1.1 $HOST" >> /etc/hosts
 
cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
  address $IP
  netmask 255.255.255.0
  gateway 10.86.5.1
EOF
service networking restart
 
cat > /etc/resolv.conf <<EOF
nameserver 10.86.5.2
nameserver 10.86.5.3
nameserver 192.168.122.1
EOF
 
apt update
apt install nginx php-fpm -y
 
cat <<'EOF' > /var/www/html/index.php
<?php
echo "<h1>Beranda - " . gethostname() . "</h1>";
echo "<p>Area core, layanan web dinamis k45.com</p>";
echo "<a href='/profil'>Lihat Profil</a>";
?>
EOF
 
cat <<'EOF' > /var/www/html/profil.php
<?php
echo "<h1>Profil - " . gethostname() . "</h1>";
echo "<p>Halaman ini diakses tanpa akhiran .php</p>";
echo "<a href='/'>Kembali ke beranda</a>";
?>
EOF
 
PHPSOCK=$(ls /run/php/php*-fpm.sock | head -1)
 
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
service php8.4-fpm restart 2>/dev/null || service php-fpm restart 2>/dev/null || true
service nginx restart
 
curl -s http://localhost/profil | head -10
```
 
---
 
## Verifikasi Menyeluruh
 
Dijalankan dari node client (misalnya alpha) setelah seluruh node dikonfigurasi:
 
```sh
# konektivitas dan jalur keluar
ping -c 2 10.86.5.1                  # gateway segmen server
ping -c 2 10.86.2.2                  # delta, lintas segmen
ping -c 2 google.com                 # akses keluar via NAT
 
# resolusi nama
dig k45.com +short                   # 10.86.4.2
dig prab.k45.com +short              # 10.86.5.2
dig molly.k45.com +short             # 10.86.5.7
dig vault.k45.com +short             # 10.86.5.4 dan 10.86.5.5
dig core.k45.com +short              # 10.86.5.6 dan 10.86.5.7
dig www.k45.com +short               # penny.k45.com. lalu 10.86.4.2
dig static.k45.com +short            # abbey.k45.com. lalu 10.86.3.2
 
# konsistensi kedua name server
dig @10.86.5.2 k45.com SOA +short
dig @10.86.5.3 k45.com SOA +short
 
# pencarian balik
dig -x 10.86.3.2 +short              # abbey.k45.com.
dig -x 10.86.5.6 +short              # oblada.k45.com.
 
# layanan web
curl -s http://vault.k45.com/arsip/ | head -20
curl -s http://core.k45.com/
curl -s http://core.k45.com/profil
```
 
Bila salah satu `dig` menghasilkan `connection refused` ke `10.86.5.2#53` atau `10.86.5.3#53`, layanan bind pada prab atau tedd sedang tidak berjalan, dan blok node tersebut dijalankan kembali. Bila `ping google.com` gagal sementara `ping` ke alamat internal berhasil, aturan *forwarding* dan NAT pada rootkit dijalankan kembali.
 
## 11. Reverse Proxy dan Load Balancing

Konfigurasikan **Penny** menggunakan Apache sebagai *reverse proxy* menuju seluruh node pada area **vault** (Obladi & Desmond). Konfigurasikan **Abbey** menggunakan Nginx sebagai *reverse proxy* menuju area **core** (Oblada & Molly).

Pastikan kedua gateway meneruskan identitas asli pengunjung dengan melakukan *forwarding* header **Host** dan **X-Real-IP**. Buktikan bahwa Penny dan Abbey berhasil mendistribusikan lalu lintas dengan tepat.

Membuat Penny dan Abbey sebagai gateway yang meneruskan request dari client menuju server backend.

* Penny → Obladi (`10.86.5.4`) dan Desmond (`10.86.5.5`)
* Abbey → Oblada (`10.86.5.6`) dan Molly (`10.86.5.7`)
* Meneruskan header `Host`
* Meneruskan header `X-Real-IP`
* Membuktikan bahwa traffic berhasil didistribusikan ke seluruh backend

---

### A. Konfigurasi Penny sebagai Reverse Proxy

#### 1. Install dan aktifkan module Apache

Pada node **Penny**, aktifkan module yang diperlukan:

```bash
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests
a2enmod headers
```

#### 2. Membuat konfigurasi Reverse Proxy

Buat file:

```bash
nano /etc/apache2/sites-available/reverse-proxy.conf
```

Isi konfigurasi:

```apache
<VirtualHost *:80>
    ServerName www.k45.com

    ProxyPreserveHost On

    RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}

    <Proxy "balancer://vault">
        BalancerMember http://10.86.5.4
        BalancerMember http://10.86.5.5
        ProxySet lbmethod=byrequests
    </Proxy>

    ProxyPass "/" "balancer://vault/"
    ProxyPassReverse "/" "balancer://vault/"

    ErrorLog ${APACHE_LOG_DIR}/vault-proxy-error.log
    CustomLog ${APACHE_LOG_DIR}/vault-proxy-access.log combined
</VirtualHost>
```

Konfigurasi tersebut membuat Apache menggunakan Obladi dan Desmond sebagai backend serta menggunakan metode `byrequests` untuk membagi request.

#### 3. Mengaktifkan konfigurasi

```bash
a2dissite 000-default.conf
a2ensite reverse-proxy.conf
apache2ctl configtest
```

Hasil:

<img width="689" height="47" alt="Screenshot 2026-09-30 at 02 05 35" src="https://github.com/user-attachments/assets/db1a6009-2a24-49bd-81c4-f1487acf558f" />

```text
Syntax OK
```

#### 4. Restart Apache

```bash
service apache2 restart
```

#### 5. Pengujian Reverse Proxy

Pengujian dilakukan dengan mengakses file pada area vault melalui Penny:

```bash
curl -s -H "Host: www.k45.com" http://10.86.4.2/arsip/dokumen1.txt
```

Hasil:

```text
Arsip desmond - dokumen 1
```

#### 6. Pengujian Load Balancing

Untuk memastikan request didistribusikan ke kedua backend:

```bash
for i in 1 2 3 4 5 6 7 8 9 10; do
    curl -s -H "Host: www.k45.com" http://10.86.4.2/arsip/dokumen1.txt
done
```

Hasil:

<img width="692" height="263" alt="Screenshot 2026-09-30 at 02 04 47" src="https://github.com/user-attachments/assets/8e8f4c63-58ea-47af-8296-de04f6274d4d" />


```text
Arsip obladi - dokumen 1
Arsip desmond - dokumen 1
Arsip obladi - dokumen 1
Arsip desmond - dokumen 1
Arsip obladi - dokumen 1
Arsip desmond - dokumen 1
Arsip obladi - dokumen 1
Arsip desmond - dokumen 1
Arsip obladi - dokumen 1
Arsip desmond - dokumen 1
```

Hasil tersebut membuktikan bahwa Penny berhasil mendistribusikan request ke **Obladi dan Desmond**.

### B. Konfigurasi Abbey sebagai Reverse Proxy

#### 1. Install Nginx

Pada node **Abbey**:

```bash
apt update
apt install nginx -y
```

Cek versi Nginx:

```bash
nginx -v
```

Hasil:

```text
nginx version: nginx/1.26.3
```

#### 2. Membuat konfigurasi Reverse Proxy

Edit konfigurasi:

```bash
nano /etc/nginx/sites-available/default
```

Isi:

```nginx
upstream core_backend {
    server 10.86.5.6;
    server 10.86.5.7;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name static.k45.com;

    location / {
        proxy_pass http://core_backend;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Konfigurasi tersebut membuat Abbey menggunakan Oblada dan Molly sebagai backend.

#### 3. Mengecek konfigurasi Nginx

```bash
nginx -t
```

Hasil:

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

#### 4. Menjalankan Nginx

```bash
nginx
```

#### 5. Pengujian Reverse Proxy

```bash
curl -s -H "Host: static.k45.com" http://10.86.3.2/
```

Hasil:

```html
<h1>Beranda - oblada</h1><p>Area core, layanan web dinamis k45.com</p><a href='/profil'>Lihat Profil</a>
```

#### 6. Pengujian Load Balancing

```bash
for i in 1 2 3 4 5 6 7 8 9 10; do
    curl -s -H "Host: static.k45.com" http://10.86.3.2/profil
    echo
done
```

Hasil:

```text
<h1>Profil - oblada</h1><p>Halaman ini diakses tanpa akhiran .php</p><a href='/'>Kembali ke beranda</a>
<h1>Profil - oblada</h1><p>Halaman ini diakses tanpa akhiran .php</p><a href='/'>Kembali ke beranda</a>
<h1>Profil - oblada</h1><p>Halaman ini diakses tanpa akhiran .php</p><a href='/'>Kembali ke beranda</a>
<h1>Profil - molly</h1><p>Halaman ini diakses tanpa akhiran .php</p><a href='/'>Kembali ke beranda</a>
<h1>Profil - oblada</h1><p>Halaman ini diakses tanpa akhiran .php</p><a href='/'>Kembali ke beranda</a>
<h1>Profil - molly</h1><p>Halaman ini diakses tanpa akhiran .php</p><a href='/'>Kembali ke beranda</a>
<h1>Profil - oblada</h1><p>Halaman ini diakses tanpa akhiran .php</p><a href='/'>Kembali ke beranda</a>
<h1>Profil - molly</h1><p>Halaman ini diakses tanpa akhiran .php</p><a href='/'>Kembali ke beranda</a>
<h1>Profil - oblada</h1><p>Halaman ini diakses tanpa akhiran .php</p><a href='/'>Kembali ke beranda</a>
<h1>Profil - molly</h1><p>Halaman ini diakses tanpa akhiran .php</p><a href='/'>Kembali ke beranda</a>
```

Hasil tersebut membuktikan bahwa Abbey berhasil mendistribusikan request ke **Oblada dan Molly**.

<img width="693" height="374" alt="Screenshot 2026-09-30 at 02 04 09" src="https://github.com/user-attachments/assets/9d2297bb-8304-46e5-93ce-cf653c033998" />


### Hasil Akhir

| Gateway | Backend | IP          | Status   |
| ------- | ------- | ----------- | -------- |
| Penny   | Obladi  | `10.86.5.4` | Berhasil |
| Penny   | Desmond | `10.86.5.5` | Berhasil |
| Abbey   | Oblada  | `10.86.5.6` | Berhasil |
| Abbey   | Molly   | `10.86.5.7` | Berhasil |

Penny berhasil dikonfigurasi sebagai reverse proxy Apache untuk area vault dan berhasil mendistribusikan request ke Obladi dan Desmond.

Abbey berhasil dikonfigurasi sebagai reverse proxy Nginx untuk area core dan berhasil mendistribusikan request ke Oblada dan Molly.

## 12. Basic Authentication pada `/admin`

Membuat Basic Authentication pada path `/admin` di server **Penny**. Hanya username `prabs` dengan password yang telah ditentukan yang dapat mengakses halaman tersebut.


Membatasi akses ke halaman `/admin` menggunakan username dan password. Path `/admin` juga harus menjadi halaman lokal di Penny dan tidak diteruskan ke backend reverse proxy.

### Langkah-Langkah

#### 1. Install `apache2-utils`

Pada server Penny:

```bash
apt update
apt install apache2-utils -y
```

Package `apache2-utils` sudah tersedia pada sistem.

#### 2. Membuat username dan password

Membuat file password `/etc/apache2/.htpasswd` dengan username `prabs`:

```bash
htpasswd -c /etc/apache2/.htpasswd prabs
```

Password dimasukkan sesuai ketentuan soal.

Verifikasi:

```bash
cat /etc/apache2/.htpasswd
```

Hasil menunjukkan user `prabs` telah tersimpan dalam bentuk hash.

#### 3. Membuat halaman admin

Membuat direktori:

```bash
mkdir -p /var/www/admin
```

Kemudian membuat halaman:

```bash
cat > /var/www/admin/index.html <<'EOF'
<h1>Admin Area - Penny</h1>
<p>Selamat datang di halaman admin.</p>
EOF
```

#### 4. Mengatur Basic Authentication

File konfigurasi reverse proxy Penny:

```bash
nano /etc/apache2/sites-available/reverse-proxy.conf
```

Konfigurasi `/admin` ditambahkan sebelum reverse proxy utama:

```apache
ProxyPass "/admin" "!"

Alias /admin /var/www/admin

<Directory /var/www/admin>
    AuthType Basic
    AuthName "Admin Area"
    AuthUserFile /etc/apache2/.htpasswd
    Require user prabs
</Directory>

ProxyPass "/" "balancer://vault/"
ProxyPassReverse "/" "balancer://vault/"
```

`ProxyPass "/admin" "!"` digunakan agar `/admin` tidak diteruskan ke backend Obladi dan Desmond.

Sedangkan:

```apache
Require user prabs
```

membatasi akses hanya untuk username `prabs`.

#### 5. Mengecek konfigurasi Apache

```bash
apache2ctl configtest
```

Hasil:

```text
Syntax OK
```

Terdapat warning `AH00558` mengenai `ServerName`, tetapi konfigurasi tetap dinyatakan valid dengan `Syntax OK`.

#### 6. Restart Apache

```bash
service apache2 restart
```

Apache berhasil di-restart.

#### 7. Pengujian tanpa autentikasi

```bash
curl -i -H "Host: www.k45.com" http://10.86.4.2/admin
```

Hasil:

```text
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="Admin Area"
```

Artinya halaman `/admin` meminta autentikasi.

#### 8. Pengujian dengan user `prabs`

```bash
curl -i -u 'prabs:pakar_pinter_jadi_gob***' \
-H "Host: www.k45.com" \
http://10.86.4.2/admin/
```

Hasil:

```text
HTTP/1.1 200 OK
```

Isi halaman:

```html
<h1>Admin Area - Penny</h1>
<p>Selamat datang di halaman admin.</p>
```

Artinya user `prabs` berhasil melakukan autentikasi dan dapat mengakses halaman admin.

#### 9. Pengujian menggunakan username lain

Untuk memastikan hanya `prabs` yang diperbolehkan:

```bash
curl -i -u 'admin:pakar_pinter_jadi_gob***' \
-H "Host: www.k45.com" \
http://10.86.4.2/admin/
```

Hasil:

```text
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="Admin Area"
```

Artinya username `admin` ditolak.

### Hasil

<img width="688" height="265" alt="Screenshot 2026-09-30 at 02 31 16" src="https://github.com/user-attachments/assets/02cde83f-edcf-47b1-80b8-dcc0f3c9e584" />

<img width="691" height="338" alt="Screenshot 2026-09-30 at 02 31 33" src="https://github.com/user-attachments/assets/4d4b56f4-61bc-4aea-858f-1bbdaef9efc6" />


| Pengujian                               | Hasil              |
| --------------------------------------- | ------------------ |
| Tanpa username/password                 | `401 Unauthorized` |
| User `prabs` + password benar           | `200 OK`           |
| User `admin` + password benar           | `401 Unauthorized` |
| `/admin` diteruskan ke backend          | Tidak              |
| `/admin` berjalan secara lokal di Penny | Ya                 |

### Kesimpulan

Basic Authentication pada path `/admin` berhasil diterapkan di Penny. Halaman `/admin` meminta autentikasi, username `prabs` berhasil masuk, sedangkan username lain ditolak dengan status `401 Unauthorized`.

## 13. Canonical Redirect

Membuat canonical redirect pada web server:

* Penny: `penny.xxx.com` diarahkan secara **permanen (301)** ke `www.xxx.com`.
* Abbey: `abbey.xxx.com` diarahkan secara **sementara (302)** ke `static.xxx.com`.
* Redirect juga harus berlaku ketika server diakses menggunakan IP address.

Pada praktikum ini digunakan domain `k45.com`.

Membuat redirect otomatis dari domain/IP tertentu menuju domain utama yang telah ditentukan, dengan membedakan jenis redirect:

* **301 Permanent Redirect** pada Penny.
* **302 Temporary Redirect** pada Abbey.

### Langkah-Langkah

#### 1. Konfigurasi Penny

Konfigurasi Penny berada di:

```bash
/etc/apache2/sites-available/reverse-proxy.conf
```

Tambahkan `RewriteEngine` dan aturan redirect berikut di dalam `<VirtualHost *:80>`:

```apache
RewriteEngine On

RewriteCond %{HTTP_HOST} ^penny\.k45\.com$ [NC,OR]
RewriteCond %{HTTP_HOST} ^10\.86\.4\.2$ [NC]
RewriteRule ^/(.*)$ http://www.k45.com/$1 [R=301,L]
```

Aktifkan modul rewrite:

```bash
a2enmod rewrite
```

Kemudian lakukan pengecekan konfigurasi:

```bash
apache2ctl configtest
```

Hasil:

```text
Syntax OK
```

Restart Apache:

```bash
service apache2 restart
```

#### 2. Verifikasi Redirect Penny

Pengujian menggunakan domain:

```bash
curl -I -H "Host: penny.k45.com" http://10.86.4.2/
```

Hasil menunjukkan:

```text
HTTP/1.1 301 Moved Permanently
Location: http://www.k45.com/
```

Pengujian menggunakan IP secara langsung:

```bash
curl -I http://10.86.4.2/
```

Hasil:

```text
HTTP/1.1 301 Moved Permanently
Location: http://www.k45.com/
```

Dengan demikian, akses melalui `penny.k45.com` maupun IP `10.86.4.2` berhasil diarahkan secara permanen ke `www.k45.com`.

#### 3. Konfigurasi Abbey

Konfigurasi Nginx berada di:

```bash
/etc/nginx/sites-available/default
```

Konfigurasi redirect yang digunakan:

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name abbey.k45.com 10.86.3.2;

    return 302 http://static.k45.com$request_uri;
}
```

Konfigurasi reverse proxy `static.k45.com` tetap dipertahankan untuk meneruskan request ke Oblada dan Molly.

Setelah konfigurasi selesai, dilakukan pengecekan:

```bash
nginx -t
```

Hasil:

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Kemudian konfigurasi dimuat ulang:

```bash
nginx -s reload
```

#### 4. Verifikasi Redirect Abbey

Pengujian menggunakan domain:

```bash
curl -I -H "Host: abbey.k45.com" http://10.86.3.2/
```

Hasil:

```text
HTTP/1.1 302 Moved Temporarily
Location: http://static.k45.com/
```

Pengujian menggunakan IP secara langsung:

```bash
curl -I http://10.86.3.2/
```

Hasil:

```text
HTTP/1.1 302 Moved Temporarily
Location: http://static.k45.com/
```

Dengan demikian, akses melalui `abbey.k45.com` maupun IP `10.86.3.2` berhasil diarahkan sementara ke `static.k45.com`.

### Hasil

<img width="690" height="298" alt="Screenshot 2026-09-30 at 02 40 33" src="https://github.com/user-attachments/assets/34cda9e6-2f52-4165-a491-9829b05831b1" />

| Server | Akses           | Status | Tujuan           |
| ------ | --------------- | -----: | ---------------- |
| Penny  | `penny.k45.com` |    301 | `www.k45.com`    |
| Penny  | `10.86.4.2`     |    301 | `www.k45.com`    |
| Abbey  | `abbey.k45.com` |    302 | `static.k45.com` |
| Abbey  | `10.86.3.2`     |    302 | `static.k45.com` |

### Kesimpulan

Canonical redirect berhasil diterapkan pada kedua server. Penny menggunakan **301 Permanent Redirect**, sedangkan Abbey menggunakan **302 Temporary Redirect**. Pengujian melalui domain maupun IP menunjukkan hasil redirect sesuai dengan ketentuan praktikum.

## 14. Access Log IP Client Asli

### Soal

Pastikan access log pada setiap web server di dalam `vault` dan `core` mencatat **IP asli client**, bukan IP dari reverse proxy (Penny atau Abbey).

### Tujuan

Membuat web server backend dapat mencatat IP asli client yang mengakses layanan, meskipun request melewati reverse proxy.

### Langkah-Langkah

#### 1. Konfigurasi Apache pada Vault

Pada server **Obladi** dan **Desmond**, ditambahkan format log baru pada `/etc/apache2/apache2.conf`:

```apache
LogFormat "%{X-Real-IP}i %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" realip
```

Kemudian konfigurasi `CustomLog` pada `/etc/apache2/sites-enabled/000-default.conf` diubah menjadi:

```apache
CustomLog ${APACHE_LOG_DIR}/access.log realip
```

Konfigurasi dicek menggunakan:

```bash
apache2ctl configtest
```

Hasil:

```text
Syntax OK
```

Apache kemudian di-restart agar konfigurasi baru aktif.

#### 2. Konfigurasi Reverse Proxy Penny

Penny mengirimkan IP client melalui header `X-Real-IP` menggunakan:

```apache
RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}
```

Dengan demikian, IP client diteruskan dari Penny menuju server backend Vault.

#### 3. Konfigurasi Reverse Proxy Abbey

Abbey meneruskan IP client ke backend Core menggunakan:

```nginx
proxy_set_header X-Real-IP $remote_addr;
```

#### 4. Konfigurasi Nginx pada Core

Pada **Oblada** dan **Molly**, ditambahkan format log pada `/etc/nginx/nginx.conf`:

```nginx
log_format realip '$http_x_real_ip - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" "$http_user_agent"';
```

Kemudian pada `/etc/nginx/sites-available/default` ditambahkan:

```nginx
access_log /var/log/nginx/access.log realip;
```

Konfigurasi dicek dengan:

```bash
nginx -t
```

Hasil:

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Kemudian konfigurasi diterapkan dengan:

```bash
nginx -s reload
```

#### 5. Pengujian dari Alpha

Request dikirim dari **Alpha (`10.86.1.2`)** melalui Abbey:

```bash
curl -H "Host: static.k45.com" http://10.86.3.2/profil
```

Kemudian dilakukan beberapa request:

```bash
for i in $(seq 1 10); do
    curl -s -H "Host: static.k45.com" http://10.86.3.2/profil
    echo
done
```

#### 6. Verifikasi Log Oblada

Pada Oblada:

```bash
tail -10 /var/log/nginx/access.log
```

Hasil menunjukkan:

```text
10.86.1.2 - - [29/Sep/2026:19:26:36 +0000] "GET /profil HTTP/1.0" 200 ...
10.86.1.2 - - [29/Sep/2026:19:26:50 +0000] "GET /profil HTTP/1.0" 200 ...
```

IP `10.86.1.2` merupakan IP Alpha.

#### 7. Verifikasi Log Molly

Pada Molly:

```bash
tail -10 /var/log/nginx/access.log
```

Hasil menunjukkan:

```text
10.86.1.2 - - [29/Sep/2026:19:26:50 +0000] "GET /profil HTTP/1.0" 200 ...
```

IP `10.86.1.2` juga tercatat pada Molly.

### Hasil

Pengujian membuktikan bahwa:

| Server Backend | IP yang tercatat | Keterangan    |
| -------------- | ---------------- | ------------- |
| Oblada         | `10.86.1.2`      | IP asli Alpha |
| Molly          | `10.86.1.2`      | IP asli Alpha |

Sebelumnya request yang berasal dari reverse proxy dapat terlihat sebagai `10.86.3.2` (IP Abbey). Setelah konfigurasi `X-Real-IP`, server backend mencatat `10.86.1.2`, yaitu IP asli client.

### Kesimpulan

Konfigurasi access log pada seluruh server backend `vault` dan `core` telah berhasil. IP asli client dapat diteruskan melalui reverse proxy dan tercatat pada access log backend.

<img width="692" height="215" alt="Screenshot 2026-09-30 at 02 58 52" src="https://github.com/user-attachments/assets/18e41951-234c-48b0-a018-68bd1245250f" />

<img width="694" height="365" alt="Screenshot 2026-09-30 at 02 59 20" src="https://github.com/user-attachments/assets/1ab970d6-7e04-4667-8676-699b2e74b87b" />

## 15. Konfigurasi Web Server `/eternal` dan `/orion`

### A. Penny — `/eternal`

Pada server **Penny (`10.86.4.2`)**, dibuat path `/eternal` yang mengarah ke directory `/var/www/eternal`.

Path ini digunakan untuk menjalankan file PHP menggunakan **PHP-FPM**.

#### 1. Membuat directory

```bash
mkdir -p /var/www/eternal
```

#### 2. Membuat file PHP

```bash
cat > /var/www/eternal/index.php <<'EOF'
<?php
echo "ETERNAL PHP BERHASIL";
?>
EOF
```

#### 3. Mengatur permission

```bash
chown -R www-data:www-data /var/www/eternal
chmod -R 755 /var/www/eternal
```

#### 4. Membuat konfigurasi Apache

File konfigurasi:

```text
/etc/apache2/conf-available/eternal.conf
```

Konfigurasi:

```apache
ProxyPass "/eternal/" "!"

Alias /eternal/ /var/www/eternal/

<Directory /var/www/eternal>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
    DirectoryIndex index.php index.html

    <FilesMatch "\.php$">
        SetHandler "proxy:unix:/run/php/php8.4-fpm.sock|fcgi://localhost/"
    </FilesMatch>
</Directory>
```

`ProxyPass "/eternal/" "!"` digunakan agar request `/eternal/` tidak diteruskan ke reverse proxy backend, tetapi dilayani langsung oleh Penny.

`Alias` menghubungkan URL `/eternal/` dengan directory `/var/www/eternal/`.

`SetHandler` digunakan agar file PHP diproses oleh PHP-FPM.

#### 5. Enable konfigurasi

```bash
a2enconf eternal
```

#### 6. Mengecek konfigurasi Apache

```bash
apache2ctl configtest
```

Hasil:

```text
Syntax OK
```

#### 7. Reload Apache

```bash
apache2ctl -k graceful
```

#### 8. Mengecek socket PHP-FPM

```bash
find /run/php -maxdepth 1 -type s -name '*.sock'
```

Hasil:

```text
/run/php/php8.4-fpm.sock
```

#### 9. Pengujian melalui localhost

```bash
curl http://localhost/eternal/
```

Hasil:

```text
ETERNAL PHP BERHASIL
```

#### 10. Pengujian melalui hostname

```bash
curl http://penny.k45.com/eternal/
```

Hasil:

```text
ETERNAL PHP BERHASIL
```

Hasil tersebut menunjukkan bahwa file PHP pada `/eternal` berhasil dieksekusi menggunakan PHP-FPM.

---

### B. Abbey — `/orion`

Pada server **Abbey (`10.86.3.2`)**, dibuat path `/orion` yang mengarah ke directory `/var/www/orion`.

Berbeda dengan `/eternal`, directory `/orion` dibuat sebagai **static directory**, sehingga file PHP di dalamnya tidak dieksekusi.

#### 1. Membuat directory

```bash
mkdir -p /var/www/orion
```

#### 2. Membuat file `index.html`

```bash
cat > /var/www/orion/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Orion</title>
</head>
<body>
    <h1>ORION STATIC BERHASIL</h1>
</body>
</html>
EOF
```

#### 3. Membuat file PHP untuk pengujian

```bash
cat > /var/www/orion/test.php <<'EOF'
<?php
echo "PHP INI TIDAK BOLEH DIEKSEKUSI";
?>
EOF
```

#### 4. Mengatur permission

```bash
chown -R www-data:www-data /var/www/orion
chmod -R 755 /var/www/orion
```

#### 5. Membuat konfigurasi Nginx

File:

```text
/etc/nginx/conf.d/orion.conf
```

Konfigurasi:

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name static.k45.com;

    location ^~ /orion/ {
        root /var/www;
        index index.html;
        try_files $uri $uri/ =404;
    }
}
```

`location ^~ /orion/` digunakan agar request pada `/orion/` diproses sebagai static content.

Tidak terdapat konfigurasi PHP-FPM pada location tersebut, sehingga file `.php` tidak dieksekusi.

#### 6. Mengecek konfigurasi Nginx

```bash
nginx -t
```

Hasil:

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

#### 7. Reload Nginx

```bash
nginx -s reload
```

#### 8. Pengujian `index.html`

```bash
curl -H "Host: static.k45.com" http://127.0.0.1/orion/
```

Hasil:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Orion</title>
</head>
<body>
    <h1>ORION STATIC BERHASIL</h1>
</body>
</html>
```

#### 9. Pengujian bahwa PHP tidak dieksekusi

```bash
curl -H "Host: static.k45.com" http://127.0.0.1/orion/test.php
```

Hasil:

```php
<?php
echo "PHP INI TIDAK BOLEH DIEKSEKUSI";
?>
```

Karena source code PHP ditampilkan secara langsung, PHP tidak dieksekusi oleh Nginx.

#### 10. Pengujian menggunakan hostname

```bash
getent hosts static.k45.com
```

Hasil:

```text
10.86.3.2    abbey.k45.com static.k45.com
```

Kemudian:

```bash
curl http://static.k45.com/orion/
```

Hasil:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Orion</title>
</head>
<body>
    <h1>ORION STATIC BERHASIL</h1>
</body>
</html>
```

Pengujian file PHP:

```bash
curl http://static.k45.com/orion/test.php
```

Hasil:

```php
<?php
echo "PHP INI TIDAK BOLEH DIEKSEKUSI";
?>
```

### Kesimpulan

Konfigurasi No. 15 berhasil:

* **Penny `/eternal`** berhasil melayani dan mengeksekusi PHP menggunakan PHP-FPM.
* **Abbey `/orion`** berhasil melayani static content.
* File PHP pada `/orion` tidak dieksekusi dan ditampilkan sebagai source code.
* DNS `static.k45.com` berhasil mengarah ke Abbey (`10.86.3.2`).

# No. 16 — ApacheBench

## Tujuan

Melakukan pengujian performa HTTP menggunakan ApacheBench (`ab`) dengan:

* Total request: `250`
* Concurrency: `10`
* Target:

  * `http://www.k45.com/`
  * `http://static.k45.com/`

---

## 1. Install ApacheBench

Pengujian dilakukan dari **Alpha**.

```bash
apt update
apt install apache2-utils -y
```

Verifikasi:

```bash
which ab
ab -V
```

Output:

```text
/usr/bin/ab

This is ApacheBench, Version 2.3
```

> Catatan: repository `debian-security` sempat menghasilkan error signature verification, tetapi paket `apache2-utils` tetap berhasil diinstal dari repository Debian utama.

---

## 2. Verifikasi DNS

```bash
getent hosts www.k45.com
getent hosts static.k45.com
```

Hasil:

```text
10.86.4.2       penny.k45.com www.k45.com
10.86.3.2       abbey.k45.com static.k45.com
```

Artinya:

* `www.k45.com` mengarah ke Penny (`10.86.4.2`)
* `static.k45.com` mengarah ke Abbey (`10.86.3.2`)

---

## 3. Verifikasi HTTP

### [www.k45.com](http://www.k45.com)

```bash
curl -I http://www.k45.com/
```

Hasil:

```text
HTTP/1.1 200 OK
Server: Apache/2.4.68 (Debian)
Content-Length: 10703
Content-Type: text/html
```

### static.k45.com

```bash
curl -I http://static.k45.com/
```

Hasil:

```text
HTTP/1.1 200 OK
Server: nginx
Content-Length: 615
Content-Type: text/html
```

Kedua web server dapat diakses dengan normal.

---

# 4. Benchmark [www.k45.com](http://www.k45.com)

Perintah:

```bash
ab -n 250 -c 10 http://www.k45.com/
```

Hasil utama:

```text
Concurrency Level:       10
Time taken for tests:   0.094 seconds
Complete requests:      250
Failed requests:        0
Requests per second:    2672.48 [#/sec] (mean)
Time per request:       3.742 [ms] (mean)
Transfer rate:          28648.28 [Kbytes/sec] received
```

Detail koneksi:

```text
Connect:       1 ms
Processing:    2 ms
Waiting:       2 ms
Total:         4 ms
```

Request paling lama:

```text
100%    6 ms
```

---

# 5. Benchmark static.k45.com

Perintah:

```bash
ab -n 250 -c 10 http://static.k45.com/
```

Hasil utama:

```text
Concurrency Level:       10
Time taken for tests:   0.051 seconds
Complete requests:      250
Failed requests:        0
Requests per second:    4899.75 [#/sec] (mean)
Time per request:       2.041 [ms] (mean)
Transfer rate:          4024.11 [Kbytes/sec] received
```

Detail koneksi:

```text
Connect:       1 ms
Processing:    1 ms
Waiting:       1 ms
Total:         2 ms
```

Request paling lama:

```text
100%    4 ms
```

---

# 6. Ringkasan Hasil

| Parameter         | [www.k45.com](http://www.k45.com) | static.k45.com |
| ----------------- | --------------------------------: | -------------: |
| Server            |                            Apache |          Nginx |
| Total Request     |                               250 |            250 |
| Concurrency       |                                10 |             10 |
| Complete Requests |                               250 |            250 |
| Failed Requests   |                                 0 |              0 |
| Time Taken        |                           0.094 s |        0.051 s |
| Requests/sec      |                           2672.48 |        4899.75 |
| Time/request      |                          3.742 ms |       2.041 ms |
| Transfer Rate     |                     28648.28 KB/s |   4024.11 KB/s |
| Max Request Time  |                              6 ms |           4 ms |

## Kesimpulan

Pengujian ApacheBench berhasil dilakukan terhadap `www.k45.com` dan `static.k45.com` dengan `250` request dan concurrency `10`.

Kedua target berhasil menyelesaikan seluruh request tanpa kegagalan:

```text
www.k45.com     → 250 complete, 0 failed
static.k45.com  → 250 complete, 0 failed
```

Hasil pengujian juga menunjukkan bahwa kedua server dapat melayani request HTTP dengan baik pada konfigurasi pengujian tersebut.

# No. 17 — TXT Record DNS

## Tujuan

Menambahkan TXT record pada DNS untuk seluruh klien sayap kiri dan sayap kanan, yaitu:

* Alpha
* Beta
* Gamma
* Delta
* Epsilon

Ketika DNS melakukan query TXT terhadap domain masing-masing, DNS harus mengembalikan teks berupa nama hostname tersebut.

Contoh:

```text
alpha.k45.com → "alpha"
```

DNS Master berada pada **Prab (`10.86.5.2`)**, sedangkan **Tedd (`10.86.5.3`)** berperan sebagai DNS Slave.

---

## 1. Mengecek A Record yang Sudah Ada

Pada Prab dilakukan pengecekan zone file:

```bash
grep -nE 'alpha|beta|gamma|delta|epsilon|SOA' /etc/bind/db.k45.com
```

Hasil awal:

```text
24:alpha   IN    A    10.86.1.2
25:beta    IN    A    10.86.1.3
26:gamma   IN    A    10.86.1.4
28:delta   IN    A    10.86.2.2
29:epsilon IN    A    10.86.2.3
```

---

## 2. Menambahkan TXT Record

Sebelum melakukan perubahan, dibuat backup zone file:

```bash
cp /etc/bind/db.k45.com /etc/bind/db.k45.com.bak-q17
```

Kemudian ditambahkan TXT record:

```text
alpha    IN    TXT    "alpha"
beta     IN    TXT    "beta"
gamma    IN    TXT    "gamma"
delta    IN    TXT    "delta"
epsilon  IN    TXT    "epsilon"
```

Hasil pengecekan:

```bash
grep -nE 'alpha|beta|gamma|delta|epsilon' /etc/bind/db.k45.com
```

Hasil:

```text
24:alpha   IN    A      10.86.1.2
25:alpha   IN    TXT    "alpha"

26:beta    IN    A      10.86.1.3
27:beta    IN    TXT    "beta"

28:gamma   IN    A      10.86.1.4
29:gamma   IN    TXT    "gamma"

31:delta   IN    A      10.86.2.2
32:delta   IN    TXT    "delta"

33:epsilon IN    A      10.86.2.3
34:epsilon IN    TXT    "epsilon"
```

---

## 3. Validasi Zone

Serial sebelum perubahan:

```text
2026092803
```

Validasi zone dilakukan dengan:

```bash
named-checkzone k45.com /etc/bind/db.k45.com
```

Hasil:

```text
zone k45.com/IN: loaded serial 2026092803
OK
```

---

## 4. Menaikkan Serial SOA

Serial dinaikkan dari:

```text
2026092803
```

menjadi:

```text
2026092804
```

Perintah:

```bash
sed -i 's/2026092803/2026092804/' /etc/bind/db.k45.com
```

Kemudian dilakukan validasi:

```bash
named-checkzone k45.com /etc/bind/db.k45.com
```

Hasil:

```text
zone k45.com/IN: loaded serial 2026092804
OK
```

---

## 5. Reload DNS Master

Perintah `rndc reload k45.com` tidak berhasil karena koneksi `rndc` ditolak.

Sebagai gantinya, proses `named` direstart secara manual:

```bash
pkill named
sleep 2
named
sleep 2
```

Kemudian dicek:

```bash
pgrep -a named
```

Hasil:

```text
804 named
```

Kemudian serial pada Prab diverifikasi:

```bash
dig @10.86.5.2 k45.com SOA +short
```

Hasil:

```text
prab.k45.com. admin.k45.com. 2026092804 3600 1800 604800 86400
```

Artinya DNS Master Prab sudah menggunakan serial terbaru.

---

## 6. Verifikasi Sinkronisasi Tedd

Pada Tedd dilakukan:

```bash
dig @10.86.5.3 k45.com SOA +short
```

Hasil:

```text
prab.k45.com. admin.k45.com. 2026092804 3600 1800 604800 86400
```

Serial Prab dan Tedd sama-sama:

```text
2026092804
```

Artinya perubahan zone berhasil disinkronkan dari DNS Master Prab ke DNS Slave Tedd.

---

## 7. Verifikasi TXT Record

Dilakukan pengecekan TXT record dari DNS Master Prab dan DNS Slave Tedd:

```bash
for host in alpha beta gamma delta epsilon; do
    echo "=== $host.k45.com ==="
    echo "PRAB:"
    dig @10.86.5.2 "$host.k45.com" TXT +short
    echo "TEDD:"
    dig @10.86.5.3 "$host.k45.com" TXT +short
    echo
done
```

Hasil:

```text
=== alpha.k45.com ===
PRAB:
"alpha"
TEDD:
"alpha"

=== beta.k45.com ===
PRAB:
"beta"
TEDD:
"beta"

=== gamma.k45.com ===
PRAB:
"gamma"
TEDD:
"gamma"

=== delta.k45.com ===
PRAB:
"delta"
TEDD:
"delta"

=== epsilon.k45.com ===
PRAB:
"epsilon"
TEDD:
"epsilon"
```

---

## Kesimpulan

TXT record untuk seluruh klien Alpha, Beta, Gamma, Delta, dan Epsilon berhasil ditambahkan pada DNS.

Hasil query menunjukkan:

```text
alpha.k45.com   → "alpha"
beta.k45.com    → "beta"
gamma.k45.com   → "gamma"
delta.k45.com   → "delta"
epsilon.k45.com → "epsilon"
```

Selain itu, serial SOA berhasil dinaikkan dari `2026092803` menjadi `2026092804` dan perubahan berhasil disinkronkan dari Prab ke Tedd.

