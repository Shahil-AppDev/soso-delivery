#!/usr/bin/expect -f

# Script de connexion et setup automatique avec mot de passe
set timeout -1

set password "ntp4vAsPJUqk"
set server "77.42.34.90"

spawn ssh root@$server

expect {
    "password:" {
        send "$password\r"
        exp_continue
    }
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    "#" {
        # Connecté au serveur
        send "echo '=== ANALYSE CONFIGURATION ACTUELLE ==='\r"
        send "ls -la /var/www/\r"
        send "pm2 list\r"
        send "ls -la /etc/nginx/sites-enabled/\r"
        
        send "echo ''\r"
        send "echo '=== SETUP SOSO DELIVERY ==='\r"
        
        # Setup complet
        send "PROJECT_NAME='soso-delivery'\r"
        send "DOMAIN='soso-delivery.xyz'\r"
        send "REPO_URL='https://github.com/Shahil-AppDev/soso-delivery.git'\r"
        
        send "mkdir -p /var/www/\$PROJECT_NAME/\{backend,frontend,logs\}\r"
        send "cd /var/www/\$PROJECT_NAME\r"
        send "rm -rf temp_repo\r"
        send "git clone \$REPO_URL temp_repo\r"
        
        expect "#"
        
        send "if \[ -d 'backend/vendor' \]; then rsync -av --exclude='.env' --exclude='vendor' --exclude='storage' temp_repo/main-app-v10/admin-panel/ backend/; else cp -r temp_repo/main-app-v10/admin-panel backend/; fi\r"
        
        expect "#"
        
        send "if \[ -d 'frontend/node_modules' \]; then rsync -av --exclude='.env.local' --exclude='node_modules' --exclude='.next' 'temp_repo/react-user-website/StackFood React/' frontend/; else cp -r 'temp_repo/react-user-website/StackFood React' frontend/; fi\r"
        
        expect "#"
        
        send "rm -rf temp_repo\r"
        send "cd backend\r"
        
        send "if \[ ! -f .env \]; then cp .env.example .env; sed -i 's|APP_URL=.*|APP_URL=https://\$DOMAIN|' .env; sed -i 's|APP_ENV=.*|APP_ENV=production|' .env; sed -i 's|APP_DEBUG=.*|APP_DEBUG=false|' .env; sed -i 's|DB_DATABASE=.*|DB_DATABASE=soso_delivery_db|' .env; sed -i 's|DB_USERNAME=.*|DB_USERNAME=soso_delivery_user|' .env; fi\r"
        
        expect "#"
        
        send "composer install --no-dev --optimize-autoloader --no-interaction\r"
        
        expect "#"
        
        send "php artisan key:generate --force\r"
        send "php artisan storage:link\r"
        send "chown -R www-data:www-data .\r"
        send "chmod -R 775 storage bootstrap/cache\r"
        
        send "cd ../frontend\r"
        
        send "if \[ ! -f .env.local \]; then echo 'NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz/api/v1' > .env.local; echo 'NEXT_PUBLIC_SOCKET_URL=https://soso-delivery.xyz' >> .env.local; echo 'PORT=3002' >> .env.local; fi\r"
        
        expect "#"
        
        send "npm ci\r"
        
        expect "#"
        
        send "echo 'Setup terminé!'\r"
        send "exit\r"
    }
}

expect eof
