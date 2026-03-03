# Configuration Multi-Projets sur Hetzner VPS

## 🏗️ Architecture Serveur Multi-Projets

Le serveur Hetzner (77.42.34.90) héberge **plusieurs projets**. Voici la structure organisée :

```
/var/www/
├── projet-1/
│   ├── backend/
│   ├── frontend/
│   └── logs/
├── projet-2/
│   ├── backend/
│   ├── frontend/
│   └── logs/
└── soso-delivery/          ← NOUVEAU PROJET
    ├── backend/            ← Laravel Admin + API
    ├── frontend/           ← Next.js Customer App
    └── logs/               ← Logs spécifiques au projet
```

## 📁 Structure du Projet Soso Delivery

```
/var/www/soso-delivery/
├── backend/
│   ├── app/
│   ├── config/
│   ├── database/
│   ├── public/            ← Document root Nginx
│   ├── storage/
│   │   ├── app/
│   │   │   └── public/   ← Fichiers uploadés
│   │   └── logs/
│   ├── .env              ← Configuration production
│   └── composer.json
├── frontend/
│   ├── pages/
│   ├── src/
│   ├── public/
│   ├── .next/            ← Build Next.js
│   ├── .env.local        ← Configuration frontend
│   └── package.json
└── logs/
    ├── deployment.log    ← Logs de déploiement
    └── backup.log        ← Logs de backup
```

## 🌐 Configuration Nginx Multi-Projets

### Fichier: `/etc/nginx/sites-available/soso-delivery`

Le projet Soso Delivery a sa propre configuration Nginx :

```nginx
# Domaine dédié: soso-delivery.xyz
server {
    listen 80;
    server_name soso-delivery.xyz www.soso-delivery.xyz;
    root /var/www/soso-delivery/backend/public;
    
    # Routes API/Admin → Laravel
    location /api { ... }
    location /admin { ... }
    
    # Frontend → Next.js (PM2 sur port 3000)
    location / {
        proxy_pass http://localhost:3000;
    }
}
```

### Gestion Multi-Ports pour Plusieurs Projets Next.js

Si vous avez plusieurs projets Next.js, chaque projet utilise un port différent :

```
Projet 1 Frontend → PM2 sur port 3000
Projet 2 Frontend → PM2 sur port 3001
Soso Delivery Frontend → PM2 sur port 3002  ← À CONFIGURER
```

## 🔧 Configuration Spécifique Soso Delivery

### 1. Port PM2 pour le Frontend

Modifier le script de démarrage pour utiliser le port 3002 :

**Fichier: `/var/www/soso-delivery/frontend/package.json`**
```json
{
  "scripts": {
    "dev": "next dev -p 3002",
    "build": "next build",
    "start": "next start -p 3002"
  }
}
```

**Commande PM2:**
```bash
cd /var/www/soso-delivery/frontend
pm2 start npm --name "soso-delivery-frontend" -- start
pm2 save
```

### 2. Base de Données Dédiée

Chaque projet a sa propre base de données :

```sql
-- Base de données Soso Delivery
CREATE DATABASE soso_delivery_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'soso_delivery_user'@'localhost' IDENTIFIED BY 'STRONG_PASSWORD';
GRANT ALL PRIVILEGES ON soso_delivery_db.* TO 'soso_delivery_user'@'localhost';
FLUSH PRIVILEGES;
```

### 3. Variables d'Environnement Backend

**Fichier: `/var/www/soso-delivery/backend/.env`**
```env
APP_NAME="Soso Delivery"
APP_URL=https://soso-delivery.xyz

DB_DATABASE=soso_delivery_db
DB_USERNAME=soso_delivery_user
DB_PASSWORD=YOUR_SECURE_PASSWORD

# Logs spécifiques
LOG_CHANNEL=daily
```

### 4. Variables d'Environnement Frontend

**Fichier: `/var/www/soso-delivery/frontend/.env.local`**
```env
NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz/api/v1
NEXT_PUBLIC_SOCKET_URL=https://soso-delivery.xyz
PORT=3002
```

## 🚀 Déploiement du Projet Soso Delivery

### Étape 1: Créer la Structure sur le VPS

```bash
ssh root@77.42.34.90

# Créer la structure du projet
mkdir -p /var/www/soso-delivery/{backend,frontend,logs}
chown -R www-data:www-data /var/www/soso-delivery
```

### Étape 2: Cloner le Code

```bash
cd /var/www/soso-delivery

# Cloner le backend
git clone https://github.com/YOUR_USERNAME/soso-delivery-stackfood.git temp
cp -r temp/main-app-v10/admin-panel/* backend/
cp -r temp/react-user-website/StackFood\ React/* frontend/
rm -rf temp
```

### Étape 3: Configurer le Backend

```bash
cd /var/www/soso-delivery/backend

# Installer les dépendances
composer install --no-dev --optimize-autoloader

# Configurer l'environnement
cp .env.example .env
nano .env  # Éditer avec les bonnes valeurs

# Générer la clé et migrer
php artisan key:generate
php artisan migrate --force
php artisan storage:link

# Permissions
chown -R www-data:www-data .
chmod -R 775 storage bootstrap/cache
```

### Étape 4: Configurer le Frontend

```bash
cd /var/www/soso-delivery/frontend

# Modifier package.json pour utiliser le port 3002
nano package.json
# Changer: "start": "next start -p 3002"

# Créer .env.local
cat > .env.local << EOF
NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz/api/v1
NEXT_PUBLIC_SOCKET_URL=https://soso-delivery.xyz
PORT=3002
EOF

# Installer et builder
npm ci
npm run build

# Démarrer avec PM2
pm2 start npm --name "soso-delivery-frontend" -- start
pm2 save
```

