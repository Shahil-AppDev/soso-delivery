#!/bin/bash

# Configuration complète Soso Delivery sur le serveur
# Exécution directe avec SSH

ssh root@77.42.34.90 << 'ENDSSH'

set -e

PROJECT_NAME="soso-delivery"
DOMAIN="soso-delivery.xyz"
REPO_URL="https://github.com/Shahil-AppDev/soso-delivery.git"

echo "🚀 SETUP SOSO DELIVERY"
echo "======================"

# Étape 1: Structure
echo "📁 Création structure..."
mkdir -p /var/www/${PROJECT_NAME}/{backend,frontend,logs}

# Étape 2: Clone
echo "📥 Clonage repository..."
cd /var/www/${PROJECT_NAME}
rm -rf temp_repo
git clone ${REPO_URL} temp_repo

# Backend
echo "Copie backend..."
if [ -d "backend/vendor" ]; then
    rsync -av --exclude='.env' --exclude='vendor' --exclude='storage' temp_repo/main-app-v10/admin-panel/ backend/
else
    cp -r temp_repo/main-app-v10/admin-panel backend/
fi

# Frontend
echo "Copie frontend..."
if [ -d "frontend/node_modules" ]; then
    rsync -av --exclude='.env.local' --exclude='node_modules' --exclude='.next' "temp_repo/react-user-website/StackFood React/" frontend/
else
    cp -r "temp_repo/react-user-website/StackFood React" frontend/
fi

rm -rf temp_repo

# Étape 3: Backend
echo "🔧 Configuration Backend..."
cd /var/www/${PROJECT_NAME}/backend

if [ ! -f .env ]; then
    cp .env.example .env
    sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|" .env
    sed -i "s|APP_ENV=.*|APP_ENV=production|" .env
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=soso_delivery_db|" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=soso_delivery_user|" .env
fi

echo "Installation Composer..."
composer install --no-dev --optimize-autoloader --no-interaction
php artisan key:generate --force
php artisan storage:link 2>/dev/null || true
chown -R www-data:www-data .
chmod -R 775 storage bootstrap/cache

# Étape 4: Frontend
echo "🔧 Configuration Frontend..."
cd /var/www/${PROJECT_NAME}/frontend

if [ ! -f .env.local ]; then
    cat > .env.local << 'EOF'
NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz/api/v1
NEXT_PUBLIC_SOCKET_URL=https://soso-delivery.xyz
PORT=3002
EOF
fi

echo "Installation NPM..."
npm ci

# Étape 5: Nginx
echo "🌐 Configuration Nginx..."
cat > /etc/nginx/sites-available/${PROJECT_NAME} << 'EOFNGINX'
server {
    listen 80;
    server_name soso-delivery.xyz www.soso-delivery.xyz;
    root /var/www/soso-delivery/backend/public;
    index index.php index.html;
    client_max_body_size 100M;
    
    access_log /var/log/nginx/soso-delivery-access.log;
    error_log /var/log/nginx/soso-delivery-error.log;
    
    location /api {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location /admin {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location /storage {
        alias /var/www/soso-delivery/backend/storage/app/public;
        expires 30d;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 300;
    }
    
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location ~ /\. {
        deny all;
    }
}
EOFNGINX

ln -sf /etc/nginx/sites-available/${PROJECT_NAME} /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# Étape 6: PM2
echo "🚀 Build Frontend et PM2..."
cd /var/www/${PROJECT_NAME}/frontend
npm run build
pm2 delete soso-delivery-frontend 2>/dev/null || true
pm2 start npm --name "soso-delivery-frontend" -- start
pm2 save

echo ""
echo "✅ SETUP TERMINÉ!"
echo ""
echo "Vérifications:"
pm2 list
echo ""
systemctl status nginx --no-pager | head -5
echo ""
echo "Structure créée:"
ls -la /var/www/${PROJECT_NAME}/

ENDSSH

echo ""
echo "✅ Configuration terminée sur le serveur!"
