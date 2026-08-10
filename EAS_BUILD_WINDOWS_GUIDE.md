# Build iOS on Windows with EAS Build

This guide helps Windows users build iOS apps without needing a Mac.

## What is EAS Build?

**EAS Build** = Cloud service that builds iOS apps on Mac servers

- Build iOS on Windows ✅
- Direct to TestFlight ✅
- $1 per build ✅
- Takes ~15-20 minutes ✅

## Prerequisites

- Node.js installed (download from nodejs.org)
- Git installed
- Apple Developer account ($99/year)
- Expo account (free, created during setup)

## Step 1: Install EAS CLI

```bash
npm install -g eas-cli

# Verify installation
eas --version
```

## Step 2: Create Expo Account

Go to: https://expo.dev and create account (free)

## Step 3: Set Up Your Project

```bash
cd yatrawalk

# Ensure everything is committed
git status
git add .
git commit -m "Ready for iOS build"
```

## Step 4: Initialize EAS

```bash
# Login to Expo
eas login

# Follow prompts:
# - Email
# - Password
# - Create account if needed

# Configure for iOS
eas build:configure --platform ios

# Generates eas.json file
```

## Step 5: Review eas.json

File created: `eas.json`

```json
{
  "build": {
    "preview": {
      "ios": {
        "buildType": "simulator"
      }
    },
    "preview2": {
      "ios": {
        "buildType": "simulator"
      }
    },
    "preview3": {
      "ios": {
        "buildType": "simulator"
      }
    },
    "production": {
      "ios": {
        "buildType": "archive"
      }
    }
  }
}
```

Good to go!

## Step 6: Build for TestFlight

```bash
# Build and auto-submit to TestFlight
eas build --platform ios --auto-submit

# Or just build (no TestFlight yet):
eas build --platform ios
```

First time build:
- EAS creates signing certificate (automatic)
- Builds on cloud Mac (15-20 mins)
- Submits to App Store Connect (automatic)

## Step 7: What Happens Next

1. **Build starts** - You'll see status in terminal
2. **EAS builds on Mac** - ~15-20 minutes
3. **Submits to TestFlight** - Automatic
4. **You get notification** - Build complete!

Example output:
```
✓ Build finished
✓ Uploading to TestFlight...
✓ Success! View in App Store Connect
```

## Step 8: Configure TestFlight

Go to App Store Connect:

1. **My Apps** → YatraWalk (create if first time)
   - Platform: iOS
   - Name: YatraWalk
   - Bundle ID: com.yatrawalk (or your id)

2. **TestFlight** → **iOS Builds**
   - Your build appears automatically
   - Wait for "Ready to Test" status

3. **Create Test Group**
   - Name: "Friends"
   - Add friend emails

4. **Send Invites**
   - Friends get email
   - They download via TestFlight app

## Step 9: Friends Install

Friends should:

1. **Download TestFlight** from App Store
2. **Open email invite** on iPhone
3. **Tap link** → Opens TestFlight
4. **Tap Install** → App installs
5. **Grant permissions** when prompted
6. **Ready to use!**

## Step 10: Update App

When you make changes:

```bash
# 1. Commit changes on Windows
git add .
git commit -m "Fix xyz"

# 2. Update build number in eas.json (increment "resourceClass")
# Or just run build again

# 3. Build and submit again
eas build --platform ios --auto-submit
```

Testers get notification of new version!

## Troubleshooting

### "eas: command not found"
```bash
# Reinstall EAS
npm install -g eas-cli --force
```

### "Not authenticated"
```bash
# Login again
eas login
```

### Build fails
```bash
# Clean and retry
flutter clean
flutter pub get
eas build --platform ios
```

### Can't find Apple Developer account
- Go to App Store Connect
- Sign in with Apple ID
- Create App ID if needed
- Re-run build

### Testers don't see build
- Wait for TestFlight status = "Ready to Test"
- Confirm tester emails are correct
- Check TestFlight app is installed on iPhone

## Cost Breakdown

| Item | Cost |
|------|------|
| Apple Developer | $99/year (one-time) |
| EAS Build | $0.50-1.00 per build |
| Expo Account | Free |
| TestFlight | Free |

## Important Notes

✅ **EAS Build benefits:**
- Build iOS without Mac
- Direct to TestFlight
- No need to install Xcode
- Works from Windows, Mac, Linux

⚠️ **Requirements:**
- Apple Developer account ($99/year)
- Node.js installed
- Good internet connection
- Git installed

🔐 **Security:**
- EAS stores signing certificate securely
- Only you can access your builds
- Privacy policy: https://expo.dev/privacy

## Commands Reference

```bash
# Login
eas login

# Configure (first time only)
eas build:configure --platform ios

# Build and submit to TestFlight
eas build --platform ios --auto-submit

# Just build (don't submit)
eas build --platform ios

# Check build status
eas builds

# View build logs
eas builds --limit 1

# Get help
eas help build
```

## Full Workflow

```bash
# 1. Commit changes
git add .
git commit -m "Feature xyz"

# 2. Build iOS
eas build --platform ios --auto-submit

# 3. Wait 20 mins
# (EAS builds on their Mac servers)

# 4. Invite testers
# (Go to App Store Connect → TestFlight)

# 5. Friends install via TestFlight
```

## Next Build

```bash
# Each new build:
git add .
git commit -m "Update xyz"
eas build --platform ios --auto-submit
# Wait 20 mins
# Done!
```

## Resources

- [EAS Build Docs](https://docs.expo.dev/build/setup/)
- [Expo CLI Reference](https://docs.expo.dev/more/expo-cli/)
- [TestFlight Guide](https://help.apple.com/app-store-connect/#/dev301cb2b3e)
- [Flutter iOS Build](https://docs.flutter.dev/deployment/ios)

---

**TL;DR:** Install EAS, run `eas build --platform ios --auto-submit`, wait 20 mins, invite friends to TestFlight!
