# 📱 Configuration et Build des Apps Flutter

## 🎯 Vue d'Ensemble

Le projet contient **3 applications Flutter** qui doivent être buildées et publiées sur les stores mobiles:

1. **User App** - Application client (commande nourriture)
2. **Restaurant App** - Application restaurant (gestion commandes)
3. **Delivery Man App** - Application livreur (livraisons)

---

## 📦 1. User App & Web

**Dossier**: `main-app-v10/User app and web/`  
**Package**: `stackfood_multivendor`  
**Version**: 3.0.0+3

### Plateformes Supportées
- ✅ Android
- ✅ iOS
- ✅ Web (peut être déployé sur VPS)

### Configuration Pré-Build

#### 1. Configurer l'API Endpoint

**Fichier**: `lib/util/app_constants.dart`

```dart
class AppConstants {
  static const String appName = 'Soso Delivery';
  static const String baseUrl = 'https://soso-delivery.xyz';
  static const String apiVersion = '/api/v1';
  
  // Configuration
  static const String configUri = '/config';
  static const String loginUri = '/auth/login';
  static const String registerUri = '/auth/register';
  // ... autres endpoints
}
```

#### 2. Configurer Firebase

**Android**: `android/app/google-services.json`
**iOS**: `ios/Runner/GoogleService-Info.plist`

Obtenir ces fichiers depuis Firebase Console:
1. Va sur https://console.firebase.google.com
2. Crée un projet "Soso Delivery"
3. Ajoute une app Android
4. Ajoute une app iOS
5. Télécharge les fichiers de configuration

#### 3. Configurer Google Maps

**Android**: `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

**iOS**: `ios/Runner/AppDelegate.swift`
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

#### 4. Configurer les Identifiants

**Android**: `android/app/build.gradle`
```gradle
defaultConfig {
    applicationId "com.sosodelivery.customer"
    minSdkVersion 21
    targetSdkVersion 34
    versionCode 3
    versionName "3.0.0"
}
```

**iOS**: `ios/Runner/Info.plist`
```xml
<key>CFBundleIdentifier</key>
<string>com.sosodelivery.customer</string>
<key>CFBundleShortVersionString</key>
<string>3.0.0</string>
```

### Build Android

```bash
cd "c:/Users/DarkNode/Desktop/Soso New/main-app-v10/User app and web"

# Nettoyer
flutter clean
flutter pub get

# Build APK (pour test)
flutter build apk --release

# Build App Bundle (pour Google Play)
flutter build appbundle --release

# Fichier généré:
# build/app/outputs/bundle/release/app-release.aab
```

### Build iOS

```bash
cd "c:/Users/DarkNode/Desktop/Soso New/main-app-v10/User app and web"

# Nettoyer
flutter clean
flutter pub get

# Build iOS
flutter build ios --release

# Ouvrir Xcode pour archiver
open ios/Runner.xcworkspace
```

Dans Xcode:
1. Product → Archive
2. Distribute App → App Store Connect
3. Upload

### Build Web (Optionnel)

```bash
# Build pour production
flutter build web --release

# Fichiers générés dans: build/web/

