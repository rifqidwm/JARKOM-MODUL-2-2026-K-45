# Cara Pakai Script 1-10

Script di folder ini menjalankan seluruh konfigurasi soal 1 sampai 10. Semua script **aman dijalankan berulang kali**.

## Dua cara pemakaian

**Cara 1, per node (paling cepat).** Satu node satu script, langsung mencakup soal 1 sampai 10 untuk node tersebut. Ada di folder `node/`.

**Cara 2, per soal.** Satu script untuk satu nomor soal, dijalankan di tiap node. Script mendeteksi hostname sendiri lalu menjalankan bagian yang sesuai. Ada di folder utama.

---

## Urutan menjalankan (wajib berurutan)

1. **rootkit** lebih dulu, karena node lain butuh jalur keluar untuk mengunduh paket
2. **prab**, lalu **tedd**
3. Node client: alpha, beta, gamma, delta, epsilon, abbey, penny
4. Node web: obladi, desmond, oblada, molly

---

## Menjalankan di node (console GNS3)

Node GNS3 tidak punya akses ke berkas di komputer, sehingga isi script **disalin lalu ditempel** ke console node. Buka berkas `.sh` yang diinginkan di teks editor, salin seluruh isinya, lalu tempel di console node.

Bila node punya akses internet dan script sudah diunggah ke repository GitHub, script dapat diambil langsung:

```sh
apt install wget -y
wget -O setup.sh https://raw.githubusercontent.com/<user>/<repo>/main/scripts/node/alpha.sh
bash setup.sh
```

---

## Daftar script per node

| Berkas               | Node    | Isi                                               |
| -------------------- | ------- | ------------------------------------------------- |
| `node/rootkit.sh`    | rootkit | IP 6 antarmuka, forwarding, NAT                   |
| `node/prab.sh`       | prab    | IP, bind9 master, zona forward, 3 reverse zone    |
| `node/tedd.sh`       | tedd    | IP, bind9 slave seluruh zona                      |
| `node/alpha.sh`      | alpha   | IP, hostname, resolver                            |
| `node/beta.sh`       | beta    | IP, hostname, resolver                            |
| `node/gamma.sh`      | gamma   | IP, hostname, resolver                            |
| `node/delta.sh`      | delta   | IP, hostname, resolver                            |
| `node/epsilon.sh`    | epsilon | IP, hostname, resolver                            |
| `node/abbey.sh`      | abbey   | IP, hostname, resolver                            |
| `node/penny.sh`      | penny   | IP, hostname, resolver                            |
| `node/obladi.sh`     | obladi  | IP, hostname, resolver, Apache autoindex          |
| `node/desmond.sh`    | desmond | IP, hostname, resolver, Apache autoindex          |
| `node/oblada.sh`     | oblada  | IP, hostname, resolver, nginx PHP-FPM, URL bersih |
| `node/molly.sh`      | molly   | IP, hostname, resolver, nginx PHP-FPM, URL bersih |

## Daftar script per soal

| Berkas                          | Dijalankan di                  | Isi                                      |
| ------------------------------- | ------------------------------ | ---------------------------------------- |
| `soal01-ip-gateway.sh`          | semua node                     | IP dan default gateway                   |
| `soal02-nat.sh`                 | rootkit                        | Antarmuka WAN, forwarding, MASQUERADE    |
| `soal03-routing-resolver.sh`    | semua node                     | Resolver awal, uji lintas segmen         |
| `soal04-dns-master-slave.sh`    | prab, tedd, lalu node lain     | bind9 master dan slave, urutan resolver  |
| `soal05-hostname-domain.sh`     | semua node                     | Hostname, A record seluruh node          |
| `soal06-zone-transfer.sh`       | tedd (dan node lain untuk uji) | Perbandingan Serial, AXFR                |
| `soal07-vault-core-cname.sh`    | prab, lalu dua klien           | A record vault dan core, CNAME           |
| `soal08-reverse-zone.sh`        | prab, tedd, lalu node lain     | Tiga reverse zone dan PTR                |
| `soal09-web-statis.sh`          | obladi, desmond, lalu klien    | Apache dan autoindex                     |
| `soal10-web-dinamis.sh`         | oblada, molly, lalu klien      | nginx, PHP-FPM, URL bersih               |
| `verifikasi.sh`                 | node client                    | Uji menyeluruh soal 1 sampai 10          |

**Catatan `soal05`:** bila hostname node belum sesuai, nama node diberikan sebagai argumen.

```sh
bash soal05-hostname-domain.sh alpha
```

---

## Verifikasi

Setelah seluruh node dikonfigurasi, jalankan dari node client mana pun:

```sh
bash verifikasi.sh
```

Script tersebut memeriksa konektivitas, resolusi nama, konsistensi kedua name server, pencarian balik, serta kedua layanan web.

---

## Hal yang perlu diperhatikan

**Urutan rootkit lebih dulu.** Pemasangan paket pada node lain memerlukan jalur keluar yang disediakan rootkit.

**prab sebelum tedd.** tedd menarik zona dari prab, sehingga prab harus sudah melayani lebih dulu. Bila tedd dijalankan duluan, cukup jalankan ulang `service named restart` pada tedd setelah prab aktif.

**Nilai Serial.** Berkas zona pada `node/prab.sh` memakai Serial `2026092803`, yaitu versi final yang sudah memuat seluruh A record node, endpoint vault dan core, serta CNAME.

**PHP-FPM.** Script `node/oblada.sh`, `node/molly.sh`, dan `soal10-web-dinamis.sh` menjalankan php-fpm lebih dulu agar berkas socket terbentuk, baru menulis konfigurasi nginx yang menunjuk ke socket tersebut.

