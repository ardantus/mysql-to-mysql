#!/bin/bash

DOMAIN="lokal.my.id"
ROOT_DIR="/var/www/$DOMAIN"
PHP_VERSION="8.2"

# Update sistem
apt update && apt upgrade -y

# Tambahkan repositori PHP 8.2
add-apt-repository ppa:ondrej/php -y
apt update

# Install PHP dan dependensi
apt install -y php${PHP_VERSION}-fpm php${PHP_VERSION}-mysql php${PHP_VERSION}-xml php${PHP_VERSION}-curl php${PHP_VERSION}-mbstring php${PHP_VERSION}-zip unzip curl gnupg2 ca-certificates lsb-release software-properties-common git

# Tambahkan repositori OpenResty
wget -qO - https://openresty.org/package/pubkey.gpg | apt-key add -
codename=$(lsb_release -sc)
echo "deb http://openresty.org/package/ubuntu $codename main" | tee /etc/apt/sources.list.d/openresty.list
apt update
apt install -y openresty

# Buat direktori root
mkdir -p $ROOT_DIR
chown -R www-data:www-data $ROOT_DIR

# Contoh file index.php
echo "<?php phpinfo(); ?>" > $ROOT_DIR/index.php

# Konfigurasi vhost
cat <<EOF > /etc/openresty/sites-available/$DOMAIN.conf
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    root $ROOT_DIR;
    index index.php index.html;

    access_log /var/log/openresty/$DOMAIN.access.log;
    error_log /var/log/openresty/$DOMAIN.error.log;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Aktifkan vhost
mkdir -p /etc/openresty/sites-enabled
ln -s /etc/openresty/sites-available/$DOMAIN.conf /etc/openresty/sites-enabled/

# Tambahkan include di openresty.conf
if ! grep -q "include sites-enabled/\*.conf;" /usr/local/openresty/nginx/conf/nginx.conf; then
    sed -i '/http {/a \    include sites-enabled/*.conf;' /usr/local/openresty/nginx/conf/nginx.conf
fi

# Install lua-resty-waf
git clone https://github.com/p0pr0ck5/lua-resty-waf.git /opt/lua-resty-waf
cd /opt/lua-resty-waf
make install

# Tambahkan konfigurasi WAF
mkdir -p /etc/openresty/waf/conf.d

cat <<EOF > /etc/openresty/waf/conf.d/default.conf
{
    "waf": {
        "enabled": true,
        "mode": "ACTIVE"
    }
}
EOF

cat <<EOF > /etc/openresty/waf.conf
lua_package_path "/opt/lua-resty-waf/lib/?.lua;;";

init_by_lua_block {
    local config = require("resty.waf").load_config("/etc/openresty/waf/conf.d/default.conf")
    waf = require("resty.waf")(config)
}

access_by_lua_block {
    waf:exec()
}
EOF

# Tambahkan WAF ke vhost
sed -i '/server {/a \    include /etc/openresty/waf.conf;' /etc/openresty/sites-available/$DOMAIN.conf

# Restart layanan
systemctl restart php${PHP_VERSION}-fpm
systemctl restart openresty

echo "✅ Instalasi selesai untuk domain http://$DOMAIN"
