#!/bin/bash

###############################################################################
# Setup Complet Soso Delivery sur Serveur
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

read -p "Continuer? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

ssh root@${VPS_IP} << ENDSSH

set -e

echo "📁 Étape 1: Création de la structure du projet"
mkdir -p /var/www/${PROJECT_NAME}/{backend,frontend,logs}
echo "✅ Structure créée"

echo ""
echo "📥 Étape 2: Clonage du repository"
cd /var/www/${PROJECT_NAME}

# Cloner dans un dossier temporaire
git clone ${REPO_URL} temp_repo

# Copier les fichiers
echo "Copie du backend..."
cp -r temp_repo/main-app-v10/admin-panel/* backend/ 2>/dev/null || echo "Backend déjà présent"

echo "Copie du frontend..."
cp -r temp_repo/react-user-website/StackFood\ React/* frontend/ 2>/dev/null || echo "Frontend déjà présent"

# Nettoyer
rm -rf temp_repo

echo "✅ Code copié"

echo ""
echo "🔧 Étape 3: Configuration Backend (Laravel)"
cd backend

# Vérifier si .env existe
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ .env créé"
else
    echo "⚠️  .env existe déjà"
fi

# Installer les dépendances
if [ -d "vendor" ]; then
    echo "Vendor existe, mise à jour..."
    composer update --no-dev --optimize-autoloader
else
    echo "Installation des dépendances..."
    composer install --no-dev --optimize-autoloader
fi

# Générer la clé si nécessaire
php artisan key:generate --force 2>/dev/null || echo "Clé déjà générée"

# Permissions
chown -R www-data:www-data .
chmod -R 775 storage bootstrap/cache

echo "✅ Backend configuré"

echo ""
echo "🔧 Étape 4: Configuration Frontend (Next.js)"
cd ../frontend

# Installer les dépendances
if [ -d "node_modules" ]; then
    echo "node_modules existe, mise à jour..."
    npm ci
else
    echo "Installation des dépendances..."
    npm ci
fi

# Créer .env.local si nécessaire
if [ ! -f .env.local ]; then
    cat > .env.local << 'EOF'
NEXT_PUBLIC_BASE_URL=https://${DOMAIN}/api/v1
NEXT_PUBLIC_SOCKET_URL=https://${DOMAIN}
NEXT_PUBLIC_GOOGLE_MAP_KEY=
PORT=3002
EOF
    echo "✅ .env.local créé"
else
    echo "⚠️  .env.local existe déjà"
fi

echo "✅ Frontend configuré"

echo ""
echo "🗄️  Étape 5: Base de données"
# Demander le mot de passe root MySQL
read -sp "Mot de passe root MySQL: " MYSQL_ROOT_PASS
echo ""

# Générer un mot de passe aléatoire pour l'utilisateur
DB_PASS=\$(openssl rand -base64 32)

mysql -u root -p"\${MYSQL_ROOT_PASS}" << 'EOSQL'
CREATE DATABASE IF NOT EXISTS soso_delivery_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'soso_delivery_user'@'localhost' IDENTIFIED BY '\${DB_PASS}';
GRANT ALL PRIVILEGES ON soso_delivery_db.* TO 'soso_delivery_user'@'localhost';
FLUSH PRIVILEGES;
EOSQL

echo "✅ Base de données créée"
echo "Utilisateur: soso_delivery_user"
echo "Mot de passe: \${DB_PASS}"
echo "⚠️  SAUVEGARDER CE MOT DE PASSE!"

# Mettre à jour le .env
cd /var/www/${PROJECT_NAME}/backend
sed -i "s/DB_DATABASE=.*/DB_DATABASE=soso_delivery_db/" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=soso_delivery_user/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=\${DB_PASS}/" .env
sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|" .env

# Migrer la base de données
php artisan migrate --force
php artisan storage:link

echo "✅ Migrations exécutées"

echo ""
echo "🌐 Étape 6: Configuration Nginx"

cat > /etc/nginx/sites-available/${PROJECT_NAME} << 'EOFNGINX'
# Soso Delivery - Nginx Configuration
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};
    
    root /var/www/${PROJECT_NAME}/backend/public;
    index index.php index.html;
    
    client_max_body_size 100M;
    
    access_log /var/log/nginx/soso-delivery-access.log;
    error_log /var/log/nginx/soso-delivery-error.log;
    
    # API routes
    location /api {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    # Admin panel
    location /admin {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    # Storage
    location /storage {
        alias /var/www/${PROJECT_NAME}/backend/storage/app/public;
        expires 30d;
    }
    
    # PHP
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # Frontend Next.js
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location ~ /\. {
        deny all;
    }
}
EOFNGINX

# Activer le site
ln -sf /etc/nginx/sites-available/${PROJECT_NAME} /etc/nginx/sites-enabled/

# Tester Nginx
nginx -t

# Recharger Nginx
systemctl reload nginx

echo "✅ Nginx configuré"

echo ""
echo "🚀 Étape 7: Démarrage Frontend avec PM2"
cd /var/www/${PROJECT_NAME}/frontend

# Build Next.js
npm run build

# Arrêter l'ancien process s'il existe
pm2 delete soso-delivery-frontend 2>/dev/null || true

# Démarrer avec PM2
pm2 start npm --name "soso-delivery-frontend" -- start
pm2 save

echo "✅ Frontend démarré sur port 3002"

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   ✅ INSTALLATION TERMINÉE !                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Informations importantes:"
echo "- Projet: /var/www/${PROJECT_NAME}/"
echo "- Base de données: soso_delivery_db"
echo "- Utilisateur DB: soso_delivery_user"
echo "- Mot de passe DB: \${DB_PASS}"
echo ""
echo "Prochaines étapes:"
echo "1. Configurer DNS: ${DOMAIN} → ${VPS_IP}"
echo "2. Installer SSL: certbot --nginx -d ${DOMAIN}"
echo "3. Configurer les API keys dans .env"
echo "4. Tester: https://${DOMAIN}"

ENDSSH

echo ""
echo "✅ Setup terminé sur le serveur!"
