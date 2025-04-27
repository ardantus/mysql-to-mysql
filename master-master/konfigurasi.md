Syarat Join cluster tidak boleh ada insert atau update meskipun  nambah atau ubah user sekalipun.

Cek status di semua node
SHOW VARIABLES WHERE Variable_name IN (
  'gtid_mode',
  'enforce_gtid_consistency',
  'log_bin',
  'server_id',
  'transaction_write_set_extraction'
);


Buat user replikasi di semua node
CREATE USER 'repl'@'%' IDENTIFIED BY 'RgVEK6sWQ02!tcjQHOLf';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;


Bootstrap Cluster di node1 saja
INSTALL PLUGIN group_replication SONAME 'group_replication.so';

SET GLOBAL group_replication_bootstrap_group = ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group = OFF;

cek 
SELECT * FROM performance_schema.replication_group_members\G

Perintah ini di jalankan di node2 dan node3 saja
INSTALL PLUGIN group_replication SONAME 'group_replication.so';

START GROUP_REPLICATION;

Kembali ke node1 dan jalankan
SELECT * FROM performance_schema.replication_group_members\G


Jika semua password root node harus sama
ALTER USER 'root'@'localhost' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
FLUSH PRIVILEGES;

ALTER USER 'root'@'%' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
FLUSH PRIVILEGES;

ganti juga di /root/.my.cnf
[client]
user="root"
password="PasswordBaruSama123!"


CREATE USER 'root'@'%' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

SELECT user, host FROM mysql.user WHERE user = 'root';

Jika terlanjur Ubah2 user sehingga di anggap insert dan update maka perlu perintah ini di node2 dan node3
RESET MASTER;
START GROUP_REPLICATION;



----
Dilakukan di master
CREATE USER 'repl'@'%' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';

CREATE USER 'repl'@'10.10.10.%' IDENTIFIED BY 'replpassword';


STOP GROUP_REPLICATION;
SET GLOBAL super_read_only = OFF;
SET GLOBAL read_only = OFF;
DROP USER IF EXISTS 'repl'@'%';



dilakukan di slave
SET GLOBAL super_read_only=OFF;
CHANGE REPLICATION SOURCE TO
  SOURCE_USER='repl',
  SOURCE_PASSWORD='BhX03Jkrrk0!Su41loBa'
  FOR CHANNEL 'group_replication_recovery';
START GROUP_REPLICATION;

SET GLOBAL read_only = ON;
SET GLOBAL super_read_only = ON;


STOP GROUP_REPLICATION;
RESET PERSIST group_replication_recovery_complete;
RESET MASTER;
RESET SLAVE ALL;
SET GLOBAL super_read_only=OFF;
CHANGE REPLICATION SOURCE TO
  SOURCE_USER='repl',
  SOURCE_PASSWORD='BhX03Jkrrk0!Su41loBa'
  FOR CHANNEL 'group_replication_recovery';
START GROUP_REPLICATION;

SET GLOBAL read_only = ON;
SET GLOBAL super_read_only = ON;




10.10.10.20	db-1
10.10.10.94	db-2
10.10.10.36 db-3

Dibuat di primary
CREATE USER 'repl'@'10.10.10.94' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'10.10.10.94';

CREATE USER 'repl'@'10.10.10.36' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'10.10.10.36';






Konfigurasi Innodb Cluster otomatis fileover

Jalankan di node1 primary
sudo apt update
sudo apt install mysql-shell

mysqlsh --version
mysqlsh --uri clusteradmin@localhost:3306
dba.checkInstanceConfiguration()
var cluster = dba.createCluster("mycluster")
cluster.status()
dba.configureInstance('clusteradmin@10.10.10.20:3306')
dba.configureInstance('clusteradmin@10.10.10.94:3306')
dba.configureInstance('clusteradmin@10.10.10.36:3306')


SELECT * FROM performance_schema.replication_group_members;


