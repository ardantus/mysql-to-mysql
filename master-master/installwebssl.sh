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

# Tambahkan certbot
apt install -y certbot

# Buat direktori root
mkdir -p $ROOT_DIR
chown -R www-data:www-data $ROOT_DIR

# Contoh file index.php
echo "<?php phpinfo(); ?>" > $ROOT_DIR/index.php

# Buat direktori log jika belum
mkdir -p /var/log/openresty

# Konfigurasi HTTP vhost sementara (untuk certbot)
cat <<EOF > /etc/openresty/sites-available/$DOMAIN.conf
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    root $ROOT_DIR;
    index index.php index.html;

    location /.well-known/acme-challenge/ {
        root /var/www/;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}
EOF

# Aktifkan vhost
mkdir -p /etc/openresty/sites-enabled
ln -sf /etc/openresty/sites-available/$DOMAIN.conf /etc/openresty/sites-enabled/

# Tambahkan include ke nginx.conf jika belum
NGINX_CONF="/usr/local/openresty/nginx/conf/nginx.conf"
if ! grep -q "include sites-enabled/\*.conf;" $NGINX_CONF; then
    sed -i '/http {/a \    include sites-enabled/*.conf;' $NGINX_CONF
fi

# Restart openresty sementara
systemctl restart openresty

# Dapatkan sertifikat SSL
certbot certonly --webroot -w $ROOT_DIR -d $DOMAIN -d www.$DOMAIN --agree-tos --email admin@$DOMAIN --non-interactive

# Konfigurasi HTTPS vhost
cat <<EOF > /etc/openresty/sites-available/$DOMAIN.conf
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN www.$DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    root $ROOT_DIR;
    index index.php index.html;

    access_log /var/log/openresty/$DOMAIN.access.log;
    error_log /var/log/openresty/$DOMAIN.error.log;

    include /etc/openresty/waf.conf;

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

# Restart layanan
systemctl restart php${PHP_VERSION}-fpm
systemctl restart openresty

# Tambah cron renew SSL
(crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet && systemctl reload openresty") | crontab -

echo "✅ Instalasi selesai. Situs aman HTTPS tersedia di https://$DOMAIN"
