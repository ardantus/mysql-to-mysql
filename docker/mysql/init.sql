-- Plugin group replication
INSTALL PLUGIN group_replication SONAME 'group_replication.so';

-- User untuk group replication
CREATE USER 'repl'@'%' IDENTIFIED BY 'replica_pass';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
GRANT BACKUP_ADMIN ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;

-- Buat user untuk MySQL Router
CREATE USER 'router'@'%' IDENTIFIED BY 'router_pass';
GRANT ALL PRIVILEGES ON *.* TO 'router'@'%';
FLUSH PRIVILEGES;
