---
description: Deploy StackFood to Hetzner VPS (soso-delivery.xyz)
---

# StackFood Deployment Workflow

This workflow guides you through deploying the StackFood multi-restaurant platform to Hetzner VPS.

## Prerequisites

1. **VPS Access**: SSH access to 77.42.34.90
2. **Domain**: soso-delivery.xyz configured
3. **GitHub**: Repository created and code pushed
4. **Credentials**: Database passwords, API keys ready

## Deployment Steps

### 1. Prepare Local Repository

```bash
cd "c:/Users/DarkNode/Desktop/Soso New"

# Initialize Git (if not done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - StackFood v8.4"
```

### 2. Create GitHub Repository

// turbo
```bash
# Create private repository on GitHub
# Repository name: soso-delivery-stackfood
```

**Manual Steps**:
- Go to GitHub.com
- Click "New Repository"
- Name: `soso-delivery-stackfood`
- Visibility: **Private**
- Do NOT initialize with README (we have one)
- Create repository

### 3. Push to GitHub

```bash
# Add remote
git remote add origin https://github.com/YOUR_USERNAME/soso-delivery-stackfood.git

# Push code
git branch -M main
git push -u origin main
```

### 4. Generate SSH Keys for GitHub Actions

// turbo
```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -f github-actions-key -C "github-actions-deploy"
```

This creates:
- `github-actions-key` (private key)
- `github-actions-key.pub` (public key)

### 5. Configure VPS SSH Access

```bash
# Copy public key to VPS
ssh root@77.42.34.90 "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
scp github-actions-key.pub root@77.42.34.90:~/.ssh/github-actions.pub
ssh root@77.42.34.90 "cat ~/.ssh/github-actions.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

### 6. Add GitHub Secret

**Manual Steps**:
1. Go to: `https://github.com/YOUR_USERNAME/soso-delivery-stackfood/settings/secrets/actions`
2. Click "New repository secret"
3. Name: `SSH_PRIVATE_KEY`
4. Value: Copy entire content of `github-actions-key` file
5. Click "Add secret"

### 7. Run Initial Deployment Script

```bash
# Make script executable (on Linux/Mac or WSL)
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

**What this does**:
- Installs Nginx, PHP, MySQL, Node.js on VPS
- Creates database and user
- Clones repository to VPS
- Configures Laravel backend
- Builds and starts Next.js frontend
- Sets up Nginx with SSL
- Configures firewall

### 8. Configure DNS

**Namecheap DNS Settings**:
1. Log in to Namecheap
2. Go to Domain List → soso-delivery.xyz → Manage
3. Advanced DNS tab
4. Add/Update records:
   - Type: `A Record`, Host: `@`, Value: `77.42.34.90`, TTL: Automatic
   - Type: `A Record`, Host: `www`, Value: `77.42.34.90`, TTL: Automatic
5. Save changes

**Wait**: DNS propagation (5-30 minutes)

### 9. Verify Deployment

```bash
# Check DNS propagation
nslookup soso-delivery.xyz

# Test HTTPS
curl -I https://soso-delivery.xyz

# Check backend
curl https://soso-delivery.xyz/api/v1/config

# Check admin panel
# Visit: https://soso-delivery.xyz/admin
```

### 10. Post-Deployment Configuration

**Backend Configuration** (via SSH):
```bash
ssh root@77.42.34.90

cd /var/www/soso-delivery.xyz/backend

# Update environment variables
nano .env

# Configure:
# - Payment gateways (Stripe, PayPal, etc.)
# - SMS gateway (Twilio)
# - Email settings
# - Google Maps API key
# - Firebase credentials
```

**Frontend Configuration**:
```bash
cd /var/www/soso-delivery.xyz/frontend

nano .env.local

# Update:
# - NEXT_PUBLIC_GOOGLE_MAP_KEY
# - Firebase credentials
# - Any other API keys
```

**Restart services**:
```bash
# Restart backend
sudo systemctl reload php8.1-fpm

# Restart frontend
pm2 restart soso-delivery-frontend

# Reload Nginx
sudo nginx -t && sudo systemctl reload nginx
```

### 11. Access Admin Panel

1. Visit: `https://soso-delivery.xyz/admin`
2. Create admin account (if first time)
3. Configure:
   - Business settings
   - Payment methods
   - Delivery zones
   - Restaurant categories
   - System settings