CREATE USER 'clusteradmin'@'%' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT ALL PRIVILEGES ON *.* TO 'clusteradmin'@'%';

GRANT REPLICATION SLAVE, CLONE_ADMIN, BACKUP_ADMIN, GROUP_REPLICATION_ADMIN, CREATE USER, SELECT ON *.* TO 'clusteradmin'@'%';
FLUSH PRIVILEGES;


CREATE USER 'clusteradmin'@'localhost' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT ALL PRIVILEGES ON *.* TO 'clusteradmin'@'localhost';
FLUSH PRIVILEGES;

CREATE USER 'clusteradmin'@'10.10.10.20' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT ALL PRIVILEGES ON *.* TO 'clusteradmin'@'10.10.10.20';
FLUSH PRIVILEGES;

CREATE USER 'clusteradmin'@'10.10.10.94' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT ALL PRIVILEGES ON *.* TO 'clusteradmin'@'10.10.10.94';
FLUSH PRIVILEGES;

CREATE USER 'clusteradmin'@'10.10.10.36' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT ALL PRIVILEGES ON *.* TO 'clusteradmin'@'10.10.10.36';
FLUSH PRIVILEGES;

CREATE USER 'clusteradmin'@'10.10.10.244' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT ALL PRIVILEGES ON *.* TO 'clusteradmin'@'10.10.10.244';
FLUSH PRIVILEGES;

CREATE USER 'clusteradmin'@'host-10-10-10-244.openstacklocal' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT ALL PRIVILEGES ON *.* TO 'clusteradmin'@'host-10-10-10-244.openstacklocal' WITH GRANT OPTION;
FLUSH PRIVILEGES;


GRANT CLONE_ADMIN, CONNECTION_ADMIN, CREATE USER, EXECUTE, FILE, GROUP_REPLICATION_ADMIN,
PERSIST_RO_VARIABLES_ADMIN, PROCESS, RELOAD, REPLICATION CLIENT, REPLICATION SLAVE,
REPLICATION_APPLIER, REPLICATION_SLAVE_ADMIN, ROLE_ADMIN, SELECT, SHUTDOWN,
SYSTEM_VARIABLES_ADMIN ON *.* TO 'clusteradmin'@'localhost' WITH GRANT OPTION;

GRANT DELETE, INSERT, UPDATE ON mysql.* TO 'clusteradmin'@'localhost' WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON mysql_innodb_cluster_metadata.* TO 'clusteradmin'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON mysql_innodb_cluster_metadata_bkp.* TO 'clusteradmin'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON mysql_innodb_cluster_metadata_previous.* TO 'clusteradmin'@'localhost' WITH GRANT OPTION;

FLUSH PRIVILEGES;



CREATE USER 'clusteradmin'@'10.10.10.20' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';

GRANT CLONE_ADMIN, CONNECTION_ADMIN, CREATE USER, EXECUTE, FILE, GROUP_REPLICATION_ADMIN,
PERSIST_RO_VARIABLES_ADMIN, PROCESS, RELOAD, REPLICATION CLIENT, REPLICATION SLAVE,
REPLICATION_APPLIER, REPLICATION_SLAVE_ADMIN, ROLE_ADMIN, SELECT, SHUTDOWN,
SYSTEM_VARIABLES_ADMIN ON *.* TO 'clusteradmin'@'10.10.10.20' WITH GRANT OPTION;

GRANT DELETE, INSERT, UPDATE ON mysql.* TO 'clusteradmin'@'10.10.10.20' WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON mysql_innodb_cluster_metadata.* TO 'clusteradmin'@'10.10.10.20' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON mysql_innodb_cluster_metadata_bkp.* TO 'clusteradmin'@'10.10.10.20' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON mysql_innodb_cluster_metadata_previous.* TO 'clusteradmin'@'10.10.10.20' WITH GRANT OPTION;

FLUSH PRIVILEGES;