# Déployer sur VPS
scp -r build/web/* root@77.42.34.90:/var/www/soso-delivery/frontend-flutter/
```

---

## 🍽️ 2. Restaurant App

**Dossier**: `restaurant-app-v10/Restaurant app/`  
**Package**: `stackfood_multivendor_restaurant`  
**Version**: 1.0.8+8

### Plateformes Supportées
- ✅ Android
- ✅ iOS
- ❌ Web (non supporté)

### Configuration Pré-Build

#### 1. Configurer l'API Endpoint

**Fichier**: `lib/util/app_constants.dart`

```dart
class AppConstants {
  static const String appName = 'Soso Delivery Restaurant';
  static const String baseUrl = 'https://soso-delivery.xyz';
  static const String apiVersion = '/api/v1';
  
  // Endpoints spécifiques restaurant
  static const String restaurantOrdersUri = '/vendor/orders';
  static const String restaurantProductsUri = '/vendor/products';
  // ... autres endpoints
}
```

#### 2. Configurer Firebase

Utilise les fichiers fournis:
- **Android**: Copie `google-services.json` vers `android/app/`
- **iOS**: Copie `GoogleService-Info.plist` vers `ios/Runner/`

#### 3. Configurer le Keystore Android

Le fichier `restaurant.jks` est fourni. Configure-le:

**Fichier**: `android/key.properties` (à créer)
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=restaurant
storeFile=../../restaurant.jks
```

**Fichier**: `android/app/build.gradle`
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### 4. Configurer les Identifiants

**Android**: `android/app/build.gradle`
```gradle
defaultConfig {
    applicationId "com.sosodelivery.restaurant"
    minSdkVersion 21
    targetSdkVersion 34
    versionCode 8
    versionName "1.0.8"
}
```

**iOS**: `ios/Runner/Info.plist`
```xml
<key>CFBundleIdentifier</key>
<string>com.sosodelivery.restaurant</string>
```

### Build Android

```bash
cd "c:/Users/DarkNode/Desktop/Soso New/restaurant-app-v10/Restaurant app"

# Nettoyer
flutter clean
flutter pub get

# Build App Bundle (signé avec restaurant.jks)
flutter build appbundle --release

# Fichier: build/app/outputs/bundle/release/app-release.aab
```

### Build iOS

```bash
cd "c:/Users/DarkNode/Desktop/Soso New/restaurant-app-v10/Restaurant app"

# Nettoyer
flutter clean
flutter pub get

# Build iOS
flutter build ios --release

# Ouvrir Xcode
open ios/Runner.xcworkspace
```

---

## 🚚 3. Delivery Man App

**Dossier**: `delivery-man-app-v10/Delivery man app/`  
**Package**: (à vérifier dans pubspec.yaml)

### Plateformes Supportées
- ✅ Android
- ✅ iOS
- ❌ Web (non supporté)

### Configuration Pré-Build

#### 1. Vérifier le Package Name

```bash
cd "c:/Users/DarkNode/Desktop/Soso New/delivery-man-app-v10/Delivery man app"
cat pubspec.yaml | grep name
```

#### 2. Configurer l'API Endpoint

**Fichier**: `lib/util/app_constants.dart`

```dart
class AppConstants {
  static const String appName = 'Soso Delivery Driver';
  static const String baseUrl = 'https://soso-delivery.xyz';
  static const String apiVersion = '/api/v1';
  
  // Endpoints spécifiques livreur
  static const String deliveryOrdersUri = '/delivery-man/orders';
  static const String deliveryStatusUri = '/delivery-man/update-status';
  // ... autres endpoints
}
```

#### 3. Configurer Firebase

Créer et ajouter les fichiers Firebase:
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`

#### 4. Configurer les Identifiants

**Android**: `android/app/build.gradle`
```gradle
defaultConfig {
    applicationId "com.sosodelivery.driver"
    minSdkVersion 21
    targetSdkVersion 34
}
```

**iOS**: `ios/Runner/Info.plist`
```xml
<key>CFBundleIdentifier</key>
<string>com.sosodelivery.driver</string>
```

### Build Android

```bash
cd "c:/Users/DarkNode/Desktop/Soso New/delivery-man-app-v10/Delivery man app"

flutter clean
flutter pub get
flutter build appbundle --release
```

### Build iOS

```bash
cd "c:/Users/DarkNode/Desktop/Soso New/delivery-man-app-v10/Delivery man app"

flutter clean
flutter pub get
flutter build ios --release
open ios/Runner.xcworkspace
```

---

## 🔧 Configuration Commune à Toutes les Apps

### 1. Variables d'Environnement Backend

Assure-toi que le backend est configuré pour accepter les requêtes des apps:

**Fichier**: `/var/www/soso-delivery/backend/.env`

```env
# CORS - Autoriser les apps mobiles
SANCTUM_STATEFUL_DOMAINS=soso-delivery.xyz,localhost

# Firebase Server Key (pour notifications push)
FCM_SERVER_KEY=YOUR_FIREBASE_SERVER_KEY

# Google Maps API (backend)
GOOGLE_MAP_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

### 2. Permissions Android

Toutes les apps nécessitent ces permissions dans `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### 3. Permissions iOS

Dans `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby restaurants</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location for delivery tracking</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to upload photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to upload images</string>
```

---

## 📤 Publication sur les Stores

### Google Play Store

#### Prérequis
1. Compte Google Play Developer (99$ one-time)
2. App Bundle signé (`.aab`)
3. Screenshots (phone, tablet)
4. Icône app (512x512)
5. Feature graphic (1024x500)
6. Description app

#### Étapes
1. Va sur https://play.google.com/console
2. Créer une nouvelle application
3. Remplir les informations:
   - Titre: "Soso Delivery" / "Soso Restaurant" / "Soso Driver"
   - Description courte et longue
   - Screenshots
   - Icône
4. Upload l'App Bundle
5. Configurer la fiche du store
6. Soumettre pour review

### Apple App Store

#### Prérequis
1. Apple Developer Account (99$/an)
2. Archive iOS (via Xcode)
3. Screenshots (iPhone, iPad)
4. Icône app (1024x1024)
5. Description app

#### Étapes
1. Créer App ID sur https://developer.apple.com
2. Créer l'app sur App Store Connect
3. Remplir les métadonnées
4. Upload via Xcode (Product → Archive → Distribute)
5. Soumettre pour review

---

## 🧪 Tests Avant Publication

### Tests Essentiels

**User App**:
- [ ] Inscription/Connexion
- [ ] Navigation restaurants
- [ ] Ajout au panier
- [ ] Paiement
- [ ] Suivi commande
- [ ] Notifications push

**Restaurant App**:
- [ ] Connexion restaurant
- [ ] Réception commandes
- [ ] Accepter/Refuser commande
- [ ] Gestion produits
- [ ] Impression ticket

**Delivery Man App**:
- [ ] Connexion livreur
- [ ] Réception livraisons
- [ ] Navigation GPS
- [ ] Mise à jour statut
- [ ] Notifications

### Tests Techniques
- [ ] API connectivity
- [ ] Firebase notifications
- [ ] Google Maps
- [ ] Permissions
- [ ] Offline mode
- [ ] Performance

---

## 📋 Checklist Complète

### Configuration Initiale
- [ ] Firebase projet créé
- [ ] Google Maps API key obtenue
- [ ] API endpoints configurés dans chaque app
- [ ] Identifiants apps configurés (package names)

### User App
- [ ] API endpoint configuré
- [ ] Firebase configuré (Android + iOS)
- [ ] Google Maps configuré
- [ ] Build Android réussi
- [ ] Build iOS réussi
- [ ] Tests effectués
- [ ] Publication Google Play
- [ ] Publication App Store

### Restaurant App
- [ ] API endpoint configuré
- [ ] Firebase configuré
- [ ] Keystore configuré
- [ ] Build Android réussi
- [ ] Build iOS réussi
- [ ] Tests effectués
- [ ] Publication Google Play
- [ ] Publication App Store

### Delivery Man App
- [ ] API endpoint configuré
- [ ] Firebase configuré
- [ ] Build Android réussi
- [ ] Build iOS réussi
- [ ] Tests effectués
- [ ] Publication Google Play
- [ ] Publication App Store

---

## 🆘 Troubleshooting

### Erreur: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### Erreur: "CocoaPods not installed"
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### Erreur: "Firebase not configured"
- Vérifie que `google-services.json` est dans `android/app/`
- Vérifie que `GoogleService-Info.plist` est dans `ios/Runner/`

### Erreur: "API connection failed"
- Vérifie l'URL de base dans `app_constants.dart`
- Vérifie que le backend est accessible
- Vérifie CORS sur le backend

---

## 📞 Ressources

- **Flutter Docs**: https://docs.flutter.dev
- **Firebase Console**: https://console.firebase.google.com
- **Google Play Console**: https://play.google.com/console
- **App Store Connect**: https://appstoreconnect.apple.com
- **StackFood Docs**: https://stackfood.app/documentation/

---

**Note**: Les apps mobiles doivent être buildées et publiées **après** que le backend soit déployé et fonctionnel sur le VPS, car elles dépendent de l'API.
