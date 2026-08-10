# YatraWalk iOS App - TestFlight Distribution Guide

This guide walks you through building and distributing your iOS app via TestFlight to friends.

## Prerequisites

- Mac with Xcode installed
- Apple Developer Account ($99/year)
- App ID created in Apple Developer
- TestFlight configured

## Step 1: Prepare on Windows (Your Current Machine)

All code is ready! Just ensure everything is committed:

```bash
git status  # Should show no uncommitted changes
```

## Step 2: Transfer to Mac

Copy your project to a Mac:

```bash
# Option A: Via Git (recommended)
git clone <your-repo-url> yatrawalk
cd yatrawalk

# Option B: Via USB/Cloud
# Just copy the entire project folder
```

## Step 3: Build on Mac

On your Mac with Xcode installed:

```bash
cd yatrawalk

# Install dependencies
flutter pub get

# Build iOS release
flutter build ios --release

# For TestFlight, you might need a build number bump:
# Edit pubspec.yaml:
#   version: 1.0.0+2  (increment the +2 part each build)

flutter build ios --release
```

Output: `build/ios/iphoneos/Runner.app`

## Step 4: Open in Xcode

```bash
open ios/Runner.xcworkspace
```

**Important:** Always use `.xcworkspace`, not `.xcodeproj`

## Step 5: Configure Signing

In Xcode:

1. **Select "Runner" project** (left sidebar)
2. **Select "Runner" target**
3. **Go to "Signing & Capabilities"**
4. **Team:** Select your Apple Developer account
5. **Bundle Identifier:** com.yourname.yatrawalk (or similar)

### Create Signing Certificate (if needed)

If you don't have a signing certificate:

1. Xcode → Preferences → Accounts
2. Add your Apple Developer account
3. Click "Manage Certificates"
4. Click "+" → "iOS Development"

## Step 6: Build Archive for TestFlight

In Xcode:

1. **Product → Scheme → Select "Runner"**
2. **Product → Destination → Generic iOS Device**
3. **Product → Archive**
4. Wait for build to complete
5. When "Organizer" opens, select your archive
6. Click **"Distribute App"**

### Distribution Steps:

1. **Method of Distribution:** "App Store Connect"
2. **Team:** Select your account
3. **Signing:** "Automatically manage signing"
4. **Review:** Confirm details
5. **Upload:** Let it upload to App Store Connect

## Step 7: Configure TestFlight

### In App Store Connect (https://appstoreconnect.apple.com):

1. **My Apps** → Create new app (if first time)
   - Platform: iOS
   - Name: YatraWalk
   - Bundle ID: com.yourname.yatrawalk
   - SKU: yatrawalk_001

2. **TestFlight** → **iOS Builds**
   - Your build should appear automatically (wait 15-30 mins)
   - Click the build → "Add Groups"

3. **Create Test Group**
   - Name: "Friends" or "Beta Testers"
   - Add emails of testers

4. **Export Compliance**
   - Answer questions (usually "No" for most)
   - Continue

5. **Contact Information**
   - Fill in your details

## Step 8: Invite Testers

In App Store Connect → TestFlight:

1. **Internal Testers:** Add your team members
   - They get instant access via TestFlight app

2. **External Testers:** Add friend emails
   - Limit: 10,000 external testers
   - They get email invite
   - Must accept via TestFlight app link

### Email Testers Get:

```
Subject: You're invited to test YatraWalk

Hi [Friend],

You're invited to test YatraWalk beta on iOS!

1. Download TestFlight from App Store
2. Open this link on your iPhone:
   [TestFlight Invite Link]
3. Accept the invitation
4. Tap "Install" for YatraWalk
5. Install completes!
```

## Step 9: Friends Install the App

Friends should:

1. **Get email invite** from you
2. **Tap link on iPhone** (opens TestFlight)
3. **Download TestFlight app** from App Store (if needed)
4. **Search for "YatraWalk"** in TestFlight
5. **Tap "Install"**
6. App installs!

### TestFlight Limits:

- ✅ Free to use
- ✅ Up to 90 days per build
- ✅ 10,000 external testers
- ✅ Unlimited internal testers
- ⚠️ App must be complete (can't have placeholder features)

## Step 10: Update Builds for TestFlight

When you make changes:

1. **On Windows:** Commit changes to git
2. **On Mac:** 
   ```bash
   git pull  # Get latest changes
   flutter pub get
   
   # Bump build number in pubspec.yaml
   # version: 1.0.0+3  (increment +3, etc)
   
   flutter build ios --release
   open ios/Runner.xcworkspace
   ```
3. **In Xcode:** Product → Archive → Distribute

4. **In App Store Connect:** New build appears → Add to test group → Testers get notification

## Important Checklist Before TestFlight

- [ ] iOS permissions set (Motion, Health, Location if needed)
- [ ] App name, icon, and description ready
- [ ] TestFlight screenshots added (optional but recommended)
- [ ] Privacy Policy URL (required for TestFlight)
- [ ] Firebase configured for iOS
- [ ] All crashes fixed
- [ ] Build number incremented
- [ ] Code signed with development certificate

## Firebase Setup for iOS

Your Firebase config is already in:
- `ios/Runner/GoogleService-Info.plist`

Make sure it's in Xcode:
1. Open Xcode
2. Select "Runner" → "Build Phases"
3. Check "Copy Bundle Resources" includes `GoogleService-Info.plist`

## Testing Checklist for Friends

Share this with your testers:

```
Please test and report:
- [ ] App installs and launches
- [ ] Login/signup works
- [ ] Steps are tracked (grant motion permission)
- [ ] Can start a new journey
- [ ] Map view works
- [ ] Can view steps history
- [ ] Mantras load
- [ ] Family features work
- [ ] Data syncs to cloud
- [ ] No crashes or errors
```

## Troubleshooting

### Build fails in Xcode
```bash
# On Mac, clean and rebuild
flutter clean
flutter pub get
flutter build ios --release
```

### "No signing certificate found"
- Xcode → Preferences → Accounts
- Add Apple Developer account
- Create signing certificate

### Build hangs during archive
- Wait 10+ minutes (large app)
- Or restart Xcode and try again

### Testers don't see app
- Check TestFlight build status (might still processing)
- Confirm tester email is correct
- Testers must have iOS 14+

### Crash on launch
- Check Xcode console for errors
- Check `ios/Runner/Info.plist` has required permissions
- Make sure GoogleService-Info.plist is included

## Next Steps

1. **Get Mac access** (yours or friend's)
2. **Set up Apple Developer account** ($99/year)
3. **Build and archive** iOS app
4. **Upload to TestFlight** via App Store Connect
5. **Invite friends** via TestFlight
6. **Gather feedback** and iterate
7. **Fix bugs** and upload new builds
8. **(Optional) Submit to App Store** after testing

## App Store Submission (Later)

Once TestFlight is stable, you can submit to App Store:

1. Complete app info in App Store Connect
2. Add screenshots and description
3. Set pricing
4. Submit for review (takes 1-3 days)
5. App goes live!

## Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [TestFlight Guide](https://help.apple.com/app-store-connect/#/dev301cb2b3e)
- [Flutter iOS Build](https://docs.flutter.dev/deployment/ios)
- [Firebase for iOS](https://firebase.google.com/docs/ios/setup)

---

**Your app is ready for iOS! Build on Mac and distribute via TestFlight.** 🚀
