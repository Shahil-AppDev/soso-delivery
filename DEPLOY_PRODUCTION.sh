#!/bin/bash

###############################################################################
# DÉPLOIEMENT PRODUCTION SOSO DELIVERY
# DevOps Senior - Déploiement Isolé et Sécurisé
###############################################################################

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  DÉPLOIEMENT PRODUCTION - SOSO DELIVERY                        ║"
echo "║  Serveur: 77.42.34.90                                          ║"
echo "║  Domaine: soso-delivery.xyz                                    ║"
echo "╚════════════════════════════════════════════════════════════════╝"

# Variables
PROJECT_NAME="soso-delivery"
DOMAIN="soso-delivery.xyz"
REPO_URL="https://github.com/Shahil-AppDev/soso-delivery.git"
PORT=3004  # ⚠️ Port 3002 déjà utilisé par angeline
PROJECT_PATH="/var/www/${PROJECT_NAME}"

# ============================================================================
# PHASE 1 - ISOLATION PROJET
# ============================================================================

echo ""
echo "═══ PHASE 1 - ISOLATION PROJET ═══"

# Créer utilisateur dédié si inexistant
if ! id "deploy-soso" &>/dev/null; then
    echo "Création utilisateur deploy-soso..."
    useradd -r -s /bin/bash -d /home/deploy-soso -m deploy-soso
    usermod -aG www-data deploy-soso
    echo "✅ Utilisateur créé"
else
    echo "✅ Utilisateur deploy-soso existe"
fi

# Créer structure
echo "Création structure de dossiers..."
mkdir -p ${PROJECT_PATH}/{backend,frontend,logs,repo-temp}
echo "✅ Structure créée"

# ============================================================================
# PHASE 2 - DEPLOY GIT SAFE
# ============================================================================

echo ""
echo "═══ PHASE 2 - CLONAGE SÉCURISÉ ═══"

cd ${PROJECT_PATH}

# Nettoyer repo temp si existe
rm -rf repo-temp
mkdir -p repo-temp

# Cloner
echo "Clonage du repository..."
git clone ${REPO_URL} repo-temp

# Extraire backend
echo "Extraction backend..."
if [ -d "backend/vendor" ]; then
    # Mise à jour sans écraser .env
    rsync -av --exclude='.env' --exclude='vendor' --exclude='storage' --exclude='node_modules' \
        repo-temp/main-app-v10/admin-panel/ backend/
