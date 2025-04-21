#!/bin/bash
# cluster-init.sh
# Otomatisasi setup InnoDB Cluster untuk 3 node MySQL dan join dari mysql2 & mysql3

set -e

# Konfigurasi
MYSQL_ROOT_PASS="rootpass"
CLUSTER_NAME="kledo_cluster"

# Fungsi untuk tunggu MySQL ready
wait_for_mysql() {
  CONTAINER=$1
  echo "⌛ Menunggu $CONTAINER siap..."
  until docker exec "$CONTAINER" mysqladmin ping -uroot -p$MYSQL_ROOT_PASS --silent; do
    sleep 2
  done
  echo "✅ $CONTAINER siap."
}

# Step 1: Tunggu semua container ready
wait_for_mysql mysql1
wait_for_mysql mysql2
wait_for_mysql mysql3

# Step 2: Setup mysql1 sebagai PRIMARY
cat <<EOF | docker exec -i mysql1 mysql -uroot -p$MYSQL_ROOT_PASS
INSTALL PLUGIN group_replication SONAME 'group_replication.so';
-- Ignore error if already exists
DO 1;

CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY 'replica_pass';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
CREATE USER IF NOT EXISTS 'router'@'%' IDENTIFIED BY 'router_pass';
GRANT ALL PRIVILEGES ON *.* TO 'router'@'%';
FLUSH PRIVILEGES;
SET GLOBAL group_replication_bootstrap_group=ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;
EOF

echo "🎉 Cluster $CLUSTER_NAME dibootstrap di mysql1"

# Step 3: Join mysql2 & mysql3 ke cluster
for NODE in mysql2 mysql3; do
  echo "🔗 Menyambungkan $NODE ke cluster..."
  cat <<EOF | docker exec -i $NODE mysql -uroot -p$MYSQL_ROOT_PASS
INSTALL PLUGIN group_replication SONAME 'group_replication.so';
CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY 'replica_pass';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
START GROUP_REPLICATION;
EOF

done

# Step 4: Cek status dari mysql1
sleep 2

echo "📋 Status cluster:"
docker exec -i mysql1 mysql -uroot -p$MYSQL_ROOT_PASS -e "SELECT MEMBER_ID, MEMBER_HOST, MEMBER_STATE, MEMBER_ROLE FROM performance_schema.replication_group_members;"

echo "✅ Semua node telah tersambung ke cluster."
echo "🎉 InnoDB Cluster siap digunakan!"