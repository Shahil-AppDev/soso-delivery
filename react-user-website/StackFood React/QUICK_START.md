# 🚀 SoSo Delivery - Quick Start Guide

## ✅ Configuration Complete!

Your React website is now configured and ready for deployment.

## 📝 What Has Been Configured

### 1. Environment Variables ✅
- **Google Maps API Key**: Configured
- **Backend API URL**: https://soso-delivery.xyz
- **Site Version**: 3.4

### 2. Firebase Configuration ✅
- **Project**: soso-delivery-b7026
- **Push Notifications**: Configured
- **Authentication**: Configured (Phone OTP)
- **Analytics**: Configured
- **Realtime Database**: Configured
- ⚠️ **VAPID Key**: Needs to be added (see FIREBASE_SETUP.md)

### 3. Vercel Configuration ✅
- `vercel.json` created with optimal settings
- Security headers configured
- Build commands set

### 4. Git Configuration ✅
- `.gitignore` updated to exclude sensitive files
- `.env.example` created as template

## 🎯 Next Steps - Choose Your Deployment Method

### Option 1: Quick Deploy with Vercel CLI (Fastest)

```bash
# 1. Install Vercel CLI globally
npm install -g vercel

# 2. Navigate to project
cd "c:\Users\DarkNode\Desktop\Soso New\react-user-website\StackFood React"

# 3. Install dependencies
yarn install

# 4. Deploy to Vercel
vercel --prod
```

Follow the prompts:
- **Set up and deploy**: Yes
- **Which scope**: Select your account
- **Link to existing project**: No
- **Project name**: soso-delivery (or your preferred name)
- **Directory**: ./ (press Enter)
- **Override settings**: No

### Option 2: Deploy via GitHub

```bash
# 1. Initialize Git
cd "c:\Users\DarkNode\Desktop\Soso New\react-user-website\StackFood React"
git init
git add .
git commit -m "Initial commit - SoSo Delivery"

# 2. Create GitHub repo and push
# (Create repo on GitHub first)
git remote add origin https://github.com/YOUR_USERNAME/soso-delivery.git
git push -u origin main

# 3. Import to Vercel
# Go to https://vercel.com/new
# Select your GitHub repository
# Click Deploy
```

### Option 3: Test Locally First

```bash
# 1. Install dependencies
yarn install

# 2. Run development server
yarn dev

# 3. Open browser
# Visit: http://localhost:3000

# 4. Build for production
yarn build

# 5. Test production build
yarn start
```

## ⚙️ Environment Variables for Vercel

When deploying, add these in Vercel Dashboard:

| Variable | Value |
|----------|-------|
| `NEXT_PUBLIC_GOOGLE_MAP_KEY` | `AIzaSyAXCyRinXECYtRSst4sXoSoAo2PwKN0iJA` |
| `NEXT_PUBLIC_BASE_URL` | `https://soso-delivery.xyz` |
| `NEXT_CLIENT_HOST_URL` | `https://your-vercel-url.vercel.app` |
| `NEXT_PUBLIC_SITE_VERSION` | `3.4` |

**Note**: Update `NEXT_CLIENT_HOST_URL` with your actual Vercel URL after deployment.

## 🔐 Important: Admin Panel Configuration

After deployment, you MUST activate React Web in admin panel:

1. Login: https://soso-delivery.xyz/admin
2. Go to: **Addon Activation**
3. Toggle: **React Web** ON
4. Enter:
   - Username: `raymondbilodeau786`
   - Purchase Code: `4410c351-6a78-4258-a0b3-9306c7c4d71e`
5. Click **Save**

## 🔒 Secure Your Google Maps API Key

After deployment, restrict your API key:

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Click on your API key
3. Under **Application restrictions**:
   - Select: **HTTP referrers**
   - Add:
     - `https://soso-delivery.xyz/*`
     - `https://*.vercel.app/*`
     - `http://localhost:3000/*` (for development)

## 📊 Required Google APIs

Ensure these are enabled in Google Cloud Console:
- ✅ Maps JavaScript API
- ✅ Geocoding API
- ✅ Places API (New)
- ✅ Routes API
- ✅ Distance Matrix API

## 🎉 Deployment Checklist

- [ ] Dependencies installed (`yarn install`)
- [ ] Local build tested (`yarn build`)
- [ ] Firebase VAPID key added (optional, for push notifications)
- [ ] Deployed to Vercel
- [ ] Environment variables added in Vercel
- [ ] `NEXT_CLIENT_HOST_URL` updated with Vercel URL
- [ ] React Web activated in admin panel
- [ ] Google Maps API key restricted
- [ ] Firebase domains authorized
- [ ] Website tested and working

## 📱 Test Your Deployment

After deployment, verify:
- [ ] Homepage loads
- [ ] Google Maps displays
- [ ] Restaurant listings show
- [ ] Search works
- [ ] User can register/login
- [ ] Cart functionality works
- [ ] No console errors

## 🆘 Need Help?

- **Full Guide**: See `DEPLOYMENT_GUIDE.md`
- **StackFood Docs**: https://stackfood.app/documentation/
- **Vercel Docs**: https://vercel.com/docs

---

**Ready to deploy?** Run: `vercel --prod`