### Étape 5: Configurer Nginx

```bash
# Copier la configuration
nano /etc/nginx/sites-available/soso-delivery
# Coller le contenu de nginx-config.conf

# Activer le site
ln -s /etc/nginx/sites-available/soso-delivery /etc/nginx/sites-enabled/

# Tester et recharger
nginx -t
systemctl reload nginx
```

### Étape 6: SSL Certificate

```bash
certbot --nginx -d soso-delivery.xyz -d www.soso-delivery.xyz
```

## 🔄 GitHub Actions pour Déploiement Automatique

Le workflow GitHub Actions déploie uniquement le projet Soso Delivery :

```yaml
# .github/workflows/deploy.yml
- name: Deploy Backend
  run: |
    ssh root@77.42.34.90 << 'ENDSSH'
      cd /var/www/soso-delivery/backend
      git pull origin main
      composer install --no-dev --optimize-autoloader
      php artisan migrate --force
      php artisan config:cache
    ENDSSH

- name: Deploy Frontend
  run: |
    ssh root@77.42.34.90 << 'ENDSSH'
      cd /var/www/soso-delivery/frontend
      git pull origin main
      npm ci
      npm run build
      pm2 restart soso-delivery-frontend
    ENDSSH
```

## 📊 Gestion des Ressources

### Vérifier les Projets Actifs

```bash
# Lister tous les projets
ls -la /var/www/

# Vérifier les processus PM2
pm2 list

# Vérifier les sites Nginx
ls -la /etc/nginx/sites-enabled/

# Vérifier les bases de données
mysql -u root -p -e "SHOW DATABASES;"
```

### Monitoring Spécifique Soso Delivery

```bash
# Logs backend
tail -f /var/www/soso-delivery/backend/storage/logs/laravel.log

# Logs frontend
pm2 logs soso-delivery-frontend

# Logs Nginx
tail -f /var/log/nginx/soso-delivery-access.log
tail -f /var/log/nginx/soso-delivery-error.log
```

## 🔐 Isolation et Sécurité

### Utilisateurs Dédiés (Optionnel mais Recommandé)

Pour une meilleure isolation, créer un utilisateur système par projet :

```bash
# Créer utilisateur pour Soso Delivery
useradd -r -s /bin/bash -d /var/www/soso-delivery soso-delivery

# Changer ownership
chown -R soso-delivery:www-data /var/www/soso-delivery

# Ajuster permissions
chmod -R 750 /var/www/soso-delivery
```

### Firewall - Ports Internes

Les ports PM2 (3000, 3001, 3002, etc.) ne doivent **PAS** être exposés publiquement :

```bash
# Vérifier que seuls 80 et 443 sont ouverts
ufw status

# Les ports 3000+ sont accessibles uniquement en localhost
# Nginx fait le proxy
```

## 📦 Backup Spécifique au Projet

### Script de Backup Soso Delivery

**Fichier: `/root/backup-soso-delivery.sh`**
```bash
#!/bin/bash
BACKUP_DIR="/root/backups/soso-delivery"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Database
mysqldump -u soso_delivery_user -p'PASSWORD' soso_delivery_db | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Files
tar -czf $BACKUP_DIR/files_$DATE.tar.gz /var/www/soso-delivery/backend/storage/app/public

# Keep 7 days
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Backup Soso Delivery completed: $DATE" >> /var/www/soso-delivery/logs/backup.log
```

```bash
chmod +x /root/backup-soso-delivery.sh

# Crontab (daily 3 AM)
crontab -e
# Ajouter: 0 3 * * * /root/backup-soso-delivery.sh
```

## 🎯 Checklist Déploiement Multi-Projets

- [ ] Structure `/var/www/soso-delivery/` créée
- [ ] Port PM2 unique assigné (3002)
- [ ] Base de données dédiée créée
- [ ] Configuration Nginx séparée
- [ ] Site Nginx activé
- [ ] SSL configuré pour le domaine
- [ ] PM2 process nommé correctement
- [ ] Logs isolés par projet
- [ ] Backup script configuré
- [ ] GitHub Actions pointe vers le bon dossier
- [ ] Variables d'environnement correctes
- [ ] Permissions correctes (www-data)

## 🔄 Commandes Utiles

### Redémarrer uniquement Soso Delivery

```bash
# Backend
sudo systemctl reload php8.1-fpm

# Frontend
pm2 restart soso-delivery-frontend

# Nginx (seulement si config modifiée)
sudo nginx -t && sudo systemctl reload nginx
```

### Vérifier le Statut

```bash
# Processus PM2
pm2 show soso-delivery-frontend

# Connexion base de données
mysql -u soso_delivery_user -p soso_delivery_db -e "SELECT COUNT(*) FROM users;"

# Test API
curl https://soso-delivery.xyz/api/v1/config
```

## 📝 Notes Importantes

1. **Isolation**: Chaque projet est complètement isolé (code, DB, logs)
2. **Ports**: Assigner des ports uniques pour chaque frontend Next.js
3. **Domaines**: Chaque projet peut avoir son propre domaine
4. **Resources**: Surveiller l'utilisation CPU/RAM avec plusieurs projets
5. **Backups**: Backup séparé par projet pour faciliter la restauration

---

**Configuration pour**: Projet Soso Delivery sur serveur multi-projets  
**Serveur**: Hetzner VPS 77.42.34.90  
**Domaine**: soso-delivery.xyz  
**Chemin**: /var/www/soso-delivery/