else
    # Première installation
    cp -r repo-temp/main-app-v10/admin-panel/* backend/
fi

# Extraire frontend
echo "Extraction frontend..."
if [ -d "frontend/node_modules" ]; then
    # Mise à jour
    rsync -av --exclude='.env.local' --exclude='node_modules' --exclude='.next' \
        "repo-temp/react-user-website/StackFood React/" frontend/
else
    # Première installation
    cp -r "repo-temp/react-user-website/StackFood React"/* frontend/
fi

# Nettoyer
rm -rf repo-temp
echo "✅ Code extrait"

# ============================================================================
# PHASE 3 - BACKEND LARAVEL
# ============================================================================

echo ""
echo "═══ PHASE 3 - BACKEND LARAVEL ═══"

cd ${PROJECT_PATH}/backend

# .env sécurisé
if [ ! -f .env ]; then
    echo "Création .env..."
    cp .env.example .env
    
    # Configuration automatique
    sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|" .env
    sed -i "s|APP_ENV=.*|APP_ENV=production|" .env
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=soso_delivery_db|" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=soso_delivery_user|" .env
    
    echo "⚠️  IMPORTANT: Configurer DB_PASSWORD dans .env"
else
    echo "✅ .env existe (non écrasé)"
fi

# Composer
echo "Installation dépendances Composer..."
composer install --no-dev --optimize-autoloader --no-interaction

# Artisan
if grep -q "APP_KEY=$" .env || grep -q "APP_KEY=base64:$" .env; then
    echo "Génération APP_KEY..."
    php artisan key:generate --force
fi

php artisan storage:link 2>/dev/null || echo "Storage link existe"

# Permissions
chown -R deploy-soso:www-data .
chmod -R 775 storage bootstrap/cache
chmod 644 .env

echo "✅ Backend configuré"

# ============================================================================
# PHASE 4 - FRONTEND NEXT.JS
# ============================================================================

echo ""
echo "═══ PHASE 4 - FRONTEND NEXT.JS ═══"

cd ${PROJECT_PATH}/frontend

# .env.local sécurisé
if [ ! -f .env.local ]; then
    echo "Création .env.local..."
    cat > .env.local << EOF
NEXT_PUBLIC_BASE_URL=https://${DOMAIN}/api/v1
NEXT_PUBLIC_SOCKET_URL=https://${DOMAIN}
PORT=${PORT}
EOF
    echo "✅ .env.local créé"
else
    # Mettre à jour le port si changé
    sed -i "s|PORT=.*|PORT=${PORT}|" .env.local
    echo "✅ .env.local existe (port mis à jour)"
fi

# NPM
echo "Installation dépendances NPM..."
npm ci --production=false

# Build
echo "Build Next.js..."
npm run build

# Permissions
chown -R deploy-soso:www-data .

echo "✅ Frontend buildé"

# ============================================================================
# PHASE 5 - NGINX SAFE BLOCK
# ============================================================================

echo ""
echo "═══ PHASE 5 - NGINX SÉCURISÉ ═══"

NGINX_CONF="/etc/nginx/sites-available/${PROJECT_NAME}"
NGINX_BACKUP="/etc/nginx/sites-available/${PROJECT_NAME}.backup.$(date +%Y%m%d_%H%M%S)"

# Backup si existe
if [ -f ${NGINX_CONF} ]; then
    echo "Backup config existante..."
    cp ${NGINX_CONF} ${NGINX_BACKUP}
fi

# Créer nouvelle config
echo "Création configuration Nginx..."
cat > ${NGINX_CONF} << 'EOFNGINX'
# Soso Delivery - Configuration Nginx
# Généré automatiquement - Ne pas modifier manuellement

server {
    listen 80;
    listen [::]:80;
    server_name soso-delivery.xyz www.soso-delivery.xyz;
    
    # Logs dédiés
    access_log /var/www/soso-delivery/logs/nginx-access.log;
    error_log /var/www/soso-delivery/logs/nginx-error.log;
    
    # Sécurité
    client_max_body_size 100M;
    client_body_timeout 300s;
    
    # Backend Laravel (API + Admin)
    location ~ ^/(api|admin|storage) {
        root /var/www/soso-delivery/backend/public;
        index index.php;
        
        try_files $uri $uri/ /index.php?$query_string;
        
        location ~ \.php$ {
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
            include fastcgi_params;
            fastcgi_read_timeout 300;
            fastcgi_buffers 16 16k;
            fastcgi_buffer_size 32k;
        }
    }
    
    # Storage Laravel
    location /storage {
        alias /var/www/soso-delivery/backend/storage/app/public;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # Frontend Next.js (proxy vers port 3004)
    location / {
        proxy_pass http://localhost:3004;
        proxy_http_version 1.1;
        
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    # Sécurité - Bloquer fichiers sensibles
    location ~ /\. {
        deny all;
    }
    
    location ~ /\.env {
        deny all;
    }
}
EOFNGINX

# Activer site
ln -sf ${NGINX_CONF} /etc/nginx/sites-enabled/${PROJECT_NAME}

# Test Nginx
echo "Test configuration Nginx..."
if nginx -t 2>&1 | grep -q "successful"; then
    echo "✅ Configuration Nginx valide"
    systemctl reload nginx
    echo "✅ Nginx rechargé"
else
    echo "❌ ERREUR: Configuration Nginx invalide"
    # Rollback
    if [ -f ${NGINX_BACKUP} ]; then
        echo "Rollback vers backup..."
        cp ${NGINX_BACKUP} ${NGINX_CONF}
        systemctl reload nginx
    fi
    exit 1
fi

# ============================================================================
# PHASE 6 - PM2 ISOLÉ
# ============================================================================

echo ""
echo "═══ PHASE 6 - PM2 ISOLÉ ═══"

cd ${PROJECT_PATH}/frontend

# Arrêter process existant si présent
pm2 delete soso-delivery-frontend 2>/dev/null || echo "Pas de process existant"

# Démarrer nouveau process
echo "Démarrage PM2 sur port ${PORT}..."
pm2 start npm --name "soso-delivery-frontend" -- start

# Sauvegarder
pm2 save

# Vérifier
if pm2 list | grep -q "soso-delivery-frontend"; then
    echo "✅ PM2 démarré"
else
    echo "❌ ERREUR: PM2 non démarré"
    exit 1
fi

# ============================================================================
# PHASE 7 - BASE DE DONNÉES
# ============================================================================

echo ""
echo "═══ PHASE 7 - BASE DE DONNÉES ═══"

# Vérifier si DB existe
if mysql -u root -e "USE soso_delivery_db" 2>/dev/null; then
    echo "✅ Base de données existe"
else
    echo "⚠️  Base de données à créer manuellement:"
    echo ""
    echo "mysql -u root -p"
    echo "CREATE DATABASE soso_delivery_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    echo "CREATE USER 'soso_delivery_user'@'localhost' IDENTIFIED BY 'VotreMotDePasse';"
    echo "GRANT ALL PRIVILEGES ON soso_delivery_db.* TO 'soso_delivery_user'@'localhost';"
    echo "FLUSH PRIVILEGES;"
    echo "EXIT;"
    echo ""
fi

# ============================================================================
# PHASE 8 - CHECK FINAL
# ============================================================================

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  PHASE 8 - VÉRIFICATIONS FINALES                               ║"
echo "╚════════════════════════════════════════════════════════════════╝"

echo ""
echo "1. Structure projet:"
ls -lah ${PROJECT_PATH}/

echo ""
echo "2. PM2 Status:"
pm2 list

echo ""
echo "3. Nginx Status:"
systemctl status nginx --no-pager | head -10

echo ""
echo "4. Ports utilisés:"
ss -tulnp | grep -E ":(${PORT}|80|443)"

echo ""
echo "5. Test local API:"
curl -s http://localhost/api/v1/config | head -20 || echo "API non accessible (normal si DB pas configurée)"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ DÉPLOIEMENT TERMINÉ                                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"

echo ""
echo "📋 RÉSUMÉ:"
echo "- Projet: ${PROJECT_PATH}"
echo "- Frontend: Port ${PORT} (PM2: soso-delivery-frontend)"
echo "- Backend: PHP-FPM via Nginx"
echo "- Nginx: /etc/nginx/sites-available/${PROJECT_NAME}"
echo "- Logs: ${PROJECT_PATH}/logs/"
echo ""
echo "⚠️  ACTIONS REQUISES:"
echo "1. Configurer DB_PASSWORD dans ${PROJECT_PATH}/backend/.env"
echo "2. Créer la base de données (voir commandes ci-dessus)"
echo "3. Exécuter migrations: cd ${PROJECT_PATH}/backend && php artisan migrate --force"
echo "4. Configurer DNS: soso-delivery.xyz → 77.42.34.90"
echo "5. Installer SSL: certbot --nginx -d soso-delivery.xyz -d www.soso-delivery.xyz"
echo ""
echo "🌐 URLs (après DNS + SSL):"
echo "- Frontend: https://soso-delivery.xyz"
echo "- Admin: https://soso-delivery.xyz/admin"
echo "- API: https://soso-delivery.xyz/api/v1"
