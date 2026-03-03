#!/bin/bash

###############################################################################
# Setup Soso Delivery avec Mot de Passe et Configuration SSH
# Serveur: 77.42.34.90
###############################################################################

set -e

VPS_IP="77.42.34.90"
VPS_PASSWORD="ntp4vAsPJUqk"
DOMAIN="soso-delivery.xyz"
PROJECT_NAME="soso-delivery"
REPO_URL="https://github.com/Shahil-AppDev/soso-delivery.git"

echo "🚀 Setup Soso Delivery avec configuration SSH automatique"
echo "=========================================================="

# Étape 1: Générer la clé SSH locale
echo "🔑 Génération de la clé SSH..."
if [ ! -f "soso-deployment-key" ]; then
    ssh-keygen -t ed25519 -f soso-deployment-key -q -N ""
    echo "✅ Clé SSH générée"
else
    echo "⚠️  Clé SSH existe déjà"
fi

# Étape 2: Installer sshpass si nécessaire
if ! command -v sshpass &> /dev/null; then
    echo "⚠️  sshpass n'est pas installé. Installation..."
    # Sur Windows avec Git Bash, utiliser expect à la place
    echo "Note: Sur Windows, utilisez le script manuel"
fi

# Étape 3: Copier la clé publique sur le serveur
echo "📤 Installation de la clé SSH sur le serveur..."
cat soso-deployment-key.pub | ssh -o StrictHostKeyChecking=no root@${VPS_IP} "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && chmod 700 ~/.ssh"

echo "✅ Clé SSH installée"

# Étape 4: Tester la connexion SSH
echo "🔐 Test de connexion SSH..."
ssh -i soso-deployment-key -o StrictHostKeyChecking=no root@${VPS_IP} "echo 'Connexion SSH réussie!'"

# Étape 5: Exécuter le setup sur le serveur
echo ""
echo "🚀 Lancement du setup sur le serveur..."

ssh -i soso-deployment-key root@${VPS_IP} << 'ENDSSH'

set -e

PROJECT_NAME="soso-delivery"
DOMAIN="soso-delivery.xyz"
REPO_URL="https://github.com/Shahil-AppDev/soso-delivery.git"

echo "📁 Étape 1: Création de la structure..."
mkdir -p /var/www/${PROJECT_NAME}/{backend,frontend,logs}

echo "📥 Étape 2: Clonage du repository..."
cd /var/www/${PROJECT_NAME}
rm -rf temp_repo
git clone ${REPO_URL} temp_repo

# Copier backend
if [ -d "backend/vendor" ]; then
    rsync -av --exclude='.env' --exclude='vendor' --exclude='storage' temp_repo/main-app-v10/admin-panel/ backend/
else
    cp -r temp_repo/main-app-v10/admin-panel backend/
fi

# Copier frontend
if [ -d "frontend/node_modules" ]; then
    rsync -av --exclude='.env.local' --exclude='node_modules' --exclude='.next' "temp_repo/react-user-website/StackFood React/" frontend/
else
    cp -r "temp_repo/react-user-website/StackFood React" frontend/
fi

rm -rf temp_repo

echo "🔧 Étape 3: Configuration Backend..."
cd /var/www/${PROJECT_NAME}/backend

if [ ! -f .env ]; then
    cp .env.example .env
    sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|" .env
    sed -i "s|APP_ENV=.*|APP_ENV=production|" .env
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=soso_delivery_db|" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=soso_delivery_user|" .env
fi

composer install --no-dev --optimize-autoloader --no-interaction
php artisan key:generate --force
php artisan storage:link 2>/dev/null || true
chown -R www-data:www-data .
chmod -R 775 storage bootstrap/cache

echo "🔧 Étape 4: Configuration Frontend..."
cd /var/www/${PROJECT_NAME}/frontend

if [ ! -f .env.local ]; then
    cat > .env.local << 'EOF'
NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz/api/v1
NEXT_PUBLIC_SOCKET_URL=https://soso-delivery.xyz
PORT=3002
EOF
fi

npm ci

echo "🌐 Étape 5: Configuration Nginx..."
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

echo "🚀 Étape 6: Build et PM2..."
cd /var/www/${PROJECT_NAME}/frontend
npm run build
pm2 delete soso-delivery-frontend 2>/dev/null || true
pm2 start npm --name "soso-delivery-frontend" -- start
pm2 save
pm2 startup systemd -u root --hp /root 2>/dev/null || true

echo ""
echo "✅ INSTALLATION TERMINÉE!"
echo ""
pm2 list
systemctl status nginx --no-pager | head -5

ENDSSH

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   ✅ SETUP TERMINÉ AVEC SUCCÈS !                      ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Informations importantes:"
echo "- Clé SSH: soso-deployment-key (privée)"
echo "- Clé publique: soso-deployment-key.pub"
echo "- Projet: /var/www/soso-delivery/"
echo ""
echo "🔑 Prochaines étapes:"
echo "1. Ajouter la clé privée aux secrets GitHub:"
echo "   - Nom: SSH_PRIVATE_KEY"
echo "   - Valeur: Contenu de 'soso-deployment-key'"
echo ""
echo "2. Configurer la base de données sur le serveur"
echo "3. Configurer le DNS"
echo "4. Installer SSL"
echo ""
echo "Pour afficher la clé privée:"
echo "cat soso-deployment-key"
