#!/bin/bash

###############################################################################
# Setup Automatique Soso Delivery sur Serveur
# Serveur: 77.42.34.90
# Domaine: soso-delivery.xyz
###############################################################################

set -e

VPS_IP="77.42.34.90"
DOMAIN="soso-delivery.xyz"
PROJECT_NAME="soso-delivery"
REPO_URL="https://github.com/Shahil-AppDev/soso-delivery.git"

echo "🚀 Setup Soso Delivery sur le serveur"
echo "======================================"
echo "Serveur: $VPS_IP"
echo "Domaine: $DOMAIN"
echo "Projet: $PROJECT_NAME"
echo ""

# Connexion SSH avec acceptation automatique de la clé
ssh -o StrictHostKeyChecking=no root@${VPS_IP} << 'ENDSSH'

set -e

echo "📁 Étape 1: Création de la structure du projet"
mkdir -p /var/www/soso-delivery/{backend,frontend,logs}
echo "✅ Structure créée"

echo ""
echo "📥 Étape 2: Clonage du repository"
cd /var/www/soso-delivery

# Cloner dans un dossier temporaire
if [ -d "temp_repo" ]; then
    rm -rf temp_repo
fi

git clone https://github.com/Shahil-AppDev/soso-delivery.git temp_repo

# Copier les fichiers
echo "Copie du backend..."
if [ -d "backend" ]; then
    echo "Backend existe, mise à jour..."
    rsync -av --exclude='.env' --exclude='vendor' --exclude='storage' temp_repo/main-app-v10/admin-panel/ backend/
else
    cp -r temp_repo/main-app-v10/admin-panel backend/
fi

echo "Copie du frontend..."
if [ -d "frontend" ]; then
    echo "Frontend existe, mise à jour..."
    rsync -av --exclude='.env.local' --exclude='node_modules' --exclude='.next' temp_repo/react-user-website/StackFood\ React/ frontend/
else
    cp -r temp_repo/react-user-website/StackFood\ React frontend/
fi

# Nettoyer
rm -rf temp_repo

echo "✅ Code copié"

echo ""
echo "🔧 Étape 3: Configuration Backend (Laravel)"
cd /var/www/soso-delivery/backend

# Vérifier si .env existe
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ .env créé"
    
    # Configuration basique
    sed -i "s|APP_URL=.*|APP_URL=https://soso-delivery.xyz|" .env
    sed -i "s|APP_ENV=.*|APP_ENV=production|" .env
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=soso_delivery_db|" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=soso_delivery_user|" .env
else
    echo "⚠️  .env existe déjà"
fi

# Installer les dépendances
echo "Installation des dépendances Composer..."
composer install --no-dev --optimize-autoloader --no-interaction 2>&1 | tail -20

# Générer la clé si nécessaire
php artisan key:generate --force 2>/dev/null || echo "Clé déjà générée"

# Créer le lien storage
php artisan storage:link 2>/dev/null || echo "Storage link existe"

# Permissions
chown -R www-data:www-data .
chmod -R 775 storage bootstrap/cache

echo "✅ Backend configuré"

echo ""
echo "🔧 Étape 4: Configuration Frontend (Next.js)"
cd /var/www/soso-delivery/frontend

# Installer les dépendances
echo "Installation des dépendances NPM..."
npm ci 2>&1 | tail -20

# Créer .env.local si nécessaire
if [ ! -f .env.local ]; then
    cat > .env.local << 'EOF'
NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz/api/v1
NEXT_PUBLIC_SOCKET_URL=https://soso-delivery.xyz
NEXT_PUBLIC_GOOGLE_MAP_KEY=
PORT=3002
EOF
    echo "✅ .env.local créé"
else
    echo "⚠️  .env.local existe déjà"
fi

echo "✅ Frontend configuré"

echo ""
echo "🌐 Étape 5: Configuration Nginx"

cat > /etc/nginx/sites-available/soso-delivery << 'EOFNGINX'
# Soso Delivery - Nginx Configuration
server {
    listen 80;
    listen [::]:80;
    server_name soso-delivery.xyz www.soso-delivery.xyz;
    
    root /var/www/soso-delivery/backend/public;
    index index.php index.html;
    
    client_max_body_size 100M;
    
    access_log /var/log/nginx/soso-delivery-access.log;
    error_log /var/log/nginx/soso-delivery-error.log;
    
    # API routes
    location /api {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    # Admin panel
    location /admin {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    # Storage
    location /storage {
        alias /var/www/soso-delivery/backend/storage/app/public;
        expires 30d;
    }
    
    # PHP
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 300;
    }
    
    # Frontend Next.js
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

# Activer le site
ln -sf /etc/nginx/sites-available/soso-delivery /etc/nginx/sites-enabled/

# Tester Nginx
nginx -t

# Recharger Nginx
systemctl reload nginx

echo "✅ Nginx configuré"

echo ""
echo "🚀 Étape 6: Build et Démarrage Frontend avec PM2"
cd /var/www/soso-delivery/frontend

# Build Next.js
echo "Build Next.js en cours..."
npm run build 2>&1 | tail -20

# Arrêter l'ancien process s'il existe
pm2 delete soso-delivery-frontend 2>/dev/null || true

# Démarrer avec PM2
pm2 start npm --name "soso-delivery-frontend" -- start
pm2 save

echo "✅ Frontend démarré sur port 3002"

echo ""
echo "📊 Vérifications finales"
echo "PM2 Status:"
pm2 list

echo ""
echo "Nginx Status:"
systemctl status nginx --no-pager | head -5

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   ✅ INSTALLATION TERMINÉE !                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Informations importantes:"
echo "- Projet: /var/www/soso-delivery/"
echo "- Nginx config: /etc/nginx/sites-available/soso-delivery"
echo "- PM2 process: soso-delivery-frontend (port 3002)"
echo ""
echo "⚠️  Actions requises:"
echo "1. Configurer la base de données dans .env"
echo "2. Exécuter: cd /var/www/soso-delivery/backend && php artisan migrate"
echo "3. Configurer DNS: soso-delivery.xyz → 77.42.34.90"
echo "4. Installer SSL: certbot --nginx -d soso-delivery.xyz -d www.soso-delivery.xyz"
echo "5. Configurer les API keys dans .env et .env.local"
echo ""
echo "Test local:"
echo "curl http://localhost/api/v1/config"

ENDSSH

echo ""
echo "✅ Setup terminé sur le serveur!"
echo ""
echo "Prochaines étapes:"
echo "1. Configurer la base de données"
echo "2. Configurer le DNS"
echo "3. Installer SSL"
echo "4. Tester: https://soso-delivery.xyz"
