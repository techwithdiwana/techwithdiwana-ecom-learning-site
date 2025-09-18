# Tech With Diwana — Single Server Project

This project shows how **frontend + backend** run together on one Ubuntu server with **nginx**.

## Components
- **Frontend**: Static files (`index.html`, `styles.css`, `app.js`) served by nginx
- **Backend**: Node.js (Express) providing `/api/courses` and `/api/purchase`

## Steps to deploy
1. Install nginx + nodejs
2. Copy `index.html`, `styles.css`, `app.js` into `/var/www/techwithdiwana`
3. Copy backend into `/opt/techwithdiwana/backend`
4. Run backend: `node server.js` or create systemd service
5. Configure nginx to serve `/` from `/var/www/techwithdiwana` and proxy `/api/` to `127.0.0.1:3000`

## Quickstart
```bash
sudo apt update
sudo apt install -y nginx nodejs npm
cd backend
npm init -y && npm install express
node server.js &
```
Open http://<server-ip>/
