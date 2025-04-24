#!/bin/bash
set -e

echo "🧩 Deteksi versi MySQL saat ini..."
mysql_version=$(mysql -V)
echo "📌 Versi saat ini: $mysql_version"

if [[ "$mysql_version" != *"5.7."* ]]; then
    echo "❌ Versi MySQL bukan 5.7.x — proses dibatalkan."
    exit 1
fi

echo "🧰 Membackup seluruh data MySQL..."
backup_file="/root/mysql57-backup-$(date +%Y%m%d%H%M%S).sql"
mysqldump --all-databases --single-transaction --quick --lock-tables=false > "$backup_file"
echo "✅ Backup disimpan di: $backup_file"

echo "🔄 Mengubah repo APT ke MySQL 8.0..."
wget https://dev.mysql.com/get/mysql-apt-config_0.8.24-1_all.deb

# Preseed pemilihan MySQL 8.0
echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.24-1_all.deb

apt-get update

echo "📦 Melakukan upgrade ke MySQL 8.0..."
DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

echo "🚀 Menjalankan mysql_upgrade untuk migrasi skema..."
mysql_upgrade

echo "🔄 Restart MySQL..."
systemctl restart mysql

# Verifikasi upgrade
new_version=$(mysql -V)
echo "✅ Upgrade selesai! Versi baru: $new_version"
echo "Jika ingin restore, gunakan perintah berikut:"
echo "mysql -u root < /root/mysql57-backup-YYYYMMDD.sql"
echo "mysql_upgrade"

