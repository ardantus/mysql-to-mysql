Untuk mengecek apakah **MySQL 8.0**  **sudah menggunakan InnoDB Cluster (Group Replication)**,  bisa menjalankan beberapa perintah SQL dan memeriksa status plugin serta konfigurasi replika. Berikut langkah-langkahnya:

---

### ✅ **1. Cek Plugin Group Replication**
```sql
SHOW PLUGINS;
```
- Cari plugin `group_replication` dan pastikan **`ACTIVE`**.
- Contoh hasil:
  ```
  +--------------------------+----------+--------------------+---------+
  | Name                     | Status   | Type               | Library |
  +--------------------------+----------+--------------------+---------+
  | group_replication        | ACTIVE   | GROUP REPLICATION  | NULL    |
  +--------------------------+----------+--------------------+---------+
  ```

---

### ✅ **2. Cek Status Group Replication**
```sql
SELECT * FROM performance_schema.replication_group_members;
```
- Jika ini mengembalikan data, berarti **server sedang berada dalam cluster**.

Contoh hasil:
```
+------------------+-----------------------------+-------------+-------------+
| CHANNEL_NAME     | MEMBER_ID                   | MEMBER_HOST | MEMBER_ROLE |
+------------------+-----------------------------+-------------+-------------+
| group_replication_applier | abcdefgh123456...  | node1       | PRIMARY     |
| group_replication_applier | abcdefgh654321...  | node2       | SECONDARY   |
+------------------+-----------------------------+-------------+-------------+
```

---

### ✅ **3. Cek Status Group Replication Aktif atau Tidak**
```sql
SHOW STATUS LIKE 'group_replication%';
```
- Pastikan nilai `group_replication_status` adalah `ONLINE`.

---

### ✅ **4. Cek apakah node ini adalah PRIMARY atau SECONDARY**
```sql
SELECT MEMBER_HOST, MEMBER_ROLE FROM performance_schema.replication_group_members;
```
- Untuk tahu siapa master (primary) dan siapa slave (secondary).

---

### ✅ **5. Cek apakah server bagian dari grup**
```sql
SELECT @@group_replication_group_name;
```
- Kalau NULL, berarti server belum join ke cluster.

---

### 🚫 Jika Belum Terpasang
Kalau  belum lihat plugin `group_replication` aktif, bisa  aktifkan dulu dengan:
```sql
INSTALL PLUGIN group_replication SONAME 'group_replication.so';
```

---
