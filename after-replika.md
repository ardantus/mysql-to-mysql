```sql
SET GLOBAL read_only = ON;
SET GLOBAL super_read_only = ON;
```

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

```ini
read_only = ON
super_read_only = ON
```

```bash
systemctl restart mysql
```
