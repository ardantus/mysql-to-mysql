---

# 📘 Tutorial: Migrasi Bertahap Tenant ke Database Baru di Server Replica

### 📌 Tujuan:
- Awalnya semua tenant (`1–10`) ada di database `db_system` (replikasi dari server utama).
- Secara bertahap, tenant dipindahkan ke database baru `db_system2` di server replica.
- Tenant yang sudah dipindahkan akan menggunakan `db_system2` (full read-write).
- Replikasi dari master ke replica tetap berjalan untuk tenant lain yang belum dipindah.

---

## 🛠️ 1. **Persiapan Replikasi**

Pastikan server `replica` sudah menerima replikasi penuh dari server `master`:
- Database: `db_system`
- Replikasi berjalan: ✅

Cek dengan:
```sql
SHOW REPLICA STATUS\G
```

---

## 🧱 2. **Buat Salinan Database untuk Migrasi Tenant**

Di server **replica**, buat database baru untuk migrasi:
```bash
mysql -u root -p -e "CREATE DATABASE db_system2;"
```

Lalu salin struktur dan/atau isi dari `db_system`:
```bash
mysqldump -u root -p --no-data db_system | mysql -u root -p db_system2
```

> Salin struktur tabel tanpa data. Nantinya, data tenant akan dipindah per bagian.

---

## 🔁 3. **Migrasi Tenant Secara Bertahap**

Misalnya ingin memigrasi tenant 1 terlebih dahulu:

### Langkah:
1. Salin data milik `tenant_id = 1` dari `db_system` ke `db_system2`
2. Hapus data tenant 1 dari database replikasi (`db_system`) agar tidak terjadi konflik dari binlog
3. Arahkan aplikasi tenant 1 ke database baru

### Contoh SQL Per Tabel:
```sql
INSERT INTO db_system2.users SELECT * FROM db_system.users WHERE tenant_id = 1;
DELETE FROM db_system.users WHERE tenant_id = 1;

INSERT INTO db_system2.invoices SELECT * FROM db_system.invoices WHERE tenant_id = 1;
DELETE FROM db_system.invoices WHERE tenant_id = 1;

-- ulangi untuk semua tabel yang berkaitan
```

> 🔁 Proses ini bisa diotomatisasi dengan script migrasi (di langkah 6).

---

## 🔄 4. **Arahkan Aplikasi Tenant ke Database Baru**

Aplikasi perlu diarahkan agar:
- Tenant 1 → koneksi ke `db_system2`
- Tenant lainnya → tetap koneksi ke `db_system`

### Contoh Routing (pseudocode):
```php
if ($tenant_id == 1) {
    DB::connection('db_system2');
} else {
    DB::connection('db_system');
}
```

---

## ➕ 5. **Migrasi Tenant Lainnya Bertahap**

Ulangi langkah 3 dan 4 untuk tenant 2, 3, dst.  
Bisa migrasikan satu per satu sambil tetap menjaga:

- Aplikasi tetap berjalan
- Replikasi tetap aktif untuk tenant yang belum pindah
- Tidak ada konflik data

---

## ⚙️ 6. **(Opsional) Script Migrasi Tenant**

Buat bash script `migrate_tenant.sh`:

```bash
#!/bin/bash
TENANT_ID=$1
TABLES=("users" "invoices" "orders") # sesuaikan dengan aslinya

for TABLE in "${TABLES[@]}"; do
    echo "Migrating tenant $TENANT_ID on table $TABLE"
    mysql -u root -e "
        INSERT INTO db_system2.${TABLE}
        SELECT * FROM db_system.${TABLE} WHERE tenant_id = ${TENANT_ID};
        
        DELETE FROM db_system.${TABLE} WHERE tenant_id = ${TENANT_ID};
    "
done
```

Jalankan dengan:
```bash
chmod +x migrate_tenant.sh
./migrate_tenant.sh 1
```

---

## ✅ 7. **Setelah Semua Tenant Migrasi**

Jika semua tenant sudah berhasil migrasi ke `db_system2`, bisa:
```sql
STOP REPLICA;
RESET SLAVE ALL;
DROP DATABASE db_system;
```

> Sekarang `db_system2` menjadi database utama aktif yang **tidak tergantung pada replikasi lagi**.

---

## 📌 Catatan Tambahan

| Area | Tips |
|------|------|
| Konsistensi | Pastikan data per tenant valid sebelum dan sesudah migrasi |
| Backup | Backup selalu sebelum migrasi |
| Validasi | Cek jumlah row sebelum dan sesudah migrasi per tenant |
| Konflik | Hapus data tenant dari `db_system` segera setelah dipindah |
| Performance | Lakukan migrasi di luar jam sibuk jika datanya besar |

---
