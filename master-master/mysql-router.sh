#!/bin/bash

set -e

echo "🔧 Menambahkan repository resmi MySQL..."
wget -q https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb -O /tmp/mysql-apt-config.deb

echo "📦 Mengonfigurasi repository MySQL..."
DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/mysql-apt-config.deb

echo "🔄 Update daftar paket..."
apt update -y

echo "⬇️ Menginstal MySQL Router..."
apt install -y mysql-router

echo "👤 Membuat user 'mysqlrouter' jika belum ada..."
if ! id mysqlrouter >/dev/null 2>&1; then
    useradd -m -d /home/mysqlrouter -s /bin/bash mysqlrouter
    echo "✅ User mysqlrouter dibuat di /home/mysqlrouter"
else
    echo "ℹ️  User mysqlrouter sudah ada"
fi

echo "📁 Menyiapkan direktori kerja bootstrap di /home/mysqlrouter/bootstrap..."
mkdir -p /home/mysqlrouter/bootstrap
chown -R mysqlrouter:mysqlrouter /home/mysqlrouter/bootstrap

echo "✅ Instalasi dan setup awal MySQL Router selesai."
echo "📌 Versi:"
mysqlrouter --version
