# Migration Checklist: Namecheap cPanel → Hetzner VPS

## 📋 Pre-Migration (On Namecheap cPanel)

### Database Export
- [ ] Login to cPanel
- [ ] Open phpMyAdmin
- [ ] Select StackFood database
- [ ] Click "Export" tab
- [ ] Choose "Quick" export method
- [ ] Format: SQL
- [ ] Click "Go" to download
- [ ] Save as: `stackfood_backup_YYYYMMDD.sql`

### Files Backup
- [ ] Login to cPanel File Manager
- [ ] Navigate to public_html or application directory
- [ ] Locate storage/app/public folder
- [ ] Download all uploaded files (images, documents)
- [ ] Save .env file (for reference)
- [ ] Note all environment variables

### Configuration Audit
- [ ] Document database credentials
- [ ] List all email accounts
- [ ] Note SSL certificate details
- [ ] Record payment gateway credentials
- [ ] Save API keys (Google Maps, Firebase, etc.)
- [ ] Document third-party integrations
- [ ] Note cron jobs (if any)

### DNS Information
- [ ] Current nameservers
- [ ] A records
- [ ] MX records (if using email)
- [ ] TXT records (SPF, DKIM)
- [ ] Any subdomains

---

## 🚀 Migration Process

### Step 1: VPS Preparation
- [ ] SSH access confirmed (root@77.42.34.90)
- [ ] VPS updated: `apt update && apt upgrade -y`
- [ ] Required software installed (Nginx, PHP, MySQL, Node.js)
- [ ] Firewall configured (UFW)
- [ ] MySQL secured

### Step 2: Database Migration
- [ ] MySQL database created on VPS
- [ ] Database user created with strong password
- [ ] SQL backup uploaded to VPS
- [ ] Database imported successfully
- [ ] Database connection tested
- [ ] Credentials saved securely

### Step 3: Application Deployment
- [ ] Git repository created (private)
- [ ] Code pushed to GitHub
- [ ] SSH keys generated for deployment
- [ ] Public key added to VPS
- [ ] Private key added to GitHub Secrets
- [ ] Backend cloned to VPS
- [ ] Frontend cloned to VPS
- [ ] Dependencies installed (Composer, NPM)

### Step 4: Configuration
- [ ] Backend .env configured
- [ ] Frontend .env.local configured
- [ ] Laravel key generated
- [ ] Database migrations run
- [ ] Storage linked
- [ ] Permissions set correctly
- [ ] PM2 configured for frontend

### Step 5: Web Server Setup
- [ ] Nginx configuration created
- [ ] Site enabled in Nginx
- [ ] Nginx configuration tested
- [ ] PHP-FPM configured
- [ ] Services restarted

### Step 6: DNS Migration
- [ ] DNS records documented from Namecheap
- [ ] A records updated to point to 77.42.34.90
- [ ] WWW subdomain configured
- [ ] DNS propagation verified (nslookup)
- [ ] Old site still accessible during transition

### Step 7: SSL Certificate
- [ ] DNS fully propagated
- [ ] Certbot installed
- [ ] SSL certificate obtained
- [ ] HTTPS redirect enabled
- [ ] Auto-renewal configured
- [ ] Certificate tested

### Step 8: File Migration
- [ ] Uploaded files transferred to VPS
- [ ] Files placed in storage/app/public
- [ ] Permissions set (775)
- [ ] Ownership set (www-data:www-data)
- [ ] Storage link verified

### Step 9: Testing
- [ ] Frontend loads: https://soso-delivery.xyz
- [ ] Admin panel accessible: https://soso-delivery.xyz/admin
- [ ] API responding: https://soso-delivery.xyz/api/v1/config
- [ ] Database queries working
- [ ] File uploads working
- [ ] Images displaying correctly
- [ ] User registration tested
- [ ] Login/logout tested
- [ ] Order placement tested
- [ ] Payment gateway tested
- [ ] Email notifications tested
- [ ] SMS notifications tested

### Step 10: GitHub Actions
- [ ] Workflow file created
- [ ] SSH_PRIVATE_KEY secret added
- [ ] Test deployment triggered
- [ ] Deployment successful
- [ ] Logs reviewed

---

## 🔍 Post-Migration Verification

