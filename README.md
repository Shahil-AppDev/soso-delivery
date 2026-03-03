# StackFood - Multi-Restaurant Food Delivery Platform

## 🚀 Project Overview

StackFood is a comprehensive multi-restaurant online food ordering and delivery platform consisting of:

- **Backend (Laravel 10)**: Admin panel and API server
- **Frontend (Next.js 15)**: Customer-facing web application
- **Mobile Apps (Flutter)**: Delivery man and Restaurant apps (not included in web deployment)

## 📋 Architecture

```
soso-delivery.xyz
├── Backend (Laravel) - /var/www/soso-delivery/backend
│   ├── Admin Panel: https://soso-delivery.xyz/admin
│   └── API: https://soso-delivery.xyz/api/v1
└── Frontend (Next.js) - /var/www/soso-delivery/frontend
    └── Customer App: https://soso-delivery.xyz

Note: Le serveur héberge plusieurs projets.
Soso Delivery est isolé dans /var/www/soso-delivery/
```

## 🛠️ Technology Stack

### Backend
- **Framework**: Laravel 10
- **PHP**: 8.1+
- **Database**: MySQL 8.0
- **Payment Gateways**: Stripe, PayPal, Razorpay, Mercado Pago, Xendit, Paystack
- **SMS**: Twilio
- **Storage**: AWS S3 / Local
- **Real-time**: Laravel WebSockets
- **Authentication**: Laravel Passport (OAuth2)

### Frontend
- **Framework**: Next.js 15
- **React**: 18.2
- **UI Library**: Material-UI (MUI) v5
- **State Management**: Redux Toolkit
- **Maps**: Google Maps API
- **Authentication**: Firebase, Social Login (Google, Facebook, Apple)
- **Payment**: Stripe integration

## 📦 Deployment

### Prerequisites
- Hetzner VPS (77.42.34.90)
- Domain: soso-delivery.xyz
- SSH access to VPS
- GitHub account for repository

### Quick Deployment

1. **Initial Setup** (One-time)
```bash
# Make deployment script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

2. **Automated Deployment via GitHub Actions**
   - Push to `main` branch triggers automatic deployment
   - Requires SSH private key in GitHub Secrets (`SSH_PRIVATE_KEY`)

### Manual Deployment Steps

#### 1. DNS Configuration
Point your domain to VPS:
```
A Record: @ → 77.42.34.90
A Record: www → 77.42.34.90
```

#### 2. VPS Initial Setup
```bash
ssh root@77.42.34.90

# Update system
apt update && apt upgrade -y

# Install dependencies
apt install -y nginx mysql-server php8.1-fpm php8.1-mysql php8.1-xml \
  php8.1-mbstring php8.1-curl php8.1-zip php8.1-gd php8.1-bcmath \
  php8.1-intl php8.1-soap git curl unzip nodejs npm certbot \
  python3-certbot-nginx

# Install Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PM2
npm install -g pm2
```

#### 3. Database Setup
```bash
mysql -u root -p

CREATE DATABASE stackfood_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'stackfood_user'@'localhost' IDENTIFIED BY 'YOUR_SECURE_PASSWORD';
GRANT ALL PRIVILEGES ON stackfood_db.* TO 'stackfood_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### 4. Backend Deployment
```bash
cd /var/www/soso-delivery/backend

# Clone repository
git clone YOUR_REPO_URL .

# Install dependencies
composer install --no-dev --optimize-autoloader

# Configure environment
cp .env.example .env
nano .env  # Update database credentials and app settings

# Generate key and migrate
php artisan key:generate
php artisan migrate --force
php artisan storage:link

# Set permissions
chown -R www-data:www-data .
chmod -R 775 storage bootstrap/cache
```

#### 5. Frontend Deployment
```bash
cd /var/www/soso-delivery/frontend

# Install dependencies
npm ci

# Create environment file
cat > .env.local << EOF
NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz/api/v1
NEXT_PUBLIC_SOCKET_URL=https://soso-delivery.xyz
NEXT_PUBLIC_GOOGLE_MAP_KEY=YOUR_GOOGLE_MAP_KEY
EOF

# Build and start
npm run build
pm2 start npm --name "soso-delivery-frontend" -- start
pm2 startup
pm2 save
```

#### 6. SSL Certificate
```bash
certbot --nginx -d soso-delivery.xyz -d www.soso-delivery.xyz
```

## 🔧 Configuration

### Backend Environment Variables
Key variables in `/var/www/soso-delivery/backend/.env`:

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
DB_PASSWORD=your_password

# Payment Gateways
STRIPE_API_KEY=
PAYPAL_CLIENT_ID=
RAZORPAY_KEY=

# SMS
TWILIO_SID=
TWILIO_TOKEN=

