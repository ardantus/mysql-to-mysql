
**Replikasi MySQL tanpa menghentikan database utama**:

---

## ✅ Cara Aman Replikasi MySQL Tanpa Downtime

### 1. **Pastikan binlog aktif di server utama**
Jika belum, edit file `mysqld.cnf` di server utama:

```ini
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_format = ROW
binlog_do_db = db_system
```

Lalu restart MySQL:
```bash
sudo systemctl restart mysql
```

---

### 2. **Buat user khusus replikasi**

```sql
CREATE USER 'replicator'@'%' IDENTIFIED BY 'passwordku';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
FLUSH PRIVILEGES;
```

---

### 3. **Ambil posisi binlog secara konsisten menggunakan `mysqldump`**
Ini bagian penting agar kamu **tidak perlu lock terlalu lama**:

```bash
mysqldump -u root \
  --databases db_system \
  --single-transaction \
  --source-data=2 \
  --triggers --routines --events \
  > db_system.sql
```

Penjelasan:
- `--master-data=2`: Menyisipkan info binlog file & pos di dalam file dump sebagai komentar.
- `--single-transaction`: Dump konsisten tanpa lock.

---

### 4. **Transfer file dump ke server replica**
```bash
scp db_system.sql user@ip-server-replica:/tmp/
```

---

### 5. **Import dump di server replica**
```bash
mysql -u root -p < /tmp/db_system.sql
```

---

### 6. **Ambil info posisi binlog dari dump**
Cek di dalam file dump:
```bash
grep "CHANGE MASTER TO" /tmp/db_system.sql
```

Hasilnya akan seperti ini:
```sql
-- CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000005', MASTER_LOG_POS=1234;
```

---

### 7. **Konfigurasi replikasi di server replica**

Pastikan `mysqld.cnf` sudah ada:
```ini
server-id = 2
relay-log = /var/log/mysql/mysql-relay-bin
log_bin = /var/log/mysql/mysql-bin.log
read_only = 1
```

Restart:
```bash
sudo systemctl restart mysql
```

Kemudian jalankan di MySQL:

```sql
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='ip-server-utama',
  SOURCE_USER='replicator',
  SOURCE_PASSWORD='passwordku',
  SOURCE_LOG_FILE='mysql-bin.000005',
  SOURCE_LOG_POS=1234;

START REPLICA;
```

---

### 8. **Cek Status Replikasi**
```sql
SHOW REPLICA STATUS\G
```

Pastikan:
- `Replica_IO_Running: Yes`
- `Replica_SQL_Running: Yes`

---

## 🔒 Tips Penting
- Pastikan firewall server utama mengizinkan koneksi dari IP replica di port 3306.
- Gunakan `read_only=ON` di replica untuk mencegah tulis langsung.
- Jika perlu, aktifkan SSL replikasi untuk keamanan data antar server.

