# StackFood Deployment Guide
## Migration from Namecheap cPanel to Hetzner VPS

---

## 📋 Pre-Deployment Checklist

### Information to Gather

#### From Namecheap cPanel
- [ ] Database name, username, password
- [ ] Database backup (export via phpMyAdmin)
- [ ] All uploaded files (storage/app/public)
- [ ] Environment variables (.env file)
- [ ] Email accounts (if any)
- [ ] SSL certificate (if custom, otherwise use Let's Encrypt)

#### For Hetzner VPS
- [ ] VPS IP: **77.42.34.90**
- [ ] Root password or SSH key
- [ ] Domain: **soso-delivery.xyz**

#### API Keys & Credentials
- [ ] Google Maps API key
- [ ] Firebase credentials (for push notifications)
- [ ] Stripe API keys (if using Stripe)
- [ ] PayPal credentials (if using PayPal)
- [ ] Twilio credentials (for SMS)
- [ ] Email SMTP settings
- [ ] Any other third-party service credentials

---

## 🚀 Deployment Process

### Phase 1: Preparation (Local Machine)

#### Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com) and create a new **private** repository
   - Name: `soso-delivery-stackfood`
   - Visibility: **Private**
   - Do NOT initialize with README

2. On your local machine:
```bash
cd "c:/Users/DarkNode/Desktop/Soso New"

# Initialize Git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - StackFood platform"

# Add remote
git remote add origin https://github.com/YOUR_USERNAME/soso-delivery-stackfood.git

# Push to GitHub
git branch -M main
git push -u origin main
```

#### Step 2: Generate SSH Keys for Deployment

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -f deployment-key -C "deployment-key"

# This creates:
# - deployment-key (private key) - for GitHub Secrets
# - deployment-key.pub (public key) - for VPS
```

#### Step 3: Configure GitHub Secrets

1. Go to your repository on GitHub
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secret:
   - Name: `SSH_PRIVATE_KEY`
   - Value: Copy entire content of `deployment-key` file (private key)

---

### Phase 2: VPS Initial Setup

#### Step 1: Connect to VPS

```bash
ssh root@77.42.34.90
```

#### Step 2: Update System

```bash
apt update && apt upgrade -y
```

#### Step 3: Install Required Software

```bash
# Install web server, database, PHP
apt install -y nginx mysql-server php8.1-fpm php8.1-mysql php8.1-xml \
  php8.1-mbstring php8.1-curl php8.1-zip php8.1-gd php8.1-bcmath \
  php8.1-intl php8.1-soap php8.1-redis php8.1-imagick \
  git curl unzip certbot python3-certbot-nginx

# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Install Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PM2 (Node.js process manager)
npm install -g pm2

# Verify installations
php -v
composer -V
node -v
npm -v
pm2 -v
```

#### Step 4: Configure MySQL

```bash
# Secure MySQL installation
mysql_secure_installation

# Create database and user
mysql -u root -p
```

In MySQL prompt:
```sql
CREATE DATABASE stackfood_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'stackfood_user'@'localhost' IDENTIFIED BY 'YOUR_SECURE_PASSWORD_HERE';
GRANT ALL PRIVILEGES ON stackfood_db.* TO 'stackfood_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

**⚠️ IMPORTANT**: Save the database password securely!

#### Step 5: Configure SSH for GitHub Actions

```bash
# Add public key to authorized_keys
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Copy the content of deployment-key.pub and add it:
nano ~/.ssh/authorized_keys
# Paste the public key content
# Save and exit (Ctrl+X, Y, Enter)

chmod 600 ~/.ssh/authorized_keys
```

---

### Phase 3: Application Deployment

#### Step 1: Create Project Directories

```bash
# Create project structure (projet isolé)
mkdir -p /var/www/soso-delivery/{backend,frontend,logs}
cd /var/www/soso-delivery
```

#### Step 2: Clone Repository

```bash
# Clone to temporary directory
git clone https://github.com/YOUR_USERNAME/soso-delivery-stackfood.git temp_repo

# Copy backend files
cp -r temp_repo/main-app-v10/admin-panel/* backend/

# Copy frontend files
cp -r temp_repo/react-user-website/StackFood\ React/* frontend/

# Remove temp directory
rm -rf temp_repo

# Set ownership
chown -R www-data:www-data /var/www/soso-delivery
```

#### Step 3: Configure Backend (Laravel)

```bash
cd /var/www/soso-delivery/backend

# Copy environment file
cp .env.example .env

# Edit environment file
nano .env
```

Update the following in `.env`:
```env
APP_NAME=StackFood
APP_ENV=production
APP_DEBUG=false
APP_URL=https://soso-delivery.xyz

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=stackfood_db
DB_USERNAME=stackfood_user
DB_PASSWORD=YOUR_SECURE_PASSWORD_HERE

# Add your API keys
GOOGLE_MAP_API_KEY=
STRIPE_API_KEY=
PAYPAL_CLIENT_ID=
TWILIO_SID=
TWILIO_TOKEN=

# Email settings
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@soso-delivery.xyz
MAIL_FROM_NAME="${APP_NAME}"
```

Continue backend setup:
```bash
# Install dependencies
composer install --no-dev --optimize-autoloader

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate --force

# Create storage link
php artisan storage:link

# Set permissions
chown -R www-data:www-data .
chmod -R 775 storage bootstrap/cache

# Cache configuration
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

#### Step 4: Import Database from cPanel (if migrating)

```bash
# Upload your database backup
scp database_backup.sql root@77.42.34.90:/tmp/

# On VPS, import database
mysql -u stackfood_user -p stackfood_db < /tmp/database_backup.sql

# Remove backup file
rm /tmp/database_backup.sql
```

#### Step 5: Configure Frontend (Next.js)

```bash
cd /var/www/soso-delivery/frontend

# Create environment file
nano .env.local
```

Add the following:
```env
NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz/api/v1
NEXT_PUBLIC_SOCKET_URL=https://soso-delivery.xyz
NEXT_PUBLIC_GOOGLE_MAP_KEY=YOUR_GOOGLE_MAP_KEY

# Firebase configuration
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID=
```

Build and start frontend:
```bash
# Install dependencies
npm ci

# Build Next.js application
npm run build

# Start with PM2
pm2 start npm --name "soso-delivery-frontend" -- start

# Configure PM2 to start on boot
pm2 startup
# Copy and run the command it outputs

pm2 save
```

---

### Phase 4: Web Server Configuration

#### Step 1: Configure Nginx

```bash
# Create Nginx configuration
nano /etc/nginx/sites-available/soso-delivery.xyz
```

Copy the content from `nginx-config.conf` file in the repository.

```bash
# Enable the site
ln -s /etc/nginx/sites-available/soso-delivery.xyz /etc/nginx/sites-enabled/

# Remove default site
rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Reload Nginx
systemctl reload nginx
```

#### Step 2: Configure Firewall

```bash
# Enable UFW
ufw --force enable

# Allow SSH, HTTP, HTTPS
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Reload firewall
ufw reload

# Check status
ufw status
```

---

### Phase 5: SSL Certificate

#### Step 1: Configure DNS First

Before getting SSL, ensure DNS is pointing to your VPS:

**IMPORTANT**: Le serveur héberge plusieurs projets. Soso Delivery sera dans `/var/www/soso-delivery/`

**On Namecheap**:
1. Login to Namecheap account
2. Domain List → soso-delivery.xyz → Manage**
3. **Advanced DNS** tab
4. Add/Update A Records:
   - Type: `A Record`, Host: `@`, Value: `77.42.34.90`
   - Type: `A Record`, Host: `www`, Value: `77.42.34.90`

**Wait 5-30 minutes for DNS propagation**

Verify DNS:
```bash
nslookup soso-delivery.xyz
# Should return 77.42.34.90
```

#### Step 2: Install SSL Certificate

```bash
# Get SSL certificate
certbot --nginx -d soso-delivery.xyz -d www.soso-delivery.xyz

# Follow prompts:
# - Enter email address
# - Agree to terms
# - Choose to redirect HTTP to HTTPS (option 2)

# Enable auto-renewal
systemctl enable certbot.timer
systemctl start certbot.timer

# Test renewal
certbot renew --dry-run
```

---

### Phase 6: Verification & Testing

#### Step 1: Check Services

```bash
# Check Nginx
systemctl status nginx

# Check PHP-FPM
systemctl status php8.1-fpm

# Check MySQL
systemctl status mysql

# Check PM2
pm2 status

# Check logs
pm2 logs soso-delivery-frontend --lines 50
tail -f /var/www/soso-delivery/backend/storage/logs/laravel.log
```

#### Step 2: Test Application

1. **Frontend**: Visit `https://soso-delivery.xyz`
   - Should load the customer-facing website

2. **Admin Panel**: Visit `https://soso-delivery.xyz/admin`
   - Should load the admin login page

3. **API**: Test API endpoint
   ```bash
   curl https://soso-delivery.xyz/api/v1/config
   ```

#### Step 3: Create Admin User (if needed)

```bash
cd /var/www/soso-delivery/backend
php artisan tinker
```

In Tinker:
```php
$admin = new App\Models\Admin();
$admin->name = 'Admin';
$admin->email = 'admin@soso-delivery.xyz';
$admin->password = bcrypt('your-secure-password');
$admin->save();
exit
```

---

### Phase 7: Post-Deployment Configuration

#### Step 1: Admin Panel Setup

1. Login to admin panel: `https://soso-delivery.xyz/admin`
2. Configure:
   - **Business Settings**: Name, logo, contact info
   - **Payment Gateways**: Enable and configure Stripe, PayPal, etc.
   - **SMS Gateway**: Configure Twilio
   - **Email Settings**: Verify SMTP works
   - **Map Settings**: Add Google Maps API key
   - **Firebase**: Add credentials for push notifications

#### Step 2: Test Complete Flow

1. **Customer Registration**: Register a new customer account
2. **Restaurant**: Add a test restaurant
3. **Menu**: Add food items
4. **Order**: Place a test order
5. **Payment**: Test payment processing
6. **Notifications**: Verify email/SMS notifications

---

### Phase 8: Automated Deployments

#### Step 1: Test GitHub Actions

```bash
# On your local machine
cd "c:/Users/DarkNode/Desktop/Soso New"

# Make a small change
echo "# Test" >> README.md

# Commit and push
git add .
git commit -m "Test automated deployment"
git push origin main
```

#### Step 2: Monitor Deployment

1. Go to GitHub repository
2. Click **Actions** tab
3. Watch the deployment workflow run
4. Verify deployment succeeded

---

## 🔧 Maintenance & Operations

### Daily Backups

Create backup script:
```bash
nano /root/backup-stackfood.sh
```

Add:
```bash
#!/bin/bash
BACKUP_DIR="/root/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Database backup
mysqldump -u stackfood_user -p'YOUR_PASSWORD' stackfood_db | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Files backup
tar -czf $BACKUP_DIR/files_$DATE.tar.gz /var/www/soso-delivery/backend/storage/app/public

# Keep only last 7 days
find $BACKUP_DIR -type f -mtime +7 -delete
```

Make executable and schedule:
```bash
chmod +x /root/backup-stackfood.sh

# Add to crontab (daily at 2 AM)
crontab -e
# Add: 0 2 * * * /root/backup-stackfood.sh
```

### Monitoring

```bash
# Check application logs
pm2 logs soso-delivery-frontend
tail -f /var/www/soso-delivery/backend/storage/logs/laravel.log

# Check Nginx logs
tail -f /var/log/nginx/soso-delivery-access.log
tail -f /var/log/nginx/soso-delivery-error.log

# Check system resources
htop
df -h
free -m
```

### Updates

```bash
# Backend updates
cd /var/www/soso-delivery.xyz/backend
git pull origin main
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
systemctl reload php8.1-fpm

# Frontend updates
cd /var/www/soso-delivery/frontend
git pull origin main
npm ci
npm run build
pm2 restart soso-delivery-frontend
```

---

## 🆘 Troubleshooting

### Issue: 502 Bad Gateway

```bash
# Check PHP-FPM
systemctl status php8.1-fpm
systemctl restart php8.1-fpm

# Check PM2
pm2 status
pm2 restart soso-delivery-frontend
```

### Issue: Database Connection Error

```bash
# Verify database credentials
cd /var/www/soso-delivery.xyz/backend
cat .env | grep DB_

# Test database connection
mysql -u stackfood_user -p stackfood_db
```

### Issue: SSL Certificate Error

```bash
# Renew certificate
certbot renew --force-renewal

# Check certificate status
certbot certificates
```

### Issue: Frontend Not Loading

```bash
# Check PM2 logs
pm2 logs soso-delivery-frontend

# Restart PM2
pm2 restart soso-delivery-frontend

# Rebuild if needed
cd /var/www/soso-delivery/frontend
npm run build
pm2 restart soso-delivery-frontend
```

---

## 📞 Support

- **StackFood Documentation**: https://stackfood.app/documentation/
- **Support**: https://support.6amtech.com/
- **Community**: Facebook Group

---

**Deployment completed by**: Business Services IDF (Shahil AppDev)  
**Date**: March 2026  
**Version**: StackFood v8.4
