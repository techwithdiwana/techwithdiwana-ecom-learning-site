# 🌐 Tech With Diwana — E-Commerce Learning Site Demo

[![Repo size](https://img.shields.io/github/repo-size/techwithdiwana/techwithdiwana-ecom-learning-site)](https://github.com/techwithdiwana/techwithdiwana-ecom-learning-site)
[![Last commit](https://img.shields.io/github/last-commit/techwithdiwana/techwithdiwana-ecom-learning-site)](https://github.com/techwithdiwana/techwithdiwana-ecom-learning-site/commits/main)
[![License: MIT](https://img.shields.io/badge/license-MIT-brightgreen)](LICENSE)

**YouTube:** https://youtube.com/@techwithdiwana  
**Subscribe:** _Tech With Diwana_

---

## 🔭 About

This repository contains a beginner-friendly **E-Commerce Learning Site Demo** for **Tech With Diwana**.  
It shows how to host a website on **NGINX + Ubuntu EC2** safely with a one-click deploy script.

Features:
- Simple responsive homepage: **Welcome To Tech With Diwana**
- Ecommerce-style IT course gallery (static demo)
- Safe `script.sh` for Ubuntu/EC2 deploy

---

## 🏗 Architecture

```
Browser → NGINX → Static files (HTML, CSS, JS)
```

---

## 🖥 First Page Preview

**Homepage Hero:**

> Welcome To Tech With Diwana  
> Curated IT courses & hands-on projects — learn, build, deploy.

_Cards: DevOps Bootcamp, Fullstack JS, Kubernetes Hands-on, Linux Server Admin._

---

## 🚀 Quick deploy (Ubuntu / EC2) — safe steps

1. Connect to server:
```bash
ssh -i "your-key.pem" ubuntu@<EC2-PUBLIC-IP>
```

2. Install Nginx & Git:
```bash
sudo apt update
sudo apt install -y nginx git
```

3. Clone repo to site root:
```bash
sudo mkdir -p /var/www/techwithdiwana
sudo git clone https://github.com/techwithdiwana/techwithdiwana-ecom-learning-site.git /var/www/techwithdiwana
```

4. Set permissions:
```bash
sudo chown -R www-data:www-data /var/www/techwithdiwana
sudo find /var/www/techwithdiwana -type d -exec chmod 755 {} \;
sudo find /var/www/techwithdiwana -type f -exec chmod 644 {} \;
```

5. Configure Nginx `/etc/nginx/sites-available/techwithdiwana`:
```nginx
server {
  listen 80;
  server_name <EC2-PUBLIC-IP>;
  root /var/www/techwithdiwana;
  index index.html;

  location / {
    try_files $uri $uri/ =404;
  }

  location ~* \.(png|jpg|jpeg|svg|css|js)$ {
    expires 7d;
    add_header Cache-Control "public";
  }
}
```

6. Enable site & reload nginx:
```bash
sudo ln -sf /etc/nginx/sites-available/techwithdiwana /etc/nginx/sites-enabled/techwithdiwana
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

7. Open in browser:
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
├── script.sh
├── README.md
└── backend/ (optional Node backend)
```

---

## 🛠 Contribute

1. Fork repo  
2. Clone locally  
3. Create branch, commit & PR

---

## 🛡 License

MIT License — see [LICENSE](LICENSE).

---

## 👨‍🏫 Author & Contact

**Tech With Diwana**  
- YouTube: https://youtube.com/@techwithdiwana  
- Email: your-email@example.com
