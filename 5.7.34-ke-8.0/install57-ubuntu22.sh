#!/bin/bash
set -e

echo "📦 Mengunduh paket MySQL 5.7 dari Ubuntu 20.04 (focal)..."
mkdir -p /tmp/mysql57
cd /tmp/mysql57

# Unduh dependensi utama MySQL 5.7
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-common_5.7.34-1ubuntu20.04_amd64.deb
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-client_5.7.34-1ubuntu20.04_amd64.deb
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-client_5.7.34-1ubuntu20.04_amd64.deb
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-server_5.7.34-1ubuntu20.04_amd64.deb
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-server_5.7.34-1ubuntu20.04_amd64.deb

echo "🛠️ Menginstal semua paket .deb secara manual..."
dpkg -i *.deb || apt -f install -y

echo "🛡️ Konfigurasi MySQL agar tidak menggunakan password sementara..."
# Buat direktori data baru
rm -rf /var/lib/mysql
mkdir -p /var/lib/mysql
chown mysql:mysql /var/lib/mysql

echo "🔄 Inisialisasi ulang database tanpa password awal (insecure)"
mysqld --initialize-insecure --user=mysql

echo "🚀 Memulai MySQL..."
systemctl restart mysql
systemctl enable mysql

# Generate password baru dan set root password
NEW_PASS=$(< /dev/urandom tr -dc 'A-Za-z0-9@#%^*_' | head -c20)

echo "🔐 Mengatur password root..."
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$NEW_PASS';
FLUSH PRIVILEGES;
EOF

echo "$NEW_PASS" > /root/mysql-root-password.txt
chmod 600 /root/mysql-root-password.txt

cat > /root/.my.cnf <<EOF
[client]
user=root
password=$NEW_PASS
EOF

chmod 600 /root/.my.cnf

echo "✅ MySQL 5.7.34 berhasil diinstall di Ubuntu 22.04!"
echo "🔑 Password root disimpan di /root/mysql-root-password.txt"
