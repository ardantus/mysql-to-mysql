# 🛠️ Simulasi Troubleshooting MySQL InnoDB Cluster & Sinkronisasi MySQL Router

## ✅ Simulasi Kasus Troubleshooting

### 🔁 1. **Node Secondary di-restart secara normal**

**Kasus:** Node `10.10.10.20` direstart karena pemeliharaan.

**Efek:**
- Status akan menjadi `RECOVERING` lalu kembali `ONLINE` jika semua konfigurasi benar.
- Group Replication akan menyinkron otomatis jika GTID dan konfigurasi aman.

**Langkah cek:**
```js
cluster.status()
```
**Log penting:**
```bash
tail -f /var/log/mysql/error.log
```

---

### ⚠️ 2. **Node gagal nyala / disk penuh / crash**

**Efek:**
- Status `UNREACHABLE`, `(MISSING)`, atau `OFFLINE`
- Jika lebih dari 2 node gagal dari 5, maka **cluster down** (karena quorum gagal).

**Penanganan:**
- Pastikan node bisa boot.
- Cek log `/var/log/mysql/error.log`
- Jika GTID mismatch atau transaksi error:
    - Jalankan:
    ```sql
    RESET MASTER;
    ```
    - atau: gunakan ulang metode clone
    ```js
    cluster.rejoinInstance("clusteradmin@IP:3306")
    ```

---

## 🔄 Sinkronisasi MySQL Router dengan Node Terbaru

### ⚠️ Masalah:
> Router hanya mendeteksi 3 node padahal cluster sudah 5 node

### ✅ Solusi:

### 1. **Rescan metadata cluster**

Jalankan dari node primary:
```js
cluster.rescan()
```
Ini akan memperbarui metadata yang dibaca oleh MySQL Router.

---

### 2. **Rebootstrap MySQL Router (opsional)**
Jika router belum terkonfigurasi atau ingin menyegarkan routing table:
```bash
mysqlrouter --bootstrap clusteradmin@10.10.10.94:3306 --user=mysqlrouter --directory /etc/mysqlrouter --force
```
> Ganti user/dir sesuai setup kamu.

---

### 3. **Cek konfigurasi runtime MySQL Router**
```bash
cat /etc/mysqlrouter/mysqlrouter.conf
```
Pastikan `routing_strategy=round-robin` dan endpoint sesuai dengan 5 node.

---

### 4. **Restart MySQL Router**
```bash
systemctl restart mysqlrouter
```

---

### 🕵️‍♂️ 5. **Cek Node dan Primary yang Terdeteksi oleh Router**

Gunakan MySQL client untuk mengecek ke mana router mengarah:
```bash
mysql -u root -h 127.0.0.1 -P 6446 -e "select @@hostname, @@read_only;"
```
> Ulangi beberapa kali untuk melihat apakah node berbeda merespons (untuk round-robin).

Untuk mode read-only (biasanya port 6447):
```bash
mysql -u root -h 127.0.0.1 -P 6447 -e "select @@hostname, @@read_only;"
```

Untuk daftar backend yang diketahui router, periksa log `mysqlrouter.log` atau metadata routing:
```bash
cat /var/log/mysqlrouter/mysqlrouter.log
```
Atau jika disimpan via metadata cache:
```bash
ls /var/lib/mysqlrouter/metadata_cache/
```

---

## ✅ Verifikasi Akhir

```bash
mysqlrouter --help
mysql -u root -h 127.0.0.1 -P 6446 -e "select @@hostname;"
```
Lakukan berkali-kali untuk memastikan router melakukan round-robin atau terhubung ke semua node `READ ONLY` jika port 6447.

---
