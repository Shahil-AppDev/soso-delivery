# 🔧 Commandes pour Configurer le Serveur Soso Delivery

## 🚀 Setup Rapide (Copier-Coller)

Connecte-toi au serveur et exécute ces commandes:

```bash
ssh root@77.42.34.90
```

Puis copie-colle ce bloc complet:

```bash
# ============================================================================
# SETUP SOSO DELIVERY - COPIER TOUT CE BLOC
# ============================================================================

PROJECT_NAME="soso-delivery"
DOMAIN="soso-delivery.xyz"
REPO_URL="https://github.com/Shahil-AppDev/soso-delivery.git"

# Étape 1: Créer la structure
echo "📁 Création de la structure..."
mkdir -p /var/www/${PROJECT_NAME}/{backend,frontend,logs}

# Étape 2: Cloner le code
echo "📥 Clonage du repository..."
cd /var/www/${PROJECT_NAME}
rm -rf temp_repo
git clone ${REPO_URL} temp_repo

# Copier backend
echo "Copie backend..."
if [ -d "backend/vendor" ]; then
    rsync -av --exclude='.env' --exclude='vendor' --exclude='storage' temp_repo/main-app-v10/admin-panel/ backend/
else
    cp -r temp_repo/main-app-v10/admin-panel backend/
fi

# Copier frontend
echo "Copie frontend..."
if [ -d "frontend/node_modules" ]; then
    rsync -av --exclude='.env.local' --exclude='node_modules' --exclude='.next' "temp_repo/react-user-website/StackFood React/" frontend/
else
    cp -r "temp_repo/react-user-website/StackFood React" frontend/
fi

rm -rf temp_repo

# Étape 3: Backend Laravel
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

composer install --no-dev --optimize-autoloader --no-interaction
php artisan key:generate --force
php artisan storage:link
chown -R www-data:www-data .
chmod -R 775 storage bootstrap/cache

# Étape 4: Frontend Next.js
echo "🔧 Configuration Frontend..."
cd /var/www/${PROJECT_NAME}/frontend

if [ ! -f .env.local ]; then
    cat > .env.local << 'EOF'
NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz/api/v1
NEXT_PUBLIC_SOCKET_URL=https://soso-delivery.xyz
PORT=3002
EOF
fi

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

# Étape 6: Build et PM2
echo "🚀 Build Frontend et PM2..."
cd /var/www/${PROJECT_NAME}/frontend
npm run build
pm2 delete soso-delivery-frontend 2>/dev/null || true
pm2 start npm --name "soso-delivery-frontend" -- start
pm2 save
pm2 startup

echo ""
echo "✅ INSTALLATION TERMINÉE!"
echo ""
echo "Vérifications:"
pm2 list
systemctl status nginx --no-pager | head -5

# ============================================================================
# FIN DU SETUP
# ============================================================================
```

## 📊 Après l'Installation

### 1. Configurer la Base de Données

```bash
# Créer la base de données
mysql -u root -p

# Dans MySQL:
CREATE DATABASE soso_delivery_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'soso_delivery_user'@'localhost' IDENTIFIED BY 'VOTRE_MOT_DE_PASSE_SECURISE';
GRANT ALL PRIVILEGES ON soso_delivery_db.* TO 'soso_delivery_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Mettre à jour le .env
cd /var/www/soso-delivery/backend
nano .env
# Modifier DB_PASSWORD avec le mot de passe créé

# Exécuter les migrations
php artisan migrate --force
```

### 2. Vérifier que Tout Fonctionne

```bash
# Vérifier PM2
pm2 list
pm2 logs soso-delivery-frontend --lines 20

# Vérifier Nginx
systemctl status nginx
nginx -t

# Tester l'API localement
curl http://localhost/api/v1/config

# Vérifier les logs
tail -f /var/log/nginx/soso-delivery-error.log
```

### 3. Installer SSL (après configuration DNS)

```bash
# Installer certbot si pas déjà fait
apt install certbot python3-certbot-nginx -y

# Obtenir le certificat SSL
certbot --nginx -d soso-delivery.xyz -d www.soso-delivery.xyz

# Tester le renouvellement automatique
certbot renew --dry-run
```

## 🔄 Commandes de Maintenance

### Redémarrer les Services

```bash
# Redémarrer Backend
systemctl reload php8.1-fpm

# Redémarrer Frontend
pm2 restart soso-delivery-frontend

# Redémarrer Nginx
systemctl reload nginx
```

### Mettre à Jour le Code

```bash
cd /var/www/soso-delivery

# Backend
cd backend
git pull  # Si c'est un repo git
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Frontend
cd ../frontend
git pull  # Si c'est un repo git
npm ci
npm run build
pm2 restart soso-delivery-frontend
```

### Vérifier les Logs

```bash
# Logs Backend Laravel
tail -f /var/www/soso-delivery/backend/storage/logs/laravel.log

# Logs Frontend PM2
pm2 logs soso-delivery-frontend

# Logs Nginx
tail -f /var/log/nginx/soso-delivery-access.log
tail -f /var/log/nginx/soso-delivery-error.log
```

## 🆘 Dépannage

### Erreur 502 Bad Gateway

```bash
# Vérifier PHP-FPM
systemctl status php8.1-fpm
systemctl restart php8.1-fpm

# Vérifier PM2
pm2 status
pm2 restart soso-delivery-frontend

# Vérifier Nginx
nginx -t
systemctl restart nginx
```

### Frontend ne démarre pas

```bash
cd /var/www/soso-delivery/frontend

# Vérifier les logs
pm2 logs soso-delivery-frontend

# Rebuild
npm run build

# Redémarrer
pm2 restart soso-delivery-frontend
```

### Base de données inaccessible

```bash
# Vérifier MySQL
systemctl status mysql

# Tester la connexion
mysql -u soso_delivery_user -p soso_delivery_db

# Vérifier .env
cd /var/www/soso-delivery/backend
cat .env | grep DB_
```

## 📋 Checklist Finale

- [ ] Structure `/var/www/soso-delivery/` créée
- [ ] Code cloné depuis GitHub
- [ ] Backend configuré (Composer, .env, migrations)
- [ ] Frontend configuré (NPM, .env.local, build)
- [ ] Base de données créée et migrée
- [ ] Nginx configuré et actif
- [ ] PM2 tourne sur port 3002
- [ ] SSL installé (après DNS)
- [ ] DNS configuré (A record → 77.42.34.90)
- [ ] Site accessible: https://soso-delivery.xyz
- [ ] Admin accessible: https://soso-delivery.xyz/admin
- [ ] API fonctionne: https://soso-delivery.xyz/api/v1/config

---

**Note**: Copie-colle le grand bloc de commandes ci-dessus directement dans ton terminal SSH connecté au serveur. Tout sera configuré automatiquement !
