### cek semua user ###

```sql
SELECT user, host FROM mysql.user ORDER BY user, host;
```
### cek semua hak akses ###


```sql
SELECT CONCAT('SHOW GRANTS FOR ''', user, '''@''', host, ''';') AS grant_stmt
FROM mysql.user
ORDER BY user, host;
```

```sql
-- ======================
-- User admincluster
-- ======================

CREATE USER IF NOT EXISTS 'admincluster'@'%' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'admincluster'@'localhost' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'admincluster'@'10.10.10.20' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'admincluster'@'10.10.10.36' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'admincluster'@'10.10.10.94' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'admincluster'@'10.10.10.244' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'admincluster'@'host-10-10-10-20.openstacklocal' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'admincluster'@'host-10-10-10-244.openstacklocal' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'admincluster'@'127.0.0.1' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';

GRANT ALL PRIVILEGES ON *.* TO 'admincluster'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'admincluster'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'admincluster'@'10.10.10.20' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'admincluster'@'10.10.10.36' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'admincluster'@'10.10.10.94' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'admincluster'@'10.10.10.244' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'admincluster'@'host-10-10-10-20.openstacklocal' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'admincluster'@'host-10-10-10-244.openstacklocal' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'admincluster'@'127.0.0.1' WITH GRANT OPTION;

GRANT PROXY ON ''@'' TO 'admincluster'@'%';
GRANT PROXY ON ''@'' TO 'admincluster'@'localhost';

-- ======================
-- User repl
-- ======================

CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'repl'@'localhost' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'repl'@'10.10.10.20' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'repl'@'10.10.10.36' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'repl'@'10.10.10.94' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'repl'@'10.10.10.244' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'repl'@'host-10-10-10-20.openstacklocal' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'repl'@'host-10-10-10-244.openstacklocal' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER IF NOT EXISTS 'repl'@'127.0.0.1' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';

GRANT ALL PRIVILEGES ON *.* TO 'repl'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'repl'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'repl'@'10.10.10.20' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'repl'@'10.10.10.36' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'repl'@'10.10.10.94' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'repl'@'10.10.10.244' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'repl'@'host-10-10-10-20.openstacklocal' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'repl'@'host-10-10-10-244.openstacklocal' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'repl'@'127.0.0.1' WITH GRANT OPTION;

GRANT PROXY ON ''@'' TO 'repl'@'%';
GRANT PROXY ON ''@'' TO 'repl'@'localhost';

-- Finalize
FLUSH PRIVILEGES;
```