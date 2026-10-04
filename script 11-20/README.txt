K45 JARKOM MODUL 2 - SCRIPT NO.11-20 (REVISI)

Cara pakai: copy file ke node yang sesuai, jalankan sebagai root:  bash noXX.sh
Script otomatis cek IP node, jadi kalau salah node akan ditolak.

NO   NODE                                   CATATAN
11   Penny (10.86.4.2) & Abbey (10.86.3.2)  Jalankan PERTAMA. Penny = Apache, Abbey = Nginx.
12   Penny                                  Diminta bikin password prabs (diketik sendiri).
13   Penny & Abbey                          Penny 301 -> www.k45.com, Abbey 302 -> static.k45.com.
14   Obladi, Desmond, Oblada, Molly         Jalankan di keempatnya (otomatis Apache/Nginx).
15   Penny & Abbey                          Penny /eternal (PHP-FPM), Abbey /orion (statis).
16   Alpha                                  ApacheBench, 250 request, c=10.
17   Prab                                   Tedd ikut otomatis (zone transfer).
18   Prab + Alpha                           Pakai argumen, lihat urutan di bawah.
19   Prab (konfigurasi) + Alpha (uji)       Tanpa argumen, otomatis sesuai node.
20   Rootkit                                `bash no20.sh` lalu reboot, `bash no20.sh cek`.

URUTAN
  Penny : 11 -> 12 -> 13 -> 15
  Abbey : 11 -> 13 -> 15
  Vault/Core : 14
  Alpha : 16
  Prab  : 17 -> 19
  No.18 : Alpha `setup` -> Prab `ubah` -> Alpha `amati` -> Prab `restore` -> Alpha `hapus`
  Rootkit : 20

PERUBAHAN DARI VERSI LAMA
  11  Penny: 000-default dimatikan; /admin & /eternal dipindah ke k45-penny.d (di-include di dalam vhost).
      Abbey: tambah default_server; /orion di-include di server block yang sama.
  12  Require user prabs (bukan valid-user); cek user pakai grep (htpasswd -v dulu minta password).
  13  Redirect Penny sekarang ada di dalam vhost, sebelumnya tidak berlaku.
  14  Apache: access.log pakai format realip (sesuai README). Nginx: access_log realip di server block.
  15  Abbey: /orion tidak lagi server block terpisah (bikin "/" berhenti diproxy).
  16  apt update dibolehkan gagal (error signature debian-security).
  17  Serial SOA dinaikkan; TXT ditaruh di bawah A record.
  18  Restore menaikkan serial (bukan cp backup) supaya Tedd ikut kembali.
      Ditambah mode Alpha: setup/amati/hapus (caching resolver sementara).
  19  Ditambah uji dari Alpha (dig + curl). 503 Web Page Blocked = filter jaringan, bukan salah DNS.
  20  Sekarang benar-benar mengkonfigurasi persistence di Rootkit (sysctl, rules.v4, init.d); bukan cuma cek.
