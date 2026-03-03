# 🎯 Prochaines Étapes - Déploiement Soso Delivery

## ✅ Déjà Fait

- ✅ Code poussé sur GitHub: https://github.com/Shahil-AppDev/soso-delivery
- ✅ Architecture multi-projets configurée
- ✅ Scripts de déploiement prêts
- ✅ GitHub Actions workflow créé
- ✅ Documentation complète

## 🔑 Étape 1: Générer les Clés SSH (À FAIRE MAINTENANT)

```bash
# Dans PowerShell ou Git Bash
cd "c:/Users/DarkNode/Desktop/Soso New"

# Générer la paire de clés
ssh-keygen -t ed25519 -f deployment-key -N "" -C "github-soso-delivery"
```

Cela crée 2 fichiers:
- `deployment-key` (privée) → pour GitHub Secret
- `deployment-key.pub` (publique) → pour VPS

## 🔐 Étape 2: Ajouter la Clé Publique au VPS

```bash
# Afficher la clé publique
type deployment-key.pub

# Copier le contenu et se connecter au VPS
ssh root@77.42.34.90

# Sur le VPS, ajouter la clé
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
# Coller la clé publique à la fin du fichier
# Sauvegarder: Ctrl+X, Y, Enter

# Définir les permissions
chmod 600 ~/.ssh/authorized_keys
exit
```

## 🔒 Étape 3: Ajouter le Secret GitHub

1. Va sur: https://github.com/Shahil-AppDev/soso-delivery/settings/secrets/actions

2. Clique sur **New repository secret**

3. Configure:
   - **Name**: `SSH_PRIVATE_KEY`
   - **Value**: Copie TOUT le contenu de `deployment-key` (clé privée)
   
   ```bash
   # Pour afficher la clé privée
   type deployment-key
   ```

4. Clique sur **Add secret**

## 🚀 Étape 4: Lancer le Déploiement Initial

### Option A: Déploiement Automatique via Script

```bash
# Rendre le script exécutable (si sur Linux/Mac/WSL)
chmod +x deploy.sh

# Lancer le déploiement
./deploy.sh
```

Le script va:
- Installer tous les packages nécessaires (Nginx, PHP, MySQL, Node.js)
- Créer la base de données `soso_delivery_db`
- Déployer backend et frontend dans `/var/www/soso-delivery/`
- Configurer Nginx
- Installer SSL avec Let's Encrypt
- Démarrer les services

### Option B: Déploiement Manuel (Recommandé pour première fois)

Suis le guide complet: `DEPLOYMENT_GUIDE.md`

**Commandes essentielles:**

```bash
# Se connecter au VPS
ssh root@77.42.34.90

# Créer la structure du projet
mkdir -p /var/www/soso-delivery/{backend,frontend,logs}

# Cloner le code
cd /var/www/soso-delivery
git clone https://github.com/Shahil-AppDev/soso-delivery.git temp
cp -r temp/main-app-v10/admin-panel/* backend/
cp -r temp/react-user-website/StackFood\ React/* frontend/
rm -rf temp

# Configurer le backend
cd backend
composer install --no-dev --optimize-autoloader
cp .env.example .env
nano .env  # Configurer DB et API keys
php artisan key:generate
php artisan migrate --force
php artisan storage:link
chown -R www-data:www-data .
chmod -R 775 storage bootstrap/cache

# Configurer le frontend
cd ../frontend
npm ci
nano .env.local  # Ajouter les variables d'environnement
npm run build
pm2 start npm --name "soso-delivery-frontend" -- start
pm2 save

# Configurer Nginx
nano /etc/nginx/sites-available/soso-delivery
# Copier le contenu de nginx-config.conf
ln -s /etc/nginx/sites-available/soso-delivery /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx

# Installer SSL
certbot --nginx -d soso-delivery.xyz -d www.soso-delivery.xyz
```

## 🌐 Étape 5: Configurer le DNS

**Sur Namecheap:**

1. Login → Domain List → soso-delivery.xyz → Manage
2. Advanced DNS
3. Ajouter/Modifier les A Records:
   - Host: `@` → Value: `77.42.34.90`
   - Host: `www` → Value: `77.42.34.90`
4. Sauvegarder

**Attendre 5-30 minutes pour la propagation DNS**

Vérifier:
```bash
nslookup soso-delivery.xyz
```

## ✅ Étape 6: Vérification Post-Déploiement

### Tester les URLs