# Storage
FILESYSTEM_DRIVER=public
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=
AWS_BUCKET=
```

### Frontend Environment Variables
File: `/var/www/soso-delivery/frontend/.env.local`:

```env
NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz/api/v1
NEXT_PUBLIC_SOCKET_URL=https://soso-delivery.xyz
NEXT_PUBLIC_GOOGLE_MAP_KEY=your_google_map_key
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
```

## 🔄 GitHub Actions Workflow

The repository includes automated deployment via GitHub Actions:

**Workflow File**: `.github/workflows/deploy.yml`

**Setup**:
1. Generate SSH key pair on your local machine:
   ```bash
   ssh-keygen -t ed25519 -C "github-actions"
   ```

2. Add public key to VPS:
   ```bash
   ssh root@77.42.34.90
   echo "YOUR_PUBLIC_KEY" >> ~/.ssh/authorized_keys
   ```

3. Add private key to GitHub:
   - Go to: Repository → Settings → Secrets and variables → Actions
   - Create secret: `SSH_PRIVATE_KEY` with your private key content

**Trigger Deployment**:
```bash
git add .
git commit -m "Deploy updates"
git push origin main
```

## 📱 Mobile Apps (Flutter)

Mobile apps are **not deployed to the web server**. They need to be built separately:

### Delivery Man App
- Location: `/delivery-man-app-v10/Delivery man app/`
- Build for Android/iOS using Flutter
- Configure API endpoint to `https://soso-delivery.xyz/api/v1`

### Restaurant App
- Location: `/restaurant-app-v10/Restaurant app/`
- Build for Android/iOS using Flutter
- Configure API endpoint to `https://soso-delivery.xyz/api/v1`

## 🔐 Security Checklist

- [ ] Change default database passwords
- [ ] Configure firewall (UFW)
- [ ] Enable SSL/TLS (Let's Encrypt)
- [ ] Set `APP_DEBUG=false` in production
- [ ] Configure CORS properly
- [ ] Set up regular database backups
- [ ] Configure fail2ban for SSH protection
- [ ] Keep all dependencies updated

## 🚦 Post-Deployment

### 1. Access Admin Panel
```
URL: https://soso-delivery.xyz/admin
Default credentials: Check Laravel seeder or create manually
```

### 2. Configure Settings
- Business settings
- Payment gateways
- SMS gateway
- Email configuration
- Google Maps API
- Firebase for push notifications

### 3. Test Functionality
- User registration/login
- Restaurant listing
- Order placement
- Payment processing
- Real-time notifications

## 📊 Monitoring & Maintenance

### Check Application Status
```bash
# Backend
cd /var/www/soso-delivery.xyz/backend
php artisan queue:work  # If using queues

# Frontend
pm2 status
pm2 logs soso-delivery-frontend

# Nginx
sudo systemctl status nginx
sudo nginx -t

# Database
sudo systemctl status mysql
```

### Update Application
```bash
# Pull latest changes
cd /var/www/soso-delivery.xyz/backend
git pull origin main
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache

cd /var/www/soso-delivery.xyz/frontend
git pull origin main
npm ci
npm run build
pm2 restart soso-delivery-frontend
```

### Backup Database
```bash
# Create backup
mysqldump -u stackfood_user -p stackfood_db > backup_$(date +%Y%m%d).sql

# Restore backup
mysql -u stackfood_user -p stackfood_db < backup_20260303.sql
```

## 📞 Support & Documentation

- **Official Documentation**: https://stackfood.app/documentation/
- **Support**: https://support.6amtech.com/
- **Community**: https://www.facebook.com/groups/450944516931102

## 📝 Migration from Namecheap cPanel

### Export from cPanel
1. **Database**: Export via phpMyAdmin
2. **Files**: Download via FTP/File Manager
3. **Environment**: Note all configuration settings

### Import to Hetzner VPS
1. **Database**: Import SQL file to MySQL
2. **Files**: Upload via Git or SCP
3. **Configuration**: Update `.env` files with new settings
4. **DNS**: Update nameservers or A records

### Checklist
- [ ] Export database from cPanel
- [ ] Download all application files
- [ ] Note environment variables
- [ ] Update DNS records
- [ ] Import database to VPS
- [ ] Deploy application files
- [ ] Configure environment
- [ ] Test thoroughly
- [ ] Update mobile app API endpoints

## 🎯 Production Optimization

### Laravel Optimization
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize
```

### Next.js Optimization
- Already optimized during build (`npm run build`)
- Uses production mode with PM2
- Static assets cached by Nginx

### Nginx Caching
```nginx
# Add to Nginx config for static assets
location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## 📄 License

This is a commercial product. Refer to your purchase license for terms.

---

**Deployed by**: Business Services IDF (Shahil AppDev)  
**Date**: March 2026  
**Version**: 8.4 (Backend) / 3.4 (Frontend)