### Functionality Tests
- [ ] Customer can register
- [ ] Customer can login
- [ ] Restaurant listing loads
- [ ] Menu items display
- [ ] Cart functionality works
- [ ] Checkout process works
- [ ] Payment processing works
- [ ] Order confirmation received
- [ ] Admin can login
- [ ] Admin can view orders
- [ ] Admin can manage restaurants
- [ ] Admin can manage users
- [ ] Reports generate correctly

### Performance Tests
- [ ] Page load times acceptable
- [ ] API response times good
- [ ] Database queries optimized
- [ ] Images loading fast
- [ ] No 404 errors
- [ ] No 500 errors
- [ ] SSL certificate valid
- [ ] HTTPS enforced

### Security Checks
- [ ] APP_DEBUG=false
- [ ] Strong database password
- [ ] SSH key authentication only
- [ ] Firewall active
- [ ] Unnecessary ports closed
- [ ] File permissions correct
- [ ] .env files not publicly accessible
- [ ] Admin panel protected
- [ ] CSRF protection enabled
- [ ] XSS protection enabled

### Monitoring Setup
- [ ] Error logging configured
- [ ] Access logs reviewed
- [ ] PM2 monitoring active
- [ ] Database backups scheduled
- [ ] File backups scheduled
- [ ] Uptime monitoring configured
- [ ] Alert notifications setup

---

## 📧 Email Migration (if applicable)

### If Using Email on Domain
- [ ] Email accounts listed
- [ ] Install mail server (Postfix/Dovecot) OR
- [ ] Configure external email (Google Workspace, etc.)
- [ ] MX records updated
- [ ] SPF record configured
- [ ] DKIM configured
- [ ] Email tested (send/receive)

### If Using SMTP Only
- [ ] SMTP credentials verified
- [ ] Test email sent from application
- [ ] Email templates working
- [ ] Unsubscribe links working

---

## 🔄 Rollback Plan (if needed)

### If Migration Fails
- [ ] Keep cPanel site active during testing
- [ ] Document rollback steps
- [ ] Have database backup ready
- [ ] Can revert DNS quickly
- [ ] Communication plan for users

### Rollback Steps
1. Update DNS back to old IP
2. Wait for propagation
3. Verify old site working
4. Investigate VPS issues
5. Fix and retry migration

---

## 📱 Mobile App Updates

### After Successful Migration
- [ ] Update API endpoint in Delivery Man app
- [ ] Update API endpoint in Restaurant app
- [ ] Test apps with new API
- [ ] Build new app versions
- [ ] Submit to app stores (if needed)
- [ ] Notify users of updates

---

## 🎯 Go-Live Checklist

### Final Steps Before Going Live
- [ ] All tests passed
- [ ] Backups configured
- [ ] Monitoring active
- [ ] Team trained on new system
- [ ] Documentation updated
- [ ] Support contacts ready

### Go-Live
- [ ] Announce maintenance window (if needed)
- [ ] Update DNS to VPS IP
- [ ] Monitor DNS propagation
- [ ] Test from multiple locations
- [ ] Monitor error logs
- [ ] Monitor user reports
- [ ] Confirm all services running

### Post Go-Live (First 24 Hours)
- [ ] Monitor server resources
- [ ] Check error logs frequently
- [ ] Verify backups running
- [ ] Test critical functions
- [ ] Respond to user issues
- [ ] Document any problems

### Post Go-Live (First Week)
- [ ] Daily monitoring
- [ ] Performance optimization
- [ ] User feedback collection
- [ ] Address any issues
- [ ] Optimize as needed

---

## 📞 Emergency Contacts

### Support Resources
- **VPS Provider**: Hetzner Support
- **Domain Registrar**: Namecheap Support
- **StackFood Support**: https://support.6amtech.com/
- **Developer**: Business Services IDF (Shahil AppDev)

### Critical Information Storage
- [ ] Database credentials saved in password manager
- [ ] SSH keys backed up securely
- [ ] API keys documented
- [ ] Emergency access procedures documented

---

## ✅ Migration Complete

### Sign-Off
- [ ] All checklist items completed
- [ ] No critical issues remaining
- [ ] Performance acceptable
- [ ] Users can access system
- [ ] Backups verified
- [ ] Monitoring confirmed
- [ ] Documentation updated
- [ ] Old cPanel can be decommissioned

**Migration Date**: _______________  
**Completed By**: _______________  
**Verified By**: _______________  

---

**Notes**: Use this checklist systematically. Don't skip steps. Test thoroughly before going live.
