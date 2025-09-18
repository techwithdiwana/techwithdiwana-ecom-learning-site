#!/usr/bin/env bash
set -e
apt update -y
apt install -y nginx nodejs npm

# Frontend setup
SITE_ROOT=/var/www/techwithdiwana
mkdir -p $SITE_ROOT
cp index.html styles.css app.js $SITE_ROOT
chown -R www-data:www-data $SITE_ROOT

# Backend setup
BACKEND_DIR=/opt/techwithdiwana/backend
mkdir -p $BACKEND_DIR
cp backend/server.js backend/db.json $BACKEND_DIR
cd $BACKEND_DIR
npm init -y
npm install express

# Systemd service
cat <<EOF >/etc/systemd/system/techwithdiwana-backend.service
[Unit]
Description=Tech With Diwana Backend
After=network.target

[Service]
ExecStart=/usr/bin/node /opt/techwithdiwana/backend/server.js
Restart=on-failure
User=www-data

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now techwithdiwana-backend

# Nginx config
cat <<EOF >/etc/nginx/sites-available/techwithdiwana
server {
    listen 80;
    server_name _;
    root /var/www/techwithdiwana;
    index index.html;
    location /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

ln -sf /etc/nginx/sites-available/techwithdiwana /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx
