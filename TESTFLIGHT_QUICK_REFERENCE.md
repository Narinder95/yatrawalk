# TestFlight Quick Reference

## 🚀 Quick Steps (5-10 mins per build)

### On Mac:

```bash
# 1. Pull latest code
git pull

# 2. Update version in pubspec.yaml
# Change: version: 1.0.0+2  (increment +2 to +3, etc)

# 3. Build
flutter pub get
flutter build ios --release

# 4. Open Xcode
open ios/Runner.xcworkspace

# 5. Archive
# Product → Archive → Distribute → Continue → Upload
```

### In App Store Connect:

1. Wait for build (15-30 mins)
2. TestFlight → iOS Builds
3. Select build → Add Groups
4. Select "Friends" group
5. Testers get notification!

---

## 📱 For Your Friends

**To install YatraWalk beta:**

1. Open the email invite on iPhone
2. Tap "View in TestFlight"
3. Tap "Install" 
4. Grant permissions (Motion, Location, Health)
5. Done! App ready to use

---

## 🔄 Update Cycle

| Step | Time | Action |
|------|------|--------|
| Code | 5 min | Make changes on Windows |
| Build | 2 min | `flutter build ios --release` on Mac |
| Archive | 5 min | Product → Archive in Xcode |
| Upload | 2 min | Distribute → Upload in Xcode |
| Process | 20 min | App Store Connect processes build |
| Notify | 1 min | Testers get notification |

**Total: ~35 minutes per update**

---

## 🎯 Before First Build

- [ ] Apple Developer account ($99/year)
- [ ] Mac with Xcode
- [ ] Signing certificate created
- [ ] App ID created
- [ ] TestFlight group created
- [ ] Friend emails collected

---

## 🔐 Permissions Your App Needs

iOS will prompt users for:

✅ **Motion & Fitness** - For step counting
✅ **Location** - For map features (if using)
✅ **Calendar** - For journey dates (if needed)
✅ **Notifications** - For reminders

All configured in `ios/Runner/Info.plist` ✓

---

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Build fails | `flutter clean && flutter pub get` |
| No signing cert | Xcode → Preferences → Accounts → Add certificate |
| Build not showing | Wait 20-30 mins, refresh |
| Tester can't install | Check TestFlight app installed, iOS 14+, email correct |
| Crash on launch | Check Info.plist permissions, Firebase config |

---

## 📊 TestFlight Stats

- **Cost:** Free
- **Testers:** Up to 10,000 external
- **Test Duration:** 90 days per build
- **Processing Time:** 15-30 minutes per build
- **Feedback:** Testers can message you in TestFlight

---

## 🎁 What Testers See

```
YatraWalk
↓
Version 1.0.0 (Build 2)
↓
[Install Button]
↓
"Awaiting Download..."
↓
Ready to use!
```

---

## 📝 Version Numbering

```
pubspec.yaml:
version: 1.0.0+2

Format: MAJOR.MINOR.PATCH+BUILD
- 1.0.0 = Your version
- +2 = Increment each TestFlight build
  - First build: +1
  - Second build: +2
  - etc.
```

---

## ✨ Pro Tips

1. **Always increment build number** or archive will fail
2. **Keep builds short** - 2-3 weeks between updates
3. **Message testers** via TestFlight about what to test
4. **Collect feedback** via email or TestFlight messages
5. **Fix crashes immediately** - upload new build quickly

---

## 🚀 One-Liner Reminder

```bash
# Mac command to remember:
git pull && flutter pub get && flutter build ios --release && open ios/Runner.xcworkspace
```

Then in Xcode: `Product → Archive → Distribute → Upload`

---

**Start with first build, then use this reference for updates!**
