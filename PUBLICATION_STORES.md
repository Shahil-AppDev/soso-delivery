# 📱 Guide de Publication sur les Stores - Soso Delivery

## 🎯 Vue d'Ensemble

Ce guide couvre la publication des 3 applications Flutter sur Google Play et App Store.

**Apps à publier**:
1. **Soso Delivery** - App client (User App)
2. **Soso Delivery Restaurant** - App restaurant
3. **Soso Delivery Driver** - App livreur

**Firebase configuré**: ✅ `soso-delivery-b7026`

---

## 📦 Étape 1: Build des Applications

### Option A: Script Automatisé (Recommandé)

**Windows**:
```bash
cd "c:/Users/DarkNode/Desktop/Soso New"
build-all-apps.bat
```

**Linux/Mac**:
```bash
cd "c:/Users/DarkNode/Desktop/Soso New"
chmod +x build-all-apps.sh
./build-all-apps.sh
```

### Option B: Build Manuel

#### User App
```bash
cd "main-app-v10/User app and web"
flutter clean && flutter pub get
flutter build appbundle --release
flutter build apk --release
```

#### Restaurant App
```bash
cd "restaurant-app-v10/Restaurant app"
flutter clean && flutter pub get
flutter build appbundle --release
flutter build apk --release
```

#### Delivery Man App
```bash
cd "delivery-man-app-v10/Delivery man app"
flutter clean && flutter pub get
flutter build appbundle --release
flutter build apk --release
```

---

## 🤖 Google Play Store