1. **Frontend**: https://soso-delivery.xyz
2. **Admin Panel**: https://soso-delivery.xyz/admin
3. **API**: https://soso-delivery.xyz/api/v1/config

### Vérifier les Services

```bash
ssh root@77.42.34.90

# Vérifier la structure
ls -la /var/www/soso-delivery/

# Vérifier PM2
pm2 list
pm2 logs soso-delivery-frontend

# Vérifier Nginx
systemctl status nginx
nginx -t

# Vérifier PHP-FPM
systemctl status php8.1-fpm

# Vérifier MySQL
systemctl status mysql
mysql -u root -p -e "SHOW DATABASES;"

# Vérifier les logs
tail -f /var/log/nginx/soso-delivery-error.log
tail -f /var/www/soso-delivery/backend/storage/logs/laravel.log
```

## 🔧 Étape 7: Configuration Initiale

### Backend (.env)

Variables importantes à configurer:

```env
APP_URL=https://soso-delivery.xyz
DB_DATABASE=soso_delivery_db
DB_USERNAME=soso_delivery_user
DB_PASSWORD=VOTRE_MOT_DE_PASSE

# API Keys
GOOGLE_MAP_API_KEY=
STRIPE_API_KEY=
PAYPAL_CLIENT_ID=
TWILIO_SID=
TWILIO_TOKEN=

# Email
MAIL_HOST=smtp.gmail.com
MAIL_USERNAME=
MAIL_PASSWORD=
```

### Frontend (.env.local)

```env
NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz/api/v1
NEXT_PUBLIC_SOCKET_URL=https://soso-delivery.xyz
NEXT_PUBLIC_GOOGLE_MAP_KEY=
NEXT_PUBLIC_FIREBASE_API_KEY=
```

## 🧪 Étape 8: Tester le Workflow GitHub Actions

```bash
# Faire un petit changement
cd "c:/Users/DarkNode/Desktop/Soso New"
echo "# Deployment test" >> README.md

# Commiter et pousser
git add README.md
git commit -m "Test: GitHub Actions automatic deployment"
git push origin main
```

Ensuite:
1. Va sur: https://github.com/Shahil-AppDev/soso-delivery/actions
2. Regarde le workflow "Deploy to Hetzner VPS" s'exécuter
3. Vérifie que le déploiement se termine avec succès

## 📊 Checklist Finale

- [ ] Clés SSH générées
- [ ] Clé publique ajoutée au VPS
- [ ] Secret GitHub `SSH_PRIVATE_KEY` configuré
- [ ] Déploiement initial effectué
- [ ] DNS configuré et propagé
- [ ] SSL installé (HTTPS fonctionne)
- [ ] Frontend accessible
- [ ] Admin panel accessible
- [ ] API répond correctement
- [ ] PM2 tourne sur port 3002
- [ ] Base de données créée et migrée
- [ ] Variables d'environnement configurées
- [ ] GitHub Actions testé et fonctionnel
- [ ] Backups configurés

## 🆘 En Cas de Problème

### Erreur 502 Bad Gateway
```bash
systemctl restart php8.1-fpm
pm2 restart soso-delivery-frontend
systemctl reload nginx
```

### Erreur Base de Données
```bash
cd /var/www/soso-delivery/backend
cat .env | grep DB_
mysql -u soso_delivery_user -p soso_delivery_db
```

### Frontend ne charge pas
```bash
pm2 logs soso-delivery-frontend
cd /var/www/soso-delivery/frontend
npm run build
pm2 restart soso-delivery-frontend
```

## 📚 Documentation de Référence

- **Guide Complet**: `DEPLOYMENT_GUIDE.md`
- **Multi-Projets**: `MULTI_PROJECT_SETUP.md`
- **Migration**: `MIGRATION_CHECKLIST.md`
- **Résumé**: `DEPLOYMENT_SUMMARY.md`

## 🎯 Ordre Recommandé

1. ✅ Générer clés SSH
2. ✅ Configurer VPS avec clé publique
3. ✅ Ajouter secret GitHub
4. ✅ Configurer DNS (peut se faire en parallèle)
5. ✅ Lancer déploiement initial
6. ✅ Vérifier services
7. ✅ Configurer variables d'environnement
8. ✅ Tester l'application
9. ✅ Tester GitHub Actions

---

**Repo GitHub**: https://github.com/Shahil-AppDev/soso-delivery  
**VPS**: 77.42.34.90  
**Domaine**: soso-delivery.xyz  
**Projet**: /var/www/soso-delivery/

**Commence par générer les clés SSH et suis les étapes dans l'ordre !**
