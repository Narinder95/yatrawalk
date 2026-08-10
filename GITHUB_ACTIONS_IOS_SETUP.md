# GitHub Actions iOS Build to TestFlight

Build iOS automatically on GitHub and deploy to TestFlight with every push to main branch!

## How It Works

1. **Push to GitHub** → `git push origin main`
2. **GitHub Actions runs** → Builds on Apple's Mac servers (free!)
3. **Builds iOS app** → Compiles, signs, archives
4. **Uploads to TestFlight** → Automatic
5. **Friends get notification** → New version ready!

## Prerequisites

✅ GitHub account with repo
✅ Apple Developer account ($99/year)
✅ TestFlight configured

## Step 1: Get Apple Certificates & Profiles

### Create Distribution Certificate

1. Go to: https://developer.apple.com/account/
2. **Certificates, Identifiers & Profiles**
3. **Certificates** → Click "+"
4. Select "iOS Distribution (App Store and Ad Hoc)"
5. Follow prompts to create certificate
6. Download `.cer` file

### Create Provisioning Profile

1. **Provisioning Profiles** → Click "+"
2. Select "App Store"
3. Select your App ID (or create: com.yourname.yatrawalk)
4. Select your distribution certificate
5. Download `.mobileprovision` file

### Export as Base64

On Windows, PowerShell:

```powershell
# For certificate
[Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\path\to\certificate.p12")) | Set-Clipboard

# For provisioning profile
[Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\path\to\profile.mobileprovision")) | Set-Clipboard
```

Save both base64 strings - you'll need them soon!

## Step 2: Get App Store Connect Credentials

### Create App Store Connect API Key

1. Go to: https://appstoreconnect.apple.com
2. **Users and Access** → **Keys** (under App Store Connect API)
3. Click "+"
4. **Access Level:** Admin
5. Download `.p8` file
6. Note the **Issuer ID** and **Key ID**

