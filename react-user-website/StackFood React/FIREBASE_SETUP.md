# Firebase Configuration - SoSo Delivery

## ✅ Firebase Configuration Complete

Your Firebase project has been configured for the SoSo Delivery React website.

## 📋 Firebase Project Details

- **Project ID**: soso-delivery-b7026
- **Auth Domain**: soso-delivery-b7026.firebaseapp.com
- **Database URL**: https://soso-delivery-b7026-default-rtdb.firebaseio.com
- **Storage Bucket**: soso-delivery-b7026.appspot.com
- **Messaging Sender ID**: 834616542221
- **App ID**: 1:834616542221:web:8561465b7b400e52cf8144
- **Measurement ID**: G-SQ042QLE27

## 🔧 Files Configured

1. ✅ `src/firebase.js` - Main Firebase configuration
2. ✅ `public/firebase-messaging-sw.js` - Service worker for push notifications

## ⚠️ IMPORTANT: VAPID Key Required for Push Notifications

To enable push notifications, you need to add a VAPID key from Firebase Console.

### How to Get VAPID Key:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **soso-delivery-b7026**
3. Click on **Project Settings** (gear icon)
4. Go to **Cloud Messaging** tab
5. Scroll down to **Web Push certificates**
6. Click **Generate key pair** (if not already generated)
7. Copy the **Key pair** value

### Where to Add VAPID Key:

Edit `src/firebase.js` at line 36-37:

```javascript
export const fetchToken = async (setFcmToken) => {
    return getToken(await messaging, {
        vapidKey: 'YOUR_VAPID_KEY_HERE', // Replace with your actual VAPID key
    })
```

**Current Status**: VAPID key is empty (line 37 in firebase.js)

## 🔔 Firebase Cloud Messaging (FCM) Features

Your app is configured to support:

- ✅ Push notifications
- ✅ Background message handling
- ✅ Firebase Authentication (for OTP)
- ✅ Firebase Analytics
- ✅ Realtime Database

## 🚀 Firebase Services Used

### 1. Firebase Cloud Messaging (FCM)
- Push notifications for orders
- Real-time updates
- Background notifications

### 2. Firebase Authentication
- Phone number verification (OTP)
- Social login support
- Password reset via Firebase

### 3. Firebase Analytics
- User behavior tracking
- Event tracking
- Performance monitoring

### 4. Firebase Realtime Database
- Real-time data sync
- Chat functionality
- Live order updates

## 📝 Next Steps

### Step 1: Get VAPID Key (Required for Push Notifications)
```bash
# Follow the instructions above to get your VAPID key
# Then update src/firebase.js line 37
```

### Step 2: Enable Firebase Services

Go to Firebase Console and ensure these are enabled:

1. **Authentication**
   - Enable Phone authentication
   - Add your domain to authorized domains
   - Configure OAuth providers (if using social login)

2. **Cloud Messaging**
   - Already configured ✅
   - Add VAPID key

3. **Realtime Database**
   - Set up database rules
   - Configure security rules

4. **Analytics**
   - Already configured ✅
   - Will start tracking after deployment

### Step 3: Configure Firebase for Production

Add your production domain to Firebase:

1. Go to **Authentication** → **Settings** → **Authorized domains**
2. Add:
   - `soso-delivery.xyz`
   - `your-vercel-domain.vercel.app`
   - Any custom domains

### Step 4: Update Environment Variables

Add to `.env.production` (if needed):

```bash
# Firebase configuration is in code, but you can also use env vars
NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSyB0Qgw61bc8PTsWP1qfPtI0zGk25OwhM_w
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=soso-delivery-b7026.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=soso-delivery-b7026
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=soso-delivery-b7026.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=834616542221
NEXT_PUBLIC_FIREBASE_APP_ID=1:834616542221:web:8561465b7b400e52cf8144
NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID=G-SQ042QLE27
NEXT_PUBLIC_FIREBASE_DATABASE_URL=https://soso-delivery-b7026-default-rtdb.firebaseio.com
```

## 🔒 Security Considerations

### Firebase Security Rules

#### Realtime Database Rules:
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

#### Storage Rules:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### API Key Security

- Firebase API keys are safe to expose in client-side code
- They identify your Firebase project
- Security is enforced by Firebase Security Rules
- Restrict usage in Firebase Console if needed

## 🧪 Testing Firebase Integration

### Test Push Notifications:

1. Deploy the website
2. Allow notifications when prompted
3. Place a test order
4. Check if notification appears

### Test Authentication:

1. Try phone number login
2. Verify OTP is received
3. Test password reset

### Test Analytics:

1. Visit Firebase Console → Analytics
2. Check real-time users
3. Monitor events

## 📊 Firebase Quotas (Free Tier)

- **Cloud Messaging**: Unlimited
- **Authentication**: 10K verifications/month
- **Realtime Database**: 1GB storage, 10GB/month download
- **Analytics**: Unlimited events

## 🆘 Troubleshooting

### Push Notifications Not Working

1. Check VAPID key is added
2. Verify service worker is registered
3. Check browser console for errors
4. Ensure HTTPS is enabled (required for FCM)

### Authentication Errors

1. Check phone authentication is enabled
2. Verify domain is authorized
3. Check reCAPTCHA configuration

### Database Connection Issues

1. Verify database URL is correct
2. Check security rules
3. Ensure authentication is working

## 📞 Support

- **Firebase Documentation**: https://firebase.google.com/docs
- **Firebase Console**: https://console.firebase.google.com/
- **StackFood Support**: https://support.6amtech.com/

---

**Status**: Firebase configured ✅ | VAPID key needed ⚠️
**Last Updated**: November 20, 2025
