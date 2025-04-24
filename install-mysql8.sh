#!/bin/bash

set -e

echo "🟢 Menambahkan repositori MySQL 8.0..."
wget https://dev.mysql.com/get/mysql-apt-config_0.8.24-1_all.deb
DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.24-1_all.deb <<EOF
1
EOF

echo "🛡️  Menambahkan GPG key MySQL..."
curl -fsSL https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 | gpg --dearmor -o /etc/apt/trusted.gpg.d/mysql.gpg

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B7B3B788A8D3785C
echo "🔄 Menjalankan apt update..."
apt-get update

echo "🟢 Menginstal MySQL Server 8.0..."
DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

echo "🟢 Menghentikan MySQL untuk konfigurasi..."
systemctl stop mysql

echo "📦 Backup konfigurasi lama..."
CONF_PATH="/etc/mysql/mysql.conf.d/mysqld.cnf"
BACKUP_PATH="/etc/mysql/mysql.conf.d/mysqld.cnf.bak.$(date +%Y%m%d%H%M%S)"
cp "$CONF_PATH" "$BACKUP_PATH"

echo "📝 Mengganti konfigurasi dengan yang baru..."
cp mysqld.conf "$CONF_PATH"
chown mysql:mysql "$CONF_PATH"
chmod 644 "$CONF_PATH"

echo "🧹 Membersihkan datadir untuk fresh initialize..."
rm -rf /var/lib/mysql/*
mkdir -p /var/lib/mysql
chown mysql:mysql /var/lib/mysql
chmod 750 /var/lib/mysql

echo "🚀 Inisialisasi MySQL..."
mysqld --initialize --user=mysql --datadir=/var/lib/mysql

echo "🟢 Memulai ulang MySQL..."
systemctl start mysql
systemctl enable mysql

# Ambil password root sementara dari log
TEMP_PASS=$(grep 'temporary password' /var/log/mysql/error.log | tail -1 | awk '{print $NF}')

# Generate password baru 20 karakter acak
NEW_PASS=$(< /dev/urandom tr -dc 'A-Za-z0-9!@#$%&*_' | head -c20)

echo "🔐 Mengganti password root MySQL..."
mysql --connect-expired-password -u root -p"$TEMP_PASS" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$NEW_PASS';
EOF

# Simpan password ke file
echo "$NEW_PASS" > /root/mysql-root-password.txt
chmod 600 /root/mysql-root-password.txt

# Tulis ke ~/.my.cnf agar bisa login tanpa password
cat > /root/.my.cnf <<EOCNF
[client]
user=root
password=$NEW_PASS
EOCNF

chmod 600 /root/.my.cnf

echo "✅ Instalasi dan konfigurasi selesai."
echo "🔓 Password root MySQL disimpan di: /root/mysql-root-password.txt"
echo "💡 Anda sekarang bisa login dengan: mysql -u root"