Or use your Apple ID password (simpler):
- **Username:** Your Apple ID email
- **Password:** App-specific password (generate at https://appleid.apple.com)

## Step 3: Add GitHub Secrets

Your GitHub repo needs secrets for:

1. Go to: **GitHub** → Your repo → **Settings** → **Secrets and variables** → **Actions**

2. Add these secrets:

```
IOS_CERTIFICATE_BASE64       = (from Step 1 - certificate)
IOS_CERTIFICATE_PASSWORD     = (password you set when exporting cert)
IOS_PROVISIONING_PROFILE_BASE64 = (from Step 1 - profile)
APPSTORE_USERNAME            = (your Apple ID email)
APPSTORE_PASSWORD            = (app-specific password)
```

### How to add secrets:

1. Click "New repository secret"
2. **Name:** IOS_CERTIFICATE_BASE64
3. **Value:** Paste base64 string
4. Click "Add secret"
5. Repeat for others

## Step 4: Verify Files

Check these files exist in your repo:

```
.github/workflows/ios-testflight.yml  ✅ (GitHub Actions workflow)
ios/exportOptions.plist                ✅ (Export configuration)
pubspec.yaml                           ✅ (Your app config)
```

## Step 5: Push to GitHub

```bash
# On Windows
git add .
git commit -m "Add GitHub Actions iOS build"
git push origin main
```

## Step 6: Watch the Build

Go to your GitHub repo:

1. Click **Actions** tab
2. See "Build iOS & Deploy to TestFlight" running
3. Click to see live logs
4. Takes ~20-30 minutes

Example output:
```
✓ Checkout code
✓ Setup Flutter
✓ Get dependencies
✓ Build Flutter iOS
✓ Import certificate
✓ Import provisioning profile
✓ Build archive
✓ Export IPA
✓ Upload to TestFlight
✅ Build uploaded to TestFlight successfully!
```

## Step 7: Invite Friends to TestFlight

After first build completes:

1. Go to: https://appstoreconnect.apple.com
2. **My Apps** → **YatraWalk** → **TestFlight**
3. **iOS Builds** → Your build should appear (wait if "Processing")
4. Create test group "Friends"
5. Add friend emails
6. Friends get invite!

## Step 8: Future Builds

Every time you push to main:

```bash
# Make changes on Windows
git add .
git commit -m "Fix xyz"
git push origin main

# GitHub Actions automatically:
# - Builds iOS
# - Signs with certificate
# - Uploads to TestFlight
# - Testers get notification!
```

No manual builds needed!

## Update Version Number

Before each build, update in `pubspec.yaml`:

```yaml
version: 1.0.0+1  # Increment +1 to +2, +3, etc for each build
```

If you forget, build will fail with "version already exists" error.

## Troubleshooting

### "Build failed: Certificate not found"
- Check secrets are correct base64
- Re-download certificate and convert to base64
- Update IOS_CERTIFICATE_BASE64 secret

### "Provisioning profile not found"
- Confirm profile matches your app bundle ID
- Check provisioning profile is valid (not expired)
- Update IOS_PROVISIONING_PROFILE_BASE64 secret

### "Authentication failed"
- Verify Apple ID and password in secrets
- Generate new app-specific password
- Check credentials have TestFlight access

### "Version already exists"
- Increment build number in pubspec.yaml
- `version: 1.0.0+2` (change +1 to +2)

### Build stuck "Processing"
- Wait 15-30 minutes
- App Store Connect processes builds
- Refresh page

### Testers can't see build
- Ensure build finished (shows "Ready to Test")
- Confirm test group created and friends added
- Check tester emails are correct

## Monitoring Builds

### See build logs:
1. GitHub repo → **Actions** tab
2. Click latest workflow
3. Click "build" job
4. Scroll to see output

### See TestFlight status:
1. App Store Connect → **My Apps**
2. Select **YatraWalk** → **TestFlight**
3. **iOS Builds** → Your build status

### Testers see:
1. TestFlight app on iPhone
2. Notification when new version available
3. "Install" button to get latest

## Cost

| Item | Cost |
|------|------|
| GitHub Actions (public repo) | Free ✅ |
| Apple Developer | $99/year |
| TestFlight | Free |
| **Total** | **$99/year** |

## Limits

- Public repo gets 3,600 Mac minutes/month (more than enough)
- Private repo: limited Mac minutes
- Build takes ~20-30 minutes per build

## Pro Tips

1. **Update version before push** - Prevents "duplicate version" errors
2. **Keep main stable** - Only push working code to main
3. **Watch Actions tab** - See real-time build progress
4. **Save base64 strings** - Easy to re-use for future projects
5. **Monitor logs** - GitHub shows exact errors if build fails

## Full Workflow

```bash
# 1. Make changes on Windows
# (edit code, test locally)

# 2. Update version number
# pubspec.yaml: version: 1.0.0+2

# 3. Commit and push
git add .
git commit -m "Feature xyz - ready for TestFlight"
git push origin main

# 4. GitHub Actions automatically:
# ✓ Builds iOS on Mac servers
# ✓ Signs with certificate
# ✓ Archives app
# ✓ Uploads to TestFlight
# (takes ~25 minutes)

# 5. Invite friends to TestFlight (first time only)
# Then they get automatic notifications for updates!
```

## Need Help?

- GitHub Actions logs: Click **Actions** → **Latest workflow** → **build**
- TestFlight status: App Store Connect → TestFlight tab
- Certificate issues: Apple Developer account → Certificates tab
- Provisioning profile: Apple Developer → Provisioning Profiles tab

## Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [TestFlight Docs](https://help.apple.com/app-store-connect/#/dev301cb2b3e)
- [Flutter iOS Build](https://docs.flutter.dev/deployment/ios)

---

**Your iOS app will automatically build and deploy to TestFlight on every push!** 🚀