Seting di mysqlrouter
mysqlrouter --bootstrap clusteradmin@10.10.10.20:3306 \
  --user=mysqlrouter \
  --directory /etc/mysqlrouter \
  --force


mysqlrouter --bootstrap clusteradmin@10.10.10.20:3306 \
  --user=mysqlrouter \
  --directory /tmp/router-bootstrap \
  --force



root@db-router:/home/ubuntu# sudo -u mysqlrouter -H bash
mysqlrouter@db-router:/home/ubuntu$ mkdir -p ~/bootstrap
mysqlrouter@db-router:/home/ubuntu$ cd  ~/bootstrap
mysqlrouter@db-router:~/bootstrap$ chown mysqlrouter:mysqlrouter  ~/bootstrap
mysqlrouter@db-router:~/bootstrap$ mysqlrouter --bootstrap clusteradmin@10.10.10.20:3306 \
  --user=mysqlrouter \
  --directory ~/bootstrap \
  --force
Please enter MySQL password for clusteradmin:
# Bootstrapping MySQL Router 8.0.42 (MySQL Community - GPL) instance at '/var/lib/mysqlrouter/bootstrap'...

- Creating account(s) (only those that are needed, if any)
FATAL ERROR ENCOUNTERED, attempting to undo new accounts that were created
- New accounts cleaned up successfully
Error: Error creating MySQL account for router (GRANTs stage): Error executing MySQL query "GRANT SELECT, EXECUTE ON mysql_innodb_cluster_metadata.* TO 'mysql_router1_w6bhz0a'@'%'": Access denied for user 'clusteradmin'@'10.10.10.244' to database 'mysql_innodb_cluster_metadata' (1044)
mysqlrouter@db-router:~/bootstrap$

GRANT SELECT, EXECUTE ON mysql_innodb_cluster_metadata.* TO 'clusteradmin'@'10.10.10.244';
GRANT CREATE USER, GRANT OPTION ON *.* TO 'clusteradmin'@'10.10.10.244';
FLUSH PRIVILEGES;


mysqlrouter --bootstrap clusteradmin@10.10.10.20:3306 \
  --user=mysqlrouter \
  --directory ~/bootstrap \
  --force



mysqlrouter@db-router:~/bootstrap$ mysqlrouter --bootstrap clusteradmin@10.10.10.20:3306 \
  --user=mysqlrouter \
  --directory ~/bootstrap \
  --force
Please enter MySQL password for clusteradmin:
# Bootstrapping MySQL Router 8.0.42 (MySQL Community - GPL) instance at '/var/lib/mysqlrouter/bootstrap'...

- Creating account(s) (only those that are needed, if any)
Failed changing the authentication plugin for account 'mysql_router1_l51bidb'@'%':  mysql_native_password which is deprecated is the default authentication plugin on this server.
- Verifying account (using it to run SQL queries that would be run by Router)
- Storing account in keyring
- Adjusting permissions of generated files
- Creating configuration /var/lib/mysqlrouter/bootstrap/mysqlrouter.conf

# MySQL Router configured for the InnoDB Cluster 'mycluster'

After this MySQL Router has been started with the generated configuration

    $ mysqlrouter -c /var/lib/mysqlrouter/bootstrap/mysqlrouter.conf

InnoDB Cluster 'mycluster' can be reached by connecting to:

## MySQL Classic protocol

- Read/Write Connections: localhost:6446
- Read/Only Connections:  localhost:6447

## MySQL X protocol

- Read/Write Connections: localhost:6448
- Read/Only Connections:  localhost:6449

mysqlrouter@db-router:~/bootstrap$


