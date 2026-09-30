K45 JARKOM MODUL 2 - SCRIPT NO.11-20

Cara pakai:
1. Copy folder ini ke node yang sesuai.
2. Jalankan sebagai root: bash noXX.sh
3. Script mendeteksi IP node untuk menentukan konfigurasi yang relevan.
4. No.20 adalah verifikasi persistence/autostart; jalankan di setiap node yang ingin dicek.
5. No.18 hanya melakukan simulasi perubahan DNS + TTL dan mengembalikan state Abbey ke 10.86.3.2 di akhir. Cache-phase penuh tetap membutuhkan resolver/cache pada Alpha.

Pemetaan:
No11 Penny/Abbey
No12 Penny
No13 Penny/Abbey
No14 Obladi/Desmond/Oblada/Molly
No15 Penny/Abbey
No16 Alpha
No17 Prab
No18 Prab (perubahan DNS + restore); Alpha hanya jika ingin menguji cache TTL
No19 Prab
No20 semua node

Catatan:
- Script tidak menyimpan password Basic Auth.
- No.12 memakai /etc/apache2/.htpasswd yang sudah ada. Jika user prabs belum ada, script akan meminta password sekali.
- Script tidak mematikan signature verification APT dan tidak mengubah repository.
