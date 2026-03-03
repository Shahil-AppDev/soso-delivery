#!/bin/bash

###############################################################################
# Quick Deploy Script - StackFood to Hetzner VPS
# Run this after pushing code to GitHub
###############################################################################

set -e

VPS_IP="77.42.34.90"
DOMAIN="soso-delivery.xyz"

echo "🚀 Quick Deploy to ${DOMAIN}"
echo "================================"

# Check if SSH key exists
if [ ! -f "deployment-key" ]; then
    echo "⚠️  Generating SSH deployment key..."
    ssh-keygen -t ed25519 -f deployment-key -N "" -C "github-deploy"
    echo "✅ SSH key generated"
    echo ""
    echo "📋 NEXT STEPS:"
    echo "1. Add public key to VPS:"
    echo "   ssh root@${VPS_IP} 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys' < deployment-key.pub"
    echo ""
    echo "2. Add private key to GitHub Secrets:"
    echo "   - Go to: Repository → Settings → Secrets → Actions"
    echo "   - Name: SSH_PRIVATE_KEY"
    echo "   - Value: Copy content of 'deployment-key' file"
    echo ""
    read -p "Press Enter after completing these steps..."
fi

# Test SSH connection
echo "🔐 Testing SSH connection..."
if ssh -i deployment-key -o StrictHostKeyChecking=no root@${VPS_IP} "echo 'SSH connection successful'"; then
    echo "✅ SSH connection working"
else
    echo "❌ SSH connection failed. Please check your SSH key setup."
    exit 1
fi

# Deploy via SSH
echo ""
echo "📦 Deploying application..."
ssh -i deployment-key root@${VPS_IP} << 'ENDSSH'
    set -e
    
    cd /var/www/soso-delivery.xyz
    
    # Pull latest changes
    echo "📥 Pulling latest code..."
    cd backend && git pull origin main
    cd ../frontend && git pull origin main
    
    # Backend deployment
    echo "🔧 Deploying backend..."
    cd /var/www/soso-delivery.xyz/backend
    composer install --no-dev --optimize-autoloader --no-interaction
    php artisan migrate --force
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    # Frontend deployment
    echo "🔧 Deploying frontend..."
    cd /var/www/soso-delivery.xyz/frontend
    npm ci
    npm run build
    pm2 restart soso-delivery-frontend
    
    # Reload services
    echo "🔄 Reloading services..."
    sudo systemctl reload php8.1-fpm
    sudo nginx -t && sudo systemctl reload nginx
    
    echo "✅ Deployment completed!"
ENDSSH

echo ""
echo "🎉 Deployment successful!"
echo "🌐 Visit: https://${DOMAIN}"
echo "🔐 Admin: https://${DOMAIN}/admin"