### 12. Test Complete Flow

**Customer Flow**:
1. Visit `https://soso-delivery.xyz`
2. Register new account
3. Browse restaurants
4. Add items to cart
5. Place test order
6. Verify payment processing

**Admin Flow**:
1. Login to admin panel
2. Check orders
3. Manage restaurants
4. View analytics

### 13. Configure Mobile Apps (Optional)

**Delivery Man App**:
```dart
// Update API endpoint in app config
static const String baseUrl = 'https://soso-delivery.xyz/api/v1';
```

**Restaurant App**:
```dart
// Update API endpoint in app config
static const String baseUrl = 'https://soso-delivery.xyz/api/v1';
```

Build and distribute apps via Google Play / App Store.

## Automated Deployments

After initial setup, deployments are automatic:

```bash
# Make changes to code
git add .
git commit -m "Update feature X"
git push origin main

# GitHub Actions automatically deploys to VPS
# Monitor: https://github.com/YOUR_USERNAME/soso-delivery-stackfood/actions
```

## Troubleshooting

### Issue: SSL Certificate Failed
```bash
ssh root@77.42.34.90
certbot --nginx -d soso-delivery.xyz -d www.soso-delivery.xyz --force-renewal
```

### Issue: Frontend Not Loading
```bash
ssh root@77.42.34.90
pm2 logs soso-delivery-frontend
pm2 restart soso-delivery-frontend
```

### Issue: Database Connection Error
```bash
# Check MySQL status
sudo systemctl status mysql

# Check credentials in .env
cd /var/www/soso-delivery.xyz/backend
cat .env | grep DB_
```

### Issue: 502 Bad Gateway
```bash
# Check PHP-FPM
sudo systemctl status php8.1-fpm
sudo systemctl restart php8.1-fpm

# Check Nginx
sudo nginx -t
sudo systemctl restart nginx
```

## Backup Strategy

### Automated Daily Backups
```bash
# Create backup script
ssh root@77.42.34.90

cat > /root/backup-stackfood.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/root/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Database backup
mysqldump -u stackfood_user -p'PASSWORD' stackfood_db > $BACKUP_DIR/db_$DATE.sql

# Files backup
tar -czf $BACKUP_DIR/files_$DATE.tar.gz /var/www/soso-delivery.xyz

# Keep only last 7 days
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Backup completed: $DATE"
EOF

chmod +x /root/backup-stackfood.sh

# Add to crontab (daily at 2 AM)
crontab -e
# Add: 0 2 * * * /root/backup-stackfood.sh >> /var/log/backup.log 2>&1
```

## Monitoring

### Setup Uptime Monitoring
- Use UptimeRobot or similar
- Monitor: `https://soso-delivery.xyz`
- Alert on downtime

### Log Monitoring
```bash
# Backend logs
tail -f /var/www/soso-delivery.xyz/backend/storage/logs/laravel.log

# Frontend logs
pm2 logs soso-delivery-frontend

# Nginx logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

## Migration from Namecheap cPanel

### Export from cPanel
1. **Database**: phpMyAdmin → Export → SQL
2. **Files**: File Manager → Compress → Download
3. **Email**: Note email accounts (recreate on VPS if needed)

### Import to VPS
```bash
# Upload database dump
scp database_backup.sql root@77.42.34.90:/tmp/

# Import
ssh root@77.42.34.90
mysql -u stackfood_user -p stackfood_db < /tmp/database_backup.sql

# Upload files (if not using Git)
scp -r ./uploads root@77.42.34.90:/var/www/soso-delivery.xyz/backend/storage/app/public/
```

## Completion Checklist

- [ ] GitHub repository created (private)
- [ ] Code pushed to GitHub
- [ ] SSH keys configured for GitHub Actions
- [ ] Initial deployment completed
- [ ] DNS configured and propagated
- [ ] SSL certificate installed
- [ ] Admin panel accessible
- [ ] Frontend loading correctly
- [ ] Database migrated
- [ ] Payment gateways configured
- [ ] Email/SMS configured
- [ ] Google Maps configured
- [ ] Test order completed
- [ ] Backup system configured
- [ ] Monitoring setup
- [ ] Mobile apps updated (if applicable)

---

**Support**: For issues, check logs first, then consult StackFood documentation or support.
