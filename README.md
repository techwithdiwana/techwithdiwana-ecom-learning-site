# 🌐 Tech With Diwana — E-Commerce Learning Site Demo

[![Repo size](https://img.shields.io/github/repo-size/techwithdiwana/techwithdiwana-ecom-learning-site)](https://github.com/techwithdiwana/techwithdiwana-ecom-learning-site)
[![Last commit](https://img.shields.io/github/last-commit/techwithdiwana/techwithdiwana-ecom-learning-site)](https://github.com/techwithdiwana/techwithdiwana-ecom-learning-site/commits/main)
[![License: MIT](https://img.shields.io/badge/license-MIT-brightgreen)](LICENSE)

📺 **YouTube:** [Tech With Diwana](https://youtube.com/@techwithdiwana)  
🔔 **Subscribe** to support and learn DevOps + IT hands-on projects.

---

## 🔭 About

This repository contains a professional **E-Commerce Learning Site Demo** for **Tech With Diwana**.  
It demonstrates how to deploy a **static frontend with an optional Node.js backend** on a single **Ubuntu EC2 instance using NGINX**.

### ✨ Key Features
- Responsive landing page: **Welcome To Tech With Diwana**
- E-commerce style course gallery with title, description, and price
- Demo backend (`/api/courses`) serving JSON course list + purchase API
- One-click deploy script (`script.sh`) to set up everything on Ubuntu/EC2
- Beginner-friendly: safe defaults, idempotent script, no destructive commands

---

## 🏗 Architecture

**System flow:**

```
Browser → NGINX → (Static frontend: HTML/CSS/JS)
                     ↘ (Optional backend: Node.js via /api/ proxy)
```

![Architecture](architecture.png)

---

## 🖥 First Page Preview

![First Page](firstpage.png)

> **Welcome To Tech With Diwana**  
> Curated IT courses & hands-on projects — learn, build, deploy.

_Course Cards Example:_  
- DevOps Bootcamp — CI/CD, Docker, Kubernetes  
- Fullstack JS — React + Node.js  

---

## 🚀 Deployment Steps (Ubuntu / EC2)

### Option A — Automated (recommended)

Upload `script.sh` and run:
```bash
chmod +x script.sh
# with backend
sudo ./script.sh
# without backend
ENABLE_BACKEND=false sudo ./script.sh
```

### Option B — Manual Steps

1. **Connect to server:**
```bash
ssh -i "your-key.pem" ubuntu@<EC2-PUBLIC-IP>
```

2. **Install required packages:**
```bash
sudo apt update
sudo apt install -y nginx git curl jq
```

3. **Clone repo to site root:**
```bash
sudo mkdir -p /var/www/techwithdiwana
sudo git clone https://github.com/techwithdiwana/techwithdiwana-ecom-learning-site.git /var/www/techwithdiwana
```

4. **Set permissions:**
```bash
sudo chown -R www-data:www-data /var/www/techwithdiwana
sudo find /var/www/techwithdiwana -type d -exec chmod 755 {} \;
sudo find /var/www/techwithdiwana -type f -exec chmod 644 {} \;
```

5. **Create Nginx site config `/etc/nginx/sites-available/techwithdiwana`:**
```nginx
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name _;

  root /var/www/techwithdiwana;
  index index.html;

  # API proxy to backend
  location ^~ /api/ {
    proxy_pass http://127.0.0.1:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }

  location / {
    try_files $uri $uri/ /index.html;
  }

  location ~* \.(?:css|js|jpg|jpeg|png|gif|ico|svg|webp)$ {
    expires 7d;
    add_header Cache-Control "public";
  }
}
```

6. **Enable site & reload nginx:**
```bash
sudo ln -sf /etc/nginx/sites-available/techwithdiwana /etc/nginx/sites-enabled/techwithdiwana
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

7. **Open in browser:**
```
http://<EC2-PUBLIC-IP>
```

---

## 📂 Project structure

```
techwithdiwana-ecom-learning-site/
├── index.html
├── styles.css
├── app.js
├── backend/ (optional Node backend)
├── script.sh
├── README.md
├── LICENSE
├── architecture.png
└── firstpage.png
```

---

## 🛡 License

MIT License — see [LICENSE](LICENSE).

---

## 👨‍🏫 Author & Contact

**Tech With Diwana**  
- YouTube: [Tech With Diwana](https://youtube.com/@techwithdiwana)  
- Email: your-email@example.com
