# SoSo Delivery - React Website Deployment Guide

## 📋 Project Information
- **App Name**: SoSo Delivery
- **Version**: 8.4 (React v3.4)
- **Framework**: Next.js 15.1.6
- **Backend API**: https://soso-delivery.xyz
- **Package Manager**: Yarn (required)

## ✅ Pre-Deployment Checklist

### Environment Configuration
- [x] Google Maps API Key configured
- [x] Backend API URL configured
- [x] Environment files updated (.env.development & .env.production)
- [x] Vercel configuration file created

### Required Admin Panel Setup
- [ ] Login to admin panel: https://soso-delivery.xyz/admin
- [ ] Navigate to **Addon Activation** section
- [ ] Activate **React Web** toggle
- [ ] Enter CodeCanyon credentials:
  - Username: `raymondbilodeau786`
  - Purchase Code: `4410c351-6a78-4258-a0b3-9306c7c4d71e`
- [ ] Save changes

## 🚀 Deployment Methods

### Method 1: Vercel CLI (Recommended)

#### Step 1: Install Vercel CLI
```bash
npm install -g vercel
```

#### Step 2: Login to Vercel
```bash
vercel login
```

#### Step 3: Navigate to Project Directory
```bash
cd "c:\Users\DarkNode\Desktop\Soso New\react-user-website\StackFood React"
```

#### Step 4: Install Dependencies
```bash
yarn install
```

#### Step 5: Test Local Build (Optional but Recommended)
```bash
yarn build
yarn start
```

#### Step 6: Deploy to Vercel
```bash
# For production deployment
vercel --prod

# Or for preview deployment first
vercel
```

#### Step 7: Set Environment Variables in Vercel
After deployment, add these in Vercel Dashboard:
```
NEXT_PUBLIC_GOOGLE_MAP_KEY=AIzaSyAXCyRinXECYtRSst4sXoSoAo2PwKN0iJA
NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz
NEXT_CLIENT_HOST_URL=https://your-vercel-url.vercel.app
NEXT_PUBLIC_SITE_VERSION=3.4
```

### Method 2: GitHub Integration

#### Step 1: Initialize Git Repository
```bash
cd "c:\Users\DarkNode\Desktop\Soso New\react-user-website\StackFood React"
git init
git add .
git commit -m "Initial commit - SoSo Delivery React Website"
```

#### Step 2: Create GitHub Repository
- Go to https://github.com/new
- Create a new repository (e.g., `soso-delivery-react`)
- Don't initialize with README (we already have code)

#### Step 3: Push to GitHub
```bash
git remote add origin https://github.com/YOUR_USERNAME/soso-delivery-react.git
git branch -M main
git push -u origin main
```

#### Step 4: Connect to Vercel
1. Go to https://vercel.com/new
2. Import your GitHub repository
3. Configure project:
   - Framework Preset: **Next.js**
   - Build Command: `yarn build`
   - Output Directory: `.next`
   - Install Command: `yarn install`

#### Step 5: Add Environment Variables
In Vercel project settings, add:
```
NEXT_PUBLIC_GOOGLE_MAP_KEY=AIzaSyAXCyRinXECYtRSst4sXoSoAo2PwKN0iJA
NEXT_PUBLIC_BASE_URL=https://soso-delivery.xyz
NEXT_CLIENT_HOST_URL=https://your-vercel-url.vercel.app
NEXT_PUBLIC_SITE_VERSION=3.4
```

#### Step 6: Deploy
Click **Deploy** button

### Method 3: Vercel Web Interface (Drag & Drop)

#### Step 1: Build the Project Locally
```bash
cd "c:\Users\DarkNode\Desktop\Soso New\react-user-website\StackFood React"
yarn install
yarn build
```

#### Step 2: Go to Vercel
- Visit https://vercel.com/new
- Choose "Deploy without Git"

#### Step 3: Upload Project
- Drag and drop the entire project folder
- Or select the folder manually

#### Step 4: Configure & Deploy
- Add environment variables
- Click Deploy

## 🔧 Post-Deployment Configuration

### 1. Update Admin Panel
After getting your Vercel URL (e.g., `https://soso-delivery.vercel.app`):

1. Login to admin panel
2. Go to **Landing Page Settings**
3. Update React website URL to your Vercel URL
4. Configure SEO settings
5. Save changes

### 2. Update Environment Variable
Update `NEXT_CLIENT_HOST_URL` in Vercel:
```
NEXT_CLIENT_HOST_URL=https://your-actual-vercel-url.vercel.app
```

### 3. Redeploy (if needed)
If you updated environment variables, trigger a redeploy in Vercel dashboard.

## 🧪 Testing Checklist

After deployment, test these features:
- [ ] Homepage loads correctly
- [ ] Restaurant listings display
- [ ] Google Maps integration works
- [ ] Search functionality
- [ ] User registration/login
- [ ] Add to cart functionality
- [ ] Checkout process
- [ ] Order tracking
- [ ] Multi-language support

## 🔐 Security Considerations

### Google Maps API Key Security
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** > **Credentials**
3. Click on your API key
4. Under **Application restrictions**:
   - Select **HTTP referrers (web sites)**
   - Add your domains:
     - `https://soso-delivery.xyz/*`
     - `https://*.vercel.app/*`
     - `https://your-custom-domain.com/*` (if applicable)

### Environment Variables
- Never commit `.env.production` or `.env.development` to Git
- Always use Vercel's environment variable system for production
- Rotate API keys if they're exposed

## 📊 Monitoring & Maintenance

### Vercel Dashboard
- Monitor deployment status
- Check build logs
- View analytics
- Monitor performance

### Error Tracking
- Check Vercel logs for runtime errors
- Monitor API calls to backend
- Check Google Maps API usage

## 🆘 Troubleshooting

### Build Fails
```bash
# Clear cache and rebuild
rm -rf .next node_modules
yarn install
yarn build
```

### Environment Variables Not Working
- Ensure variables start with `NEXT_PUBLIC_` for client-side access
- Redeploy after adding/updating variables
- Check Vercel dashboard for variable configuration

### Google Maps Not Loading
- Verify API key is correct
- Check API key restrictions
- Ensure billing is enabled on Google Cloud
- Verify required APIs are enabled:
  - Maps JavaScript API
  - Geocoding API
  - Places API (New)
  - Routes API
  - Distance Matrix API

### Backend Connection Issues
- Verify `NEXT_PUBLIC_BASE_URL` is correct
- Check CORS settings in Laravel backend
- Ensure backend API is accessible

## 📞 Support

- **StackFood Documentation**: https://stackfood.app/documentation/
- **StackFood Support**: https://support.6amtech.com/
- **Vercel Documentation**: https://vercel.com/docs

## 🎉 Success Criteria

Your deployment is successful when:
1. ✅ Website loads at Vercel URL
2. ✅ Google Maps displays correctly
3. ✅ Backend API connections work
4. ✅ User can browse restaurants
5. ✅ Cart and checkout function properly
6. ✅ No console errors
7. ✅ Mobile responsive design works

---

**Last Updated**: November 20, 2025
**Prepared for**: SoSo Delivery React Website Deployment
