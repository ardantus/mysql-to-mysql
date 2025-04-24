#!/bin/bash

set -e

echo "🔧 Menambahkan repository resmi MySQL..."
wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb -O /tmp/mysql-apt-config.deb

echo "📦 Mengonfigurasi repository..."
DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/mysql-apt-config.deb

echo "🔄 Update apt..."
apt update

echo "⬇️ Menginstal MySQL Router..."
apt install -y mysql-router

echo "✅ Instalasi MySQL Router selesai."
mysqlrouter --version