cp /etc/mysqlrouter/mysqlrouter.conf /etc/mysqlrouter/mysqlrouter.conf.bak
cp -a /var/lib/mysqlrouter/bootstrap/* /etc/mysqlrouter/
chown -R mysqlrouter:mysqlrouter /etc/mysqlrouter/
systemctl restart mysqlrouter


dibuat di node1 atau di primary
CREATE USER 'appuser'@'%' IDENTIFIED BY 'AppPass123';
GRANT ALL PRIVILEGES ON myappdb.* TO 'appuser'@'%';


Dibuat di node1
CREATE DATABASE wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'wp'@'%' IDENTIFIED BY 'WpAppPass123';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp'@'%';
CREATE USER 'wp'@'127.0.0.1' IDENTIFIED BY 'WpAppPass123';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp'@'127.0.0.1';
FLUSH PRIVILEGES;


Test Database dari mysql router
mysql -u wp -p -h 127.0.0.1 -P 6446 wordpress



mysql -u wp -p -h 127.0.0.1 -P 6446  # should go to PRIMARY
mysql -u wp -p -h 127.0.0.1 -P 6447  # should go to SECONDARY (round robin)



### Troubleshot cluster ###
mysqlsh --uri clusteradmin@localhost:3306 --js
var cluster = dba.getCluster()
cluster.status()





DROP USER IF EXISTS 'repl'@'10.10.10.20';
DROP USER IF EXISTS 'repl'@'host-10-10-10-20.openstacklocal';

CREATE USER 'repl'@'10.10.10.20' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
CREATE USER 'repl'@'host-10-10-10-20.openstacklocal' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';

GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'repl'@'10.10.10.20';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'repl'@'host-10-10-10-20.openstacklocal';

FLUSH PRIVILEGES;
CREATE USER 'repl'@'10.10.10.20' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'repl'@'10.10.10.20';



SET GLOBAL super_read_only = OFF;

DROP USER IF EXISTS 'repl'@'%';
CREATE USER 'repl'@'%' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;



### recovery ###
var cluster = dba.getCluster('mycluster');

// Langkah 1: Hapus dulu
cluster.removeInstance("admincluster@10.10.10.20:3306", { force: true });

// Langkah 2: Tambahkan kembali dengan metode clone
cluster.addInstance(
  "admincluster@10.10.10.20:3306",
  {
    recoveryMethod: "clone",
    password: "BhX03Jkrrk0!Su41loBa"
  }
);

CREATE USER 'clusteradmin'@'10.10.10.177' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT ALL PRIVILEGES ON *.* TO 'clusteradmin'@'10.10.10.177' WITH GRANT OPTION;
FLUSH PRIVILEGES;

CREATE USER 'clusteradmin'@'10.10.10.126' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT ALL PRIVILEGES ON *.* TO 'clusteradmin'@'10.10.10.126' WITH GRANT OPTION;
FLUSH PRIVILEGES;



CREATE USER 'admincluster'@'10.10.10.177' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT ALL PRIVILEGES ON *.* TO 'admincluster'@'10.10.10.177' WITH GRANT OPTION;
FLUSH PRIVILEGES;

CREATE USER 'admincluster'@'10.10.10.126' IDENTIFIED BY 'BhX03Jkrrk0!Su41loBa';
GRANT ALL PRIVILEGES ON *.* TO 'admincluster'@'10.10.10.126' WITH GRANT OPTION;
FLUSH PRIVILEGES;


mysqlsh --uri clusteradmin@10.10.10.94:3306
dba.configureInstance("clusteradmin@10.10.10.177:3306", { password: "BhX03Jkrrk0!Su41loBa" })
dba.configureInstance("clusteradmin@10.10.10.126:3306", { password: "BhX03Jkrrk0!Su41loBa" })
var cluster = dba.getCluster('mycluster')

cluster.addInstance("clusteradmin@10.10.10.177:3306", {
  recoveryMethod: "clone",
  password: "BhX03Jkrrk0!Su41loBa"
})

cluster.addInstance("clusteradmin@10.10.10.126:3306", {
  recoveryMethod: "clone",
  password: "BhX03Jkrrk0!Su41loBa"
})