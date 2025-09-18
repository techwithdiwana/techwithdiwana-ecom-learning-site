#!/usr/bin/env bash
set -euo pipefail
# Improved deploy script for Tech With Diwana (static + optional backend)
REPO_URL="https://github.com/techwithdiwana/techwithdiwana-ecom-learning-site.git"
SITE_ROOT="/var/www/techwithdiwana"
NGINX_SITE="/etc/nginx/sites-available/techwithdiwana"
BACKEND_DIR="/opt/techwithdiwana/backend"
ENABLE_BACKEND=true   # set to false if you don't want the demo backend installed

echo
echo "=== Tech With Diwana improved deploy ==="

# 1. install base packages
apt-get update -y
apt-get install -y nginx git curl jq

# 2. prepare site root
mkdir -p "$SITE_ROOT"
echo "Copying frontend files to $SITE_ROOT ..."
# prefer local files if script run from repo root
COPIED=false
for f in index.html styles.css app.js; do
  if [ -f "./$f" ]; then
    cp -v "./$f" "$SITE_ROOT/" || true
    COPIED=true
  fi
done
# copy folders if present
for d in assets css js images; do
  if [ -d "./$d" ]; then
    cp -rv "./$d" "$SITE_ROOT/" || true
    COPIED=true
  fi
done
# fallback: shallow clone if nothing present locally
if [ "$COPIED" = false ]; then
  echo "No local frontend detected — cloning from repo..."
  TMP="/tmp/techwithdiwana_deploy_$$"
  rm -rf "$TMP"
  git clone --depth=1 "$REPO_URL" "$TMP"
  cp -rv "$TMP"/* "$SITE_ROOT"/ || true
  rm -rf "$TMP"
fi

# ensure index.html exists
if [ ! -f "$SITE_ROOT/index.html" ]; then
  echo "Creating fallback index.html"
  cat > "$SITE_ROOT/index.html" <<'HTML'
<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Welcome To Tech With Diwana</title></head><body><h1>Welcome To Tech With Diwana</h1></body></html>
HTML
fi

# 3. permissions
chown -R www-data:www-data "$SITE_ROOT"
find "$SITE_ROOT" -type d -exec chmod 755 {} \;
find "$SITE_ROOT" -type f -exec chmod 644 {} \;

# 4. write nginx site (with safe try_files and proxy)
cat > "$NGINX_SITE" <<'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    root /var/www/techwithdiwana;
    index index.html;

    # API proxy
    location ^~ /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # serve static files; fallback to index.html for SPA-like behavior
    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(?:css|js|jpg|jpeg|png|gif|ico|svg|webp)$ {
        expires 7d;
        add_header Cache-Control "public";
    }
}
NGINX

ln -sf "$NGINX_SITE" /etc/nginx/sites-enabled/techwithdiwana
rm -f /etc/nginx/sites-enabled/default || true

# 5. optional backend bootstrap
if [ "$ENABLE_BACKEND" = true ]; then
  echo "Bootstrapping demo Node backend in $BACKEND_DIR ..."
  mkdir -p "$BACKEND_DIR"
  # prefer local backend folder if available
  if [ -d "./backend" ]; then
    cp -rv ./backend/* "$BACKEND_DIR"/ || true
  else
    # create minimal server.js and db.json
    cat > "$BACKEND_DIR/server.js" <<'NODE'
const express = require('express');
const fs = require('fs').promises;
const path = require('path');
const app = express();
app.use(express.json());
const DB = path.join(__dirname,'db.json');
async function readDB(){ try { return JSON.parse(await fs.readFile(DB,'utf8')); } catch(e){ return { courses: [] }; } }
async function writeDB(d){ await fs.writeFile(DB, JSON.stringify(d, null, 2)); }
app.get('/api/courses', async (req,res)=>{ const db = await readDB(); res.json(db.courses || []); });
app.post('/api/purchase', async (req,res)=>{ const {courseId,user} = req.body || {}; if(!courseId) return res.status(400).json({error:'courseId required'}); const db = await readDB(); db.purchases = db.purchases || []; db.purchases.push({id:Date.now(), courseId, user, ts: new Date().toISOString()}); await writeDB(db); res.json({success:true}); });
const PORT = process.env.PORT || 3000; app.listen(PORT, ()=> console.log('Backend listening on', PORT));
NODE
    cat > "$BACKEND_DIR/db.json" <<'DB'
{
  "courses": [
    {"id":"c1","title":"DevOps Bootcamp","description":"CI/CD, Docker, Kubernetes","price":999,"image":"https://via.placeholder.com/400x250?text=DevOps+Course"},
    {"id":"c2","title":"Fullstack JS","description":"React + Node.js","price":799,"image":"https://via.placeholder.com/400x250?text=Fullstack+JS"}
  ]
}
DB
  fi

  # install Node if missing (Node 18+ recommended)
  if ! command -v node >/dev/null 2>&1; then
    echo "Installing Node.js (Node 18 LTS)..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
  fi

  cd "$BACKEND_DIR"
  if [ ! -f package.json ]; then
    npm init -y >/dev/null 2>&1 || true
  fi
  npm install express >/dev/null 2>&1 || true

  # create systemd service
  cat > /etc/systemd/system/techwithdiwana-backend.service <<'SERVICE'
[Unit]
Description=TechWithDiwana Backend
After=network.target

[Service]
ExecStart=/usr/bin/node /opt/techwithdiwana/backend/server.js
Restart=on-failure
User=www-data
WorkingDirectory=/opt/techwithdiwana/backend

[Install]
WantedBy=multi-user.target
SERVICE

  systemctl daemon-reload
  systemctl enable --now techwithdiwana-backend || true
fi

# 6. Test & reload nginx
nginx -t
systemctl reload nginx

echo
echo "=== done ==="
echo "Open: http://<EC2-PUBLIC-IP>/"
echo "If gallery missing, run the diagnostic checks from earlier (curl /app.js and curl /api/courses)."
