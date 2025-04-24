#!/bin/bash
set -e

echo "🟢 Menambahkan repositori MySQL 5.7..."

# Download mysql-apt-config dan pilih MySQL 5.7
wget https://dev.mysql.com/get/mysql-apt-config_0.8.24-1_all.deb

# Preseed untuk memilih MySQL 5.7 saat install
echo "mysql-apt-config mysql-apt-config/select-server select mysql-5.7" | debconf-set-selections

DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.24-1_all.deb

echo "🔄 Update apt source list..."
apt-get update

echo "🛡️ Mengimpor GPG key MySQL..."
curl -fsSL https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 | gpg --dearmor -o /etc/apt/trusted.gpg.d/mysql.gpg

echo "📦 Menginstal MySQL Server versi 5.7..."
DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

echo "🟢 Menghentikan MySQL sejenak untuk konfigurasi..."
systemctl stop mysql

echo "📦 Backup konfigurasi bawaan..."
CONF_PATH="/etc/mysql/mysql.conf.d/mysqld.cnf"
BACKUP_PATH="/etc/mysql/mysql.conf.d/mysqld.cnf.bak.$(date +%Y%m%d%H%M%S)"
cp "$CONF_PATH" "$BACKUP_PATH"

# Optional: salin file konfigurasi jika kamu sudah punya
if [ -f mysqld.conf ]; then
    echo "📝 Mengganti file konfigurasi dengan yang disediakan..."
    cp mysqld.conf "$CONF_PATH"
    chown mysql:mysql "$CONF_PATH"
    chmod 644 "$CONF_PATH"
fi

echo "🧹 Membersihkan datadir untuk fresh initialize..."
rm -rf /var/lib/mysql/*
mkdir -p /var/lib/mysql
chown mysql:mysql /var/lib/mysql
chmod 750 /var/lib/mysql

echo "🚀 Inisialisasi data MySQL 5.7..."
mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql

echo "🟢 Memulai MySQL kembali..."
systemctl start mysql
systemctl enable mysql

# Set password root secara otomatis
NEW_PASS=$(< /dev/urandom tr -dc 'A-Za-z0-9!@#$%&*_' | head -c20)

echo "🔐 Mengatur password root MySQL..."
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$NEW_PASS';
FLUSH PRIVILEGES;
EOF

# Simpan password ke file
echo "$NEW_PASS" > /root/mysql-root-password.txt
chmod 600 /root/mysql-root-password.txt

# Buat file ~/.my.cnf agar bisa login tanpa password
cat > /root/.my.cnf <<EOCNF
[client]
user=root
password=$NEW_PASS
EOCNF

chmod 600 /root/.my.cnf

echo "✅ Instalasi MySQL 5.7.34 selesai!"
echo "🔓 Password root disimpan di /root/mysql-root-password.txt"
echo "💡 Gunakan 'mysql -u root' untuk login langsung"
