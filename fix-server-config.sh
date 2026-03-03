#!/bin/bash

###############################################################################
# Script de Configuration Serveur - Soso Delivery
# Serveur: 77.42.34.90
# Correction: angeline-nj → soso-delivery
###############################################################################

set -e

VPS_IP="77.42.34.90"
OLD_PROJECT="angeline-nj"
NEW_PROJECT="soso-delivery"

echo "🔧 Configuration du serveur pour Soso Delivery"
echo "Serveur: $VPS_IP"
echo "Ancien projet: $OLD_PROJECT"
echo "Nouveau projet: $NEW_PROJECT"
echo ""

# Se connecter au serveur et exécuter les commandes
ssh root@${VPS_IP} << 'ENDSSH'

echo "📊 Analyse de la configuration actuelle..."

# Vérifier les projets existants
echo ""
echo "=== Projets dans /var/www/ ==="
ls -la /var/www/

# Vérifier Nginx
echo ""
echo "=== Sites Nginx activés ==="
ls -la /etc/nginx/sites-enabled/

# Vérifier PM2
echo ""
echo "=== Processus PM2 ==="
pm2 list

# Vérifier les bases de données
echo ""
echo "=== Bases de données MySQL ==="
mysql -u root -p -e "SHOW DATABASES;" 2>/dev/null || echo "Connexion MySQL requise"

echo ""
echo "✅ Analyse terminée"
echo ""
echo "Prochaines étapes manuelles:"
echo "1. Créer /var/www/soso-delivery/"
echo "2. Configurer Nginx pour soso-delivery.xyz"
echo "3. Créer la base de données soso_delivery_db"
echo "4. Configurer PM2 pour le frontend"

ENDSSH

echo ""
echo "📋 Informations collectées. Vérifiez les résultats ci-dessus."
