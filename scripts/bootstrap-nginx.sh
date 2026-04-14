#!/usr/bin/env bash
set -euo pipefail
set -x


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/defaults.sh"


###############################################################################
# SSH BOOTSTRAP (ALL REAL WORK HAPPENS HERE)
###############################################################################
ssh $SSH_OPTS "$SSH_HOST" <<'EOF'

set -euo pipefail

###############################################################################
# DOCKER
###############################################################################
sudo apt update
sudo apt install -y ca-certificates curl nginx
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker devopsadmin

###############################################################################
# BACKEND CONTAINER (LOCALHOST ONLY)
###############################################################################
sudo docker rm -f app 2>/dev/null || true
sudo docker run -d \
  --name app \
  -p 127.0.0.1:8080:80 \
  nginx

###############################################################################
# NGINX REVERSE PROXY
###############################################################################
sudo tee /etc/nginx/sites-available/app >/dev/null <<'NGINX'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX

sudo ln -sf /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

echo "✅ bootstrap NGINX finished"
EOF

###############################################################################
# FINAL
###############################################################################
echo "✅ DONE"
echo "🌍 http://$PUBLIC_IP"
