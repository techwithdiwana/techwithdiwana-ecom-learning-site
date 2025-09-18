#!/usr/bin/env bash
# script.sh - safe deploy for Tech With Diwana static site on Ubuntu/EC2
set -euo pipefail

REPO_URL="https://github.com/techwithdiwana/techwithdiwana-ecom-learning-site.git"
SITE_ROOT="/var/www/techwithdiwana"
NGINX_SITE="/etc/nginx/sites-available/techwithdiwana"

echo "=== Tech With Diwana: deploy script ==="

apt-get update -y
if ! command -v nginx >/dev/null 2>&1; then
  apt-get install -y nginx
fi
if ! command -v git >/dev/null 2>&1; then
  apt-get install -y git
fi

mkdir -p "$SITE_ROOT"

if [ -f "./index.html" ]; then
  cp -r ./index.html ./styles.css ./app.js "$SITE_ROOT/" 2>/dev/null || true
else
  TMP_CLONE="/tmp/techwithdiwana_deploy_$$"
  rm -rf "$TMP_CLONE"
  git clone --depth=1 "$REPO_URL" "$TMP_CLONE"
  cp -r "$TMP_CLONE"/* "$SITE_ROOT"/
  rm -rf "$TMP_CLONE"
fi

if [ ! -f "$SITE_ROOT/index.html" ]; then
  cat > "$SITE_ROOT/index.html" <<'HTML'
<!doctype html><html><head><title>Welcome To Tech With Diwana</title></head><body><h1>Welcome To Tech With Diwana</h1></body></html>
HTML
fi

chown -R www-data:www-data "$SITE_ROOT"
find "$SITE_ROOT" -type d -exec chmod 755 {} \;
find "$SITE_ROOT" -type f -exec chmod 644 {} \;

cat > "$NGINX_SITE" <<'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    root /var/www/techwithdiwana;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~* \.(?:css|js|jpg|jpeg|png|gif|ico|svg|webp)$ {
        expires 7d;
        add_header Cache-Control "public";
    }
}
NGINX

ln -sf "$NGINX_SITE" /etc/nginx/sites-enabled/techwithdiwana
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default || true

nginx -t
systemctl reload nginx

echo "=== Deploy complete ==="
echo "Open your server IP in browser: http://<EC2-PUBLIC-IP>/"
