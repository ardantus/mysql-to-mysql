# 🛠️ Troubleshooting MySQL InnoDB Cluster: Node Gagal Join atau Rejoin

Dokumen ini menyusun langkah-langkah troubleshooting dan penyelesaian ketika sebuah node MySQL InnoDB Cluster gagal join, rejoin, atau keluar dari cluster karena masalah seperti transaksi divergen, GTID kosong, atau konfigurasi tidak konsisten.

---

## ✅ Checklist Awal

1. **Pastikan user admin cluster (`clusteradmin`) memiliki hak akses lengkap:**
   ```sql
   GRANT ALL PRIVILEGES ON *.* TO 'clusteradmin'@'%' WITH GRANT OPTION;
   FLUSH PRIVILEGES;
   ```

2. **Pastikan konfigurasi `/etc/mysql/my.cnf` di semua node berisi parameter yang sesuai:**

   ```ini
   [mysqld]
   server_id = <unique_id>
   gtid_mode = ON
   enforce_gtid_consistency = ON
   log_bin = mysql-bin
   binlog_format = ROW
   transaction_write_set_extraction = XXHASH64
   loose-group_replication_group_name = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
   loose-group_replication_start_on_boot = OFF
   loose-group_replication_local_address = "<ip>:33061"
   loose-group_replication_group_seeds = "10.10.10.94:33061,10.10.10.36:33061,10.10.10.20:33061"
   loose-group_replication_bootstrap_group = OFF
   loose-group_replication_single_primary_mode = ON
   loose-group_replication_enforce_update_everywhere_checks = OFF
   ```

3. **Periksa konektivitas antar node:**
   ```bash
   telnet 10.10.10.94 33061
   telnet 10.10.10.36 33061
   telnet 10.10.10.20 33061
   ```

---

## 🚨 Masalah Umum dan Solusinya

### 1. **Error: Transaction cannot be executed while Group Replication is recovering**

**Penyebab:** group replication sedang `RECOVERING`, tapi ada `CREATE USER`, `GRANT`, atau DML yang dijalankan.

**Solusi:** Tunggu status `cluster.status()` menjadi `ONLINE`, atau hentikan GR sementara:
```sql
STOP GROUP_REPLICATION;
SET GLOBAL super_read_only = OFF;
```

---

### 2. **Error: The member has more executed transactions than those present in the group**

**Penyebab:** Node memiliki transaksi lokal yang tidak dikenali oleh cluster.

**Solusi:**
```sql
STOP GROUP_REPLICATION;
RESET MASTER;
```
Kemudian dari `mysqlsh`:
```js
cluster.removeInstance("clusteradmin@10.10.10.20:3306", { force: true });
cluster.addInstance("clusteradmin@10.10.10.20:3306", {
  recoveryMethod: "clone",
  password: "<password>"
});
```

---

### 3. **Error: The instance has an empty GTID set**

**Penyebab:** Node baru saja di-`RESET MASTER` dan tidak bisa di-*rejoin* karena tidak punya jejak transaksi sebelumnya.

**Solusi:** Sama seperti poin di atas — gunakan `removeInstance()` lalu `addInstance()` dengan metode `clone`.

---

## 📋 Langkah Pemulihan Node dari Awal (Jika Sudah Kacau):

1. Masuk ke node yang bermasalah:
   ```bash
   mysql -u root
   STOP GROUP_REPLICATION;
   RESET MASTER;
   SET GLOBAL super_read_only = OFF;
   SET GLOBAL read_only = OFF;
   ```

2. Dari node primary, hapus node lama:
   ```js
   var cluster = dba.getCluster('mycluster');
   cluster.removeInstance("clusteradmin@10.10.10.20:3306", { force: true });
   ```

3. Tambahkan ulang dengan metode clone:
   ```js
   cluster.addInstance("clusteradmin@10.10.10.20:3306", {
     recoveryMethod: "clone",
     password: "<password>"
   });
   ```

---

## 🧹 Cleanup: Hapus user yang tidak diperlukan

Jika ada dua user mirip seperti `admincluster` dan `clusteradmin`, konsolidasikan ke satu:

```sql
DROP USER 'admincluster'@'%';
DROP USER 'admincluster'@'localhost';
-- dst sesuai yang terdaftar
```

---

## 📌 Catatan Tambahan

- Gunakan `clusteradmin` sebagai default user untuk manajemen cluster.
- Jangan membuat/menghapus user di node `SECONDARY` atau dalam status `RECOVERING`.
- Untuk operasi sensitif seperti ini, selalu lakukan dari node `PRIMARY`.
- Gunakan `mysqlsh` untuk semua manajemen cluster, bukan SQL CLI biasa.

---

## 🚀 Panduan Menambah 2 Node Baru ke Cluster Existing

Misal node cluster utama adalah `10.10.10.94`, dan 2 node baru adalah `10.10.10.101` dan `10.10.10.102`.

### 1. **Pastikan semua node sudah install MySQL 8.0 dan bisa saling terhubung (port 3306 & 33061)**

### 2. **Konfigurasi MySQL di `my.cnf` masing-masing node baru:**

```ini
[mysqld]
server_id = 101 # untuk node 10.10.10.101 (ganti 102 untuk node lainnya)
gtid_mode = ON
enforce_gtid_consistency = ON
log_bin = mysql-bin
binlog_format = ROW
transaction_write_set_extraction = XXHASH64
loose-group_replication_group_name = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
loose-group_replication_start_on_boot = OFF
loose-group_replication_local_address = "10.10.10.101:33061"
loose-group_replication_group_seeds = "10.10.10.94:33061,10.10.10.36:33061,10.10.10.101:33061,10.10.10.102:33061"
loose-group_replication_bootstrap_group = OFF
loose-group_replication_single_primary_mode = ON
loose-group_replication_enforce_update_everywhere_checks = OFF
```

### 3. **Buat user `clusteradmin` di node baru**

```sql
CREATE USER 'clusteradmin'@'%' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT ALL PRIVILEGES ON *.* TO 'clusteradmin'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

### 4. **Dari PRIMARY (`10.10.10.94`), tambahkan node dengan metode clone**

```js
var cluster = dba.getCluster('mycluster');

cluster.addInstance("clusteradmin@10.10.10.101:3306", {
  recoveryMethod: "clone",
  password: "BhX03Jkrrk0!Su41loBa"
});

cluster.addInstance("clusteradmin@10.10.10.102:3306", {
  recoveryMethod: "clone",
  password: "BhX03Jkrrk0!Su41loBa"
});
```

### 5. **Verifikasi dengan:**
```js
cluster.status()
```

---

Disusun oleh: saya
Tanggal: 2025-04-25

