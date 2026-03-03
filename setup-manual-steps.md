# 🔧 Setup Manuel - Soso Delivery sur Serveur

## Étape par Étape avec le Mot de Passe

**Mot de passe VPS**: `ntp4vAsPJUqk` (à changer après)

---

## 🔑 Étape 1: Créer et Installer la Clé SSH

### Sur ton ordinateur (PowerShell ou Git Bash):

```bash
cd "c:/Users/DarkNode/Desktop/Soso New"

# Générer la clé SSH
ssh-keygen -t ed25519 -f soso-deployment-key

# Appuyer sur Entrée 3 fois (pas de passphrase)
```

### Copier la clé sur le serveur:

```bash
# Afficher la clé publique
type soso-deployment-key.pub

# Se connecter au serveur
ssh root@77.42.34.90
# Mot de passe: ntp4vAsPJUqk

# Sur le serveur, ajouter la clé:
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
# Coller la clé publique
# Sauvegarder: Ctrl+X, Y, Enter

chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

# Déconnexion
exit
```

### Tester la connexion SSH sans mot de passe:

```bash
ssh -i soso-deployment-key root@77.42.34.90
# Devrait se connecter sans demander le mot de passe
```

---

## 🚀 Étape 2: Setup du Projet

### Se connecter au serveur:

```bash
ssh -i soso-deployment-key root@77.42.34.90
```

### Exécuter le setup (copier-coller tout ce bloc):

```bash
# ============================================================================
# SETUP SOSO DELIVERY
# ============================================================================

PROJECT_NAME="soso-delivery"
DOMAIN="soso-delivery.xyz"
REPO_URL="https://github.com/Shahil-AppDev/soso-delivery.git"

# Créer la structure
echo "📁 Création structure..."
mkdir -p /var/www/${PROJECT_NAME}/{backend,frontend,logs}

# Cloner le code
echo "📥 Clonage repository..."
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

# Backend
echo "🔧 Backend..."
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

# Frontend
echo "🔧 Frontend..."
cd /var/www/${PROJECT_NAME}/frontend

if [ ! -f .env.local ]; then
    cat > .env.local << 'EOF'
NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz/api/v1
NEXT_PUBLIC_SOCKET_URL=https://soso-delivery.xyz
PORT=3002
EOF
fi

npm ci

# Nginx
echo "🌐 Nginx..."
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

# PM2
echo "🚀 PM2..."
cd /var/www/${PROJECT_NAME}/frontend
npm run build
pm2 delete soso-delivery-frontend 2>/dev/null || true
pm2 start npm --name "soso-delivery-frontend" -- start
pm2 save
pm2 startup

echo ""
echo "✅ INSTALLATION TERMINÉE!"
pm2 list
systemctl status nginx --no-pager | head -5

# ============================================================================
```

---

## 🗄️ Étape 3: Configurer la Base de Données

```bash
# Toujours sur le serveur
mysql -u root -p
# Entrer le mot de passe MySQL root

# Dans MySQL:
CREATE DATABASE soso_delivery_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'soso_delivery_user'@'localhost' IDENTIFIED BY 'VotreMotDePasseSecurise123!';
GRANT ALL PRIVILEGES ON soso_delivery_db.* TO 'soso_delivery_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Mettre à jour .env
cd /var/www/soso-delivery/backend
nano .env
# Modifier: DB_PASSWORD=VotreMotDePasseSecurise123!

# Migrer la base de données
php artisan migrate --force
```

---

## 🔐 Étape 4: Ajouter la Clé SSH à GitHub

### Sur ton ordinateur:

```bash
# Afficher la clé privée
type soso-deployment-key
```

### Sur GitHub:

1. Va sur: https://github.com/Shahil-AppDev/soso-delivery/settings/secrets/actions
2. Clique **New repository secret**
3. Name: `SSH_PRIVATE_KEY`
4. Value: Colle TOUT le contenu de `soso-deployment-key` (y compris BEGIN et END)
5. Clique **Add secret**

---

## 🌐 Étape 5: Configurer le DNS

### Sur Namecheap:

1. Login → Domain List → soso-delivery.xyz → Manage
2. Advanced DNS
3. Ajouter/Modifier:
   - Type: `A Record`, Host: `@`, Value: `77.42.34.90`
   - Type: `A Record`, Host: `www`, Value: `77.42.34.90`
4. Save

Attendre 5-30 minutes pour la propagation.

---

## 🔒 Étape 6: Installer SSL

### Sur le serveur:

```bash
# Vérifier que le DNS est propagé
nslookup soso-delivery.xyz

# Installer SSL
certbot --nginx -d soso-delivery.xyz -d www.soso-delivery.xyz

# Suivre les instructions
# Email: ton-email@example.com
# Accepter les termes
# Rediriger HTTP vers HTTPS: Oui
```

---

## ✅ Étape 7: Vérifications

```bash
# Sur le serveur
pm2 list
systemctl status nginx
curl http://localhost/api/v1/config

# Sur ton ordinateur
curl https://soso-delivery.xyz/api/v1/config
```

### Tester dans le navigateur:

- Frontend: https://soso-delivery.xyz
- Admin: https://soso-delivery.xyz/admin
- API: https://soso-delivery.xyz/api/v1/config

---

## 🔐 Étape 8: Changer le Mot de Passe Root

```bash
# Sur le serveur
passwd

# Entrer le nouveau mot de passe 2 fois
# Sauvegarder ce nouveau mot de passe en lieu sûr
```

---

## 📋 Checklist Finale

- [ ] Clé SSH créée et installée
- [ ] Connexion SSH sans mot de passe fonctionne
- [ ] Projet cloné dans `/var/www/soso-delivery/`
- [ ] Backend configuré (Composer, .env)
- [ ] Frontend configuré (NPM, .env.local)
- [ ] Base de données créée et migrée
- [ ] Nginx configuré
- [ ] PM2 tourne sur port 3002
- [ ] Clé SSH ajoutée aux secrets GitHub
- [ ] DNS configuré
- [ ] SSL installé
- [ ] Site accessible en HTTPS
- [ ] Mot de passe root changé

---

**Tout est prêt ! Le site devrait être accessible sur https://soso-delivery.xyz** 🚀