### Prérequis
- [ ] Compte Google Play Developer (99$ one-time fee)
- [ ] App Bundles (.aab) buildés
- [ ] Screenshots (minimum 2 par type d'appareil)
- [ ] Icône 512x512 px
- [ ] Feature graphic 1024x500 px
- [ ] Description courte (80 caractères max)
- [ ] Description longue (4000 caractères max)

### Publication - User App (Client)

#### 1. Créer l'Application

1. Va sur https://play.google.com/console
2. Clique **Créer une application**
3. Remplis les informations:
   - **Nom**: Soso Delivery
   - **Langue par défaut**: Français
   - **Type**: Application
   - **Gratuite/Payante**: Gratuite

#### 2. Fiche du Store

**Description courte**:
```
Commandez vos plats préférés en quelques clics avec Soso Delivery
```

**Description longue**:
```
🍕 Soso Delivery - Votre service de livraison de repas

Découvrez une nouvelle façon de commander vos repas préférés avec Soso Delivery. 
Des restaurants locaux à votre porte en quelques clics !

✨ Fonctionnalités :
• Parcourez des centaines de restaurants
• Commandez en quelques secondes
• Suivez votre commande en temps réel
• Paiement sécurisé (carte, PayPal, etc.)
• Historique de vos commandes
• Offres et promotions exclusives

🚀 Pourquoi Soso Delivery ?
• Large choix de restaurants
• Livraison rapide
• Support client réactif
• Interface simple et intuitive

📱 Téléchargez maintenant et profitez de votre première commande !
```

**Catégorie**: Alimentation et boissons

**Tags**: livraison, nourriture, restaurant, repas, food delivery

#### 3. Assets Graphiques

**Icône de l'application** (512x512):
- Format: PNG 32 bits
- Pas de transparence
- Logo Soso Delivery centré

**Feature Graphic** (1024x500):
- Image promotionnelle
- Texte: "Soso Delivery - Vos repas livrés"
- Couleurs de la marque

**Screenshots** (minimum 2):
- **Phone**: 1080x1920 ou plus
- **Tablet 7"**: 1920x1200 ou plus
- **Tablet 10"**: 2560x1600 ou plus

Captures d'écran recommandées:
1. Page d'accueil avec restaurants
2. Menu d'un restaurant
3. Panier
4. Suivi de commande
5. Profil utilisateur

#### 4. Upload de l'App Bundle

1. **Production** → **Versions** → **Créer une version**
2. Upload `app-release.aab` depuis:
   ```
   main-app-v10/User app and web/build/app/outputs/bundle/release/app-release.aab
   ```
3. **Notes de version**:
   ```
   Version 3.0.0
   - Première version publique
   - Commande de repas en ligne
   - Suivi en temps réel
   - Paiement sécurisé
   ```

#### 5. Classification du Contenu

- **Cible d'âge**: Tous publics
- **Contenu**: Aucun contenu sensible
- **Publicités**: Non (ou Oui si applicable)

#### 6. Tarification et Distribution

- **Prix**: Gratuit
- **Pays**: France (et autres pays souhaités)
- **Appareils**: Téléphones et tablettes

#### 7. Soumettre pour Review

1. Vérifier tous les éléments
2. Cliquer **Vérifier la version**
3. Cliquer **Déployer en production**

**Délai de review**: 1-7 jours

---

### Publication - Restaurant App

Même processus que User App avec ces différences:

**Nom**: Soso Delivery Restaurant

**Description courte**:
```
Gérez votre restaurant et vos commandes avec Soso Delivery
```

**Description longue**:
```
🍽️ Soso Delivery Restaurant - Gérez votre restaurant

Application dédiée aux restaurateurs partenaires de Soso Delivery.

✨ Fonctionnalités :
• Réception des commandes en temps réel
• Gestion du menu et des produits
• Accepter/Refuser les commandes
• Statistiques de ventes
• Gestion du stock
• Impression des tickets
• Notifications instantanées

📊 Optimisez votre activité :
• Tableau de bord complet
• Historique des commandes
• Rapports de ventes
• Gestion des horaires

🚀 Rejoignez Soso Delivery et développez votre activité !
```

**App Bundle**:
```
restaurant-app-v10/Restaurant app/build/app/outputs/bundle/release/app-release.aab
```

**Package Name**: `xyz.sosodelivery.restaurant` (vérifier dans build.gradle)

---

### Publication - Delivery Man App

**Nom**: Soso Delivery Driver

**Description courte**:
```
Devenez livreur avec Soso Delivery et gagnez de l'argent
```

**Description longue**:
```
🚴 Soso Delivery Driver - Devenez livreur

Application pour les livreurs partenaires de Soso Delivery.

✨ Fonctionnalités :
• Réception des courses
• Navigation GPS intégrée
• Suivi des livraisons
• Historique et statistiques
• Gestion des gains
• Mode en ligne/hors ligne
• Support en temps réel

💰 Gagnez de l'argent :
• Horaires flexibles
• Paiement rapide
• Bonus et promotions
• Transparence des gains

🚀 Inscrivez-vous et commencez à livrer dès aujourd'hui !
```

**App Bundle**:
```
delivery-man-app-v10/Delivery man app/build/app/outputs/bundle/release/app-release.aab
```

---

## 🍎 Apple App Store

### Prérequis
- [ ] Apple Developer Account (99$/an)
- [ ] Mac avec Xcode
- [ ] Certificats de signature configurés
- [ ] Screenshots (iPhone, iPad)
- [ ] Icône 1024x1024 px

### Publication - User App

#### 1. Préparer le Build iOS

Sur un Mac:
```bash
cd "main-app-v10/User app and web"
flutter clean && flutter pub get
flutter build ios --release
open ios/Runner.xcworkspace
```

#### 2. Dans Xcode

1. **Sélectionner l'équipe** (Team)
2. **Product** → **Archive**
3. Attendre la fin de l'archivage
4. **Window** → **Organizer**
5. Sélectionner l'archive
6. **Distribute App**
7. **App Store Connect**
8. **Upload**

#### 3. App Store Connect

1. Va sur https://appstoreconnect.apple.com
2. **Mes Apps** → **+** → **Nouvelle app**
3. Remplis:
   - **Nom**: Soso Delivery
   - **Langue principale**: Français
   - **Bundle ID**: com.sosodelivery.customer
   - **SKU**: soso-delivery-customer
   - **Accès utilisateur**: Accès complet

#### 4. Informations de l'App

**Catégorie**: Alimentation et boissons

**Description**:
```
Soso Delivery - Votre service de livraison de repas

Découvrez une nouvelle façon de commander vos repas préférés avec Soso Delivery. 
Des restaurants locaux à votre porte en quelques clics !

Fonctionnalités :
• Parcourez des centaines de restaurants
• Commandez en quelques secondes
• Suivez votre commande en temps réel
• Paiement sécurisé
• Historique de vos commandes
• Offres exclusives

Téléchargez maintenant et profitez de votre première commande !
```

**Mots-clés**:
```
livraison,nourriture,restaurant,repas,food,delivery,commande
```

**URL de support**: https://soso-delivery.xyz/support

**URL marketing**: https://soso-delivery.xyz

#### 5. Screenshots

**iPhone 6.7"** (obligatoire):
- 1290 x 2796 pixels
- Minimum 3 screenshots

**iPhone 6.5"**:
- 1242 x 2688 pixels

**iPad Pro 12.9"**:
- 2048 x 2732 pixels

#### 6. Informations de Version

**Version**: 3.0.0

**Notes de version**:
```
Première version publique
- Commande de repas en ligne
- Suivi en temps réel
- Paiement sécurisé
- Interface intuitive
```

#### 7. Classification

- **Âge**: 4+
- **Contenu**: Aucun

#### 8. Soumettre

1. Sélectionner le build uploadé
2. **Ajouter pour review**
3. **Soumettre pour review**

**Délai de review**: 1-3 jours

---

## 📊 Checklist Publication

### User App (Client)
- [ ] Build Android (.aab) créé
- [ ] Build iOS (.ipa) créé
- [ ] Screenshots préparés (Android + iOS)
- [ ] Icônes préparées (512x512 + 1024x1024)
- [ ] Descriptions rédigées
- [ ] Google Play: App créée
- [ ] Google Play: Assets uploadés
- [ ] Google Play: App Bundle uploadé
- [ ] Google Play: Soumis pour review
- [ ] App Store: App créée
- [ ] App Store: Screenshots uploadés
- [ ] App Store: Build uploadé
- [ ] App Store: Soumis pour review

### Restaurant App
- [ ] Build Android (.aab) créé
- [ ] Build iOS (.ipa) créé
- [ ] Screenshots préparés
- [ ] Icônes préparées
- [ ] Descriptions rédigées
- [ ] Google Play: Publié
- [ ] App Store: Publié

### Delivery Man App
- [ ] Build Android (.aab) créé
- [ ] Build iOS (.ipa) créé
- [ ] Screenshots préparés
- [ ] Icônes préparées
- [ ] Descriptions rédigées
- [ ] Google Play: Publié
- [ ] App Store: Publié

---

## 🔄 Mises à Jour Futures

### Processus de Mise à Jour

1. **Modifier le code**
2. **Incrémenter la version** dans `pubspec.yaml`:
   ```yaml
   version: 3.0.1+4  # 3.0.1 = version, 4 = build number
   ```
3. **Rebuild**:
   ```bash
   flutter build appbundle --release
   ```
4. **Upload nouvelle version** sur les stores
5. **Notes de version** avec les changements

### Versioning

- **Major** (3.x.x): Changements majeurs, breaking changes
- **Minor** (x.1.x): Nouvelles fonctionnalités
- **Patch** (x.x.1): Corrections de bugs

---

## 🆘 Troubleshooting

### Erreur: "App Bundle not signed"
```bash
# Vérifier le keystore
keytool -list -v -keystore restaurant.jks
```

### Erreur: "Invalid package name"
Vérifier dans `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId "xyz.sosodelivery.customer"  // Doit être unique
}
```

### Erreur iOS: "Provisioning profile doesn't match"
1. Ouvrir Xcode
2. Signing & Capabilities
3. Sélectionner le bon Team
4. Automatic signing

---

## 📞 Support

- **Google Play Console**: https://support.google.com/googleplay/android-developer
- **App Store Connect**: https://developer.apple.com/support/app-store-connect/
- **Flutter**: https://docs.flutter.dev/deployment

---

## 🎯 Timeline Estimé

| Étape | Durée |
|-------|-------|
| Build des 3 apps | 1-2 heures |
| Préparation assets | 2-4 heures |
| Configuration Google Play (3 apps) | 2-3 heures |
| Configuration App Store (3 apps) | 2-3 heures |
| Review Google Play | 1-7 jours |
| Review App Store | 1-3 jours |
| **TOTAL** | **2-3 semaines** |

---

**Note**: Commencer par publier sur Google Play (plus rapide), puis App Store. Tester en profondeur avant de soumettre pour éviter les rejets.
