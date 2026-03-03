#!/bin/bash

###############################################################################
# StackFood Deployment Script for Hetzner VPS
# Domain: soso-delivery.xyz
# Server: 77.42.34.90
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
VPS_IP="77.42.34.90"
DOMAIN="soso-delivery.xyz"
PROJECT_ROOT="/var/www/${DOMAIN}"
BACKEND_DIR="${PROJECT_ROOT}/backend"
FRONTEND_DIR="${PROJECT_ROOT}/frontend"
DB_NAME="stackfood_db"
DB_USER="stackfood_user"
DB_PASS=$(openssl rand -base64 32)

echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   StackFood Deployment to Hetzner VPS                 ║${NC}"
echo -e "${GREEN}║   Domain: ${DOMAIN}                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"

# Function to run commands on VPS
run_remote() {
    ssh root@${VPS_IP} "$@"
}

# Step 1: Initial VPS Setup
echo -e "\n${YELLOW}[1/10] Setting up VPS environment...${NC}"
run_remote << 'ENDSSH'
    # Update system
    apt update && apt upgrade -y
    
    # Install required packages
    apt install -y nginx mysql-server php8.1-fpm php8.1-mysql php8.1-xml php8.1-mbstring \
        php8.1-curl php8.1-zip php8.1-gd php8.1-bcmath php8.1-intl php8.1-soap \
        php8.1-redis php8.1-imagick git curl unzip nodejs npm certbot python3-certbot-nginx
    
    # Install Composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    
    # Install PM2 for Node.js process management
    npm install -g pm2
    
    echo "✅ VPS environment setup completed"
ENDSSH

# Step 2: Create MySQL Database
echo -e "\n${YELLOW}[2/10] Creating MySQL database...${NC}"
run_remote << ENDSSH
    mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
    echo "✅ Database created: ${DB_NAME}"
ENDSSH

# Step 3: Create project directories
echo -e "\n${YELLOW}[3/10] Creating project directories...${NC}"
run_remote << ENDSSH
    mkdir -p ${PROJECT_ROOT}/{backend,frontend}
    chown -R www-data:www-data ${PROJECT_ROOT}
    echo "✅ Project directories created"
ENDSSH

# Step 4: Clone repository to VPS
echo -e "\n${YELLOW}[4/10] Cloning repository...${NC}"
echo -e "${GREEN}Please ensure you've pushed your code to GitHub first!${NC}"
read -p "Enter your GitHub repository URL: " REPO_URL

run_remote << ENDSSH
    cd ${PROJECT_ROOT}
    
    # Clone backend
    git clone ${REPO_URL} temp_repo
    cp -r temp_repo/main-app-v10/admin-panel/* ${BACKEND_DIR}/
    cp -r temp_repo/react-user-website/StackFood\ React/* ${FRONTEND_DIR}/
    rm -rf temp_repo
    
    echo "✅ Repository cloned"
ENDSSH

# Step 5: Configure Backend (Laravel)
echo -e "\n${YELLOW}[5/10] Configuring Laravel backend...${NC}"
run_remote << ENDSSH
    cd ${BACKEND_DIR}
    
    # Copy environment file
    cp .env.example .env
    
    # Update .env with production settings
    sed -i "s|APP_ENV=.*|APP_ENV=production|" .env
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|" .env
    sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USER}|" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|" .env
    
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
    
    echo "✅ Backend configured"
ENDSSH

# Step 6: Configure Frontend (Next.js)
echo -e "\n${YELLOW}[6/10] Configuring Next.js frontend...${NC}"
run_remote << ENDSSH
    cd ${FRONTEND_DIR}
    
    # Create .env.local
    cat > .env.local << 'EOF'
NEXT_PUBLIC_BASE_URL=https://${DOMAIN}/api/v1
NEXT_PUBLIC_SOCKET_URL=https://${DOMAIN}
NEXT_PUBLIC_GOOGLE_MAP_KEY=YOUR_GOOGLE_MAP_KEY
EOF
    
    # Install dependencies
    npm ci
    
    # Build Next.js app
    npm run build
    
    # Start with PM2
    pm2 start npm --name "soso-delivery-frontend" -- start
    pm2 startup
    pm2 save
    
    echo "✅ Frontend configured"
ENDSSH

# Step 7: Configure Nginx
echo -e "\n${YELLOW}[7/10] Configuring Nginx...${NC}"
run_remote << ENDSSH
    cat > /etc/nginx/sites-available/${DOMAIN} << 'EOF'
# Backend API
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};
    root ${BACKEND_DIR}/public;
    
    index index.php index.html;
    
    # API routes
    location /api {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    # Admin panel routes
    location /admin {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    # Storage files
    location /storage {
        alias ${BACKEND_DIR}/storage/app/public;
    }
    
    # PHP handling
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # Frontend (Next.js) - proxy to PM2
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }
    
    client_max_body_size 100M;
}
EOF
    
    # Enable site
    ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    # Test and reload Nginx
    nginx -t && systemctl reload nginx
    
    echo "✅ Nginx configured"
ENDSSH

# Step 8: Setup SSL Certificate
echo -e "\n${YELLOW}[8/10] Setting up SSL certificate...${NC}"
read -p "Enter your email for SSL certificate: " SSL_EMAIL

run_remote << ENDSSH
    certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos -m ${SSL_EMAIL}
    
    # Setup auto-renewal
    systemctl enable certbot.timer
    systemctl start certbot.timer
    
    echo "✅ SSL certificate installed"
ENDSSH

# Step 9: Configure Firewall
echo -e "\n${YELLOW}[9/10] Configuring firewall...${NC}"
run_remote << 'ENDSSH'
    ufw --force enable
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw reload
    
    echo "✅ Firewall configured"
ENDSSH

# Step 10: Final checks
echo -e "\n${YELLOW}[10/10] Running final checks...${NC}"
run_remote << ENDSSH
    # Check services
    systemctl status nginx --no-pager
    systemctl status php8.1-fpm --no-pager
    systemctl status mysql --no-pager
    pm2 status
    
    echo "✅ All services running"
ENDSSH

# Save credentials
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              DEPLOYMENT COMPLETED!                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo -e "\n${YELLOW}Important Information:${NC}"
echo -e "Domain: https://${DOMAIN}"
echo -e "Admin Panel: https://${DOMAIN}/admin"
echo -e "API: https://${DOMAIN}/api"
echo -e "\nDatabase Credentials:"
echo -e "Database: ${DB_NAME}"
echo -e "Username: ${DB_USER}"
echo -e "Password: ${DB_PASS}"
echo -e "\n${RED}⚠️  SAVE THESE CREDENTIALS SECURELY!${NC}"

# Save to file
cat > deployment-credentials.txt << EOF
StackFood Deployment Credentials
================================
Date: $(date)
Domain: https://${DOMAIN}
Server IP: ${VPS_IP}

Database:
- Name: ${DB_NAME}
- User: ${DB_USER}
- Password: ${DB_PASS}

Directories:
- Backend: ${BACKEND_DIR}
- Frontend: ${FRONTEND_DIR}

Admin Panel: https://${DOMAIN}/admin
API Endpoint: https://${DOMAIN}/api/v1
EOF

echo -e "\n${GREEN}Credentials saved to: deployment-credentials.txt${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Configure your domain DNS to point to ${VPS_IP}"
echo -e "2. Access admin panel and complete initial setup"
echo -e "3. Configure payment gateways and third-party services"
echo -e "4. Test all functionality"
