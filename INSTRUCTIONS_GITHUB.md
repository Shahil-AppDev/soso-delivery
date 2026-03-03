# Instructions pour Créer le Repo GitHub et Pousser le Code

## Étape 1: Créer le Repo GitHub (Privé)

1. Va sur https://github.com/new
2. Remplis les informations:
   - **Repository name**: `soso-delivery-stackfood`
   - **Description**: "StackFood multi-restaurant delivery platform - Soso Delivery project"
   - **Visibility**: ⚠️ **Private** (IMPORTANT)
   - **Ne coche PAS**: "Initialize this repository with a README"
3. Clique sur **Create repository**

## Étape 2: Configurer le Remote et Pousser

Une fois le repo créé, GitHub te donnera des commandes. Utilise celles-ci:

```bash
cd "c:/Users/DarkNode/Desktop/Soso New"

# Ajouter le remote (remplace YOUR_USERNAME par ton username GitHub)
git remote add origin https://github.com/YOUR_USERNAME/soso-delivery-stackfood.git

# Renommer la branche en main
git branch -M main

# Pousser le code
git push -u origin main
```

## Étape 3: Configurer les Secrets GitHub

Après avoir poussé le code:

1. Va sur ton repo: `https://github.com/YOUR_USERNAME/soso-delivery-stackfood`
2. Clique sur **Settings** (en haut)
3. Dans le menu de gauche: **Secrets and variables** → **Actions**
4. Clique sur **New repository secret**
5. Ajoute le secret suivant:
   - **Name**: `SSH_PRIVATE_KEY`
   - **Value**: (tu devras générer une clé SSH - voir ci-dessous)

## Étape 4: Générer les Clés SSH pour le Déploiement

Sur ton ordinateur local (PowerShell ou Git Bash):

```bash
# Générer la paire de clés
ssh-keygen -t ed25519 -f deployment-key -N "" -C "github-deploy"

# Cela crée 2 fichiers:
# - deployment-key (clé privée) → pour GitHub Secret
# - deployment-key.pub (clé publique) → pour le VPS
```

## Étape 5: Ajouter la Clé Publique au VPS

```bash
# Afficher la clé publique
type deployment-key.pub

# Copier le contenu et l'ajouter au VPS
ssh root@77.42.34.90

# Sur le VPS:
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
# Coller la clé publique à la fin du fichier
# Sauvegarder (Ctrl+X, Y, Enter)

chmod 600 ~/.ssh/authorized_keys
exit
```

## Étape 6: Ajouter la Clé Privée à GitHub

1. Sur ton ordinateur, affiche la clé privée:
   ```bash
   type deployment-key
   ```

2. Copie TOUT le contenu (y compris les lignes BEGIN et END)

3. Va sur GitHub:
   - Repo → Settings → Secrets and variables → Actions
   - New repository secret
   - Name: `SSH_PRIVATE_KEY`
   - Value: Colle la clé privée complète
   - Add secret

## Étape 7: Tester le Déploiement Automatique

Une fois tout configuré:

```bash
# Faire un petit changement
echo "# Test deployment" >> README.md

# Commiter et pousser
git add README.md
git commit -m "Test: GitHub Actions deployment"
git push origin main
```

Ensuite:
1. Va sur GitHub → ton repo → onglet **Actions**
2. Tu verras le workflow "Deploy to Hetzner VPS" en cours d'exécution
3. Clique dessus pour voir les logs en temps réel

## ✅ Vérification

Après le premier déploiement réussi:

```bash
# Connecte-toi au VPS
ssh root@77.42.34.90

# Vérifie que le projet existe
ls -la /var/www/soso-delivery/

# Vérifie PM2
pm2 list

# Vérifie Nginx
ls -la /etc/nginx/sites-enabled/

# Teste l'API
curl https://soso-delivery.xyz/api/v1/config
```

## 🔑 Résumé des Credentials à Sauvegarder

- **Repo GitHub**: https://github.com/YOUR_USERNAME/soso-delivery-stackfood
- **Clé SSH privée**: `deployment-key` (NE PAS PARTAGER)
- **Clé SSH publique**: `deployment-key.pub`
- **VPS IP**: 77.42.34.90
- **Domaine**: soso-delivery.xyz

## 📞 Besoin d'Aide ?

Si tu rencontres un problème:
1. Vérifie les logs GitHub Actions
2. Vérifie les logs sur le VPS: `pm2 logs` et `/var/log/nginx/`
3. Consulte `DEPLOYMENT_GUIDE.md` pour le troubleshooting

---

**Note**: Garde les clés SSH en sécurité. Ne les commite JAMAIS dans Git !
