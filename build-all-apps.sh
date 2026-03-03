#!/bin/bash

###############################################################################
# Script de Build Automatisé - Toutes les Apps Flutter
# Soso Delivery - Apps Mobiles
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Build Automatisé - Apps Flutter Soso Delivery       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"

# Configuration
API_URL="https://soso-delivery.xyz"
BUILD_TYPE="release"

# Fonction pour vérifier Flutter
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter n'est pas installé${NC}"
        echo "Installer Flutter: https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    echo -e "${GREEN}✅ Flutter installé: $(flutter --version | head -n 1)${NC}"
}

# Fonction pour nettoyer et préparer
prepare_app() {
    local app_path=$1
    echo -e "\n${YELLOW}🧹 Nettoyage de $app_path...${NC}"
    cd "$app_path"
    flutter clean
    flutter pub get
    echo -e "${GREEN}✅ Préparation terminée${NC}"
}

# Fonction pour build Android
build_android() {
    local app_name=$1
    echo -e "\n${YELLOW}📦 Build Android - $app_name...${NC}"
    
    # Build App Bundle (pour Google Play)
    flutter build appbundle --release
    
    # Build APK (pour test)
    flutter build apk --release
    
    echo -e "${GREEN}✅ Build Android terminé${NC}"
    echo -e "   App Bundle: build/app/outputs/bundle/release/app-release.aab"
    echo -e "   APK: build/app/outputs/flutter-apk/app-release.apk"
}

# Fonction pour build iOS
build_ios() {
    local app_name=$1
    echo -e "\n${YELLOW}📦 Build iOS - $app_name...${NC}"
    
    flutter build ios --release --no-codesign
    
    echo -e "${GREEN}✅ Build iOS terminé${NC}"
    echo -e "${YELLOW}⚠️  Ouvrir Xcode pour signer et archiver:${NC}"
    echo -e "   open ios/Runner.xcworkspace"
}

# Menu de sélection
echo -e "\n${BLUE}Quelle(s) app(s) voulez-vous builder ?${NC}"
echo "1) User App (Client)"
echo "2) Restaurant App"
echo "3) Delivery Man App"
echo "4) Toutes les apps"
echo "5) Quitter"
read -p "Choix (1-5): " choice

# Vérifier Flutter
check_flutter

case $choice in
    1)
        echo -e "\n${BLUE}═══ BUILD USER APP ═══${NC}"
        prepare_app "main-app-v10/User app and web"
        build_android "User App"
        build_ios "User App"
        ;;
    2)
        echo -e "\n${BLUE}═══ BUILD RESTAURANT APP ═══${NC}"
        prepare_app "restaurant-app-v10/Restaurant app"
        build_android "Restaurant App"
        build_ios "Restaurant App"
        ;;
    3)
        echo -e "\n${BLUE}═══ BUILD DELIVERY MAN APP ═══${NC}"
        prepare_app "delivery-man-app-v10/Delivery man app"
        build_android "Delivery Man App"
        build_ios "Delivery Man App"
        ;;
    4)
        echo -e "\n${BLUE}═══ BUILD TOUTES LES APPS ═══${NC}"
        
        # User App
        echo -e "\n${BLUE}[1/3] User App${NC}"
        prepare_app "main-app-v10/User app and web"
        build_android "User App"
        build_ios "User App"
        cd ../..
        
        # Restaurant App
        echo -e "\n${BLUE}[2/3] Restaurant App${NC}"
        prepare_app "restaurant-app-v10/Restaurant app"
        build_android "Restaurant App"
        build_ios "Restaurant App"
        cd ../..
        
        # Delivery Man App
        echo -e "\n${BLUE}[3/3] Delivery Man App${NC}"
        prepare_app "delivery-man-app-v10/Delivery man app"
        build_android "Delivery Man App"
        build_ios "Delivery Man App"
        cd ../..
        
        echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║   ✅ TOUS LES BUILDS TERMINÉS !                       ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
        ;;
    5)
        echo "Annulé"
        exit 0
        ;;
    *)
        echo -e "${RED}Choix invalide${NC}"
        exit 1
        ;;
esac

echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Build terminé avec succès !${NC}"
echo -e "\n${YELLOW}Prochaines étapes:${NC}"
echo "1. Tester les APKs sur des appareils Android"
echo "2. Ouvrir Xcode pour signer et archiver les apps iOS"
echo "3. Uploader sur Google Play Console et App Store Connect"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
