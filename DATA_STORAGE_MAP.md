# YatraWalk Data Storage Map

## 📍 Overview

The app uses **hybrid storage**: Most user data is stored **locally** (device-only), while **social/family features** sync to **Firebase Firestore**.

---

## ☁️ FIREBASE ONLINE DATA

### Firestore Collection: `users/{uid}`

This is created for every signed-in user. Contains:

```json
{
  "uid": "Firebase Auth UID",
  "name": "User's display name",
  "email": "User's email address",
  "phoneNumber": "User's phone (if phone auth)",
  "familyId": "ID of family group (null if not joined)",
  
  // Profile info (mirrored from local profile)
  "dailyGoal": 10000,
  "age": 28,
  "heightCm": 175.5,
  "weightKg": 75.0,
  
  "createdAt": "server timestamp"
}
```

**Source**: 
- Created in `AuthService.signUp()` (email signup)
- Created in `AuthService.ensureUserDocExists()` (phone signup)
- Updated in `UserProfileService.saveProfile()` (best-effort sync)

**Update Frequency**: Only when user edits profile or joins family

**Sync Behavior**: Local SharedPreferences is source of truth; Firebase is optional mirror (errors ignored)

---

### Firestore Collection: `families/{familyId}`

One doc per family group. Contains:

```json
{
  "name": "Our Family",
  "inviteCode": "ABC123",  // 6-char code for joining
  "createdBy": "uid of family creator",
  "createdAt": "server timestamp"
}
```

**Sub-collection**: `families/{familyId}/members/{uid}`

Each family member's real-time stats:

```json
{
  "uid": "Family member's Firebase UID",
  "name": "Member's display name",
  "avatarEmoji": "🧑",
  "totalSteps": 45230,        // All-time steps from device
  "todaySteps": 8920,          // Today's steps from device
  "updatedAt": "server timestamp"  // When this was last synced
}
```

**Source**:
- Created in `FamilyService.createFamily()` (user creates family)
- Created in `FamilyService.joinFamilyByCode()` (user joins with invite code)
- **Continuously updated** in `FamilyService.startSyncingSteps()` via `_pushMyStats()`

**Update Frequency**: Real-time - whenever step count changes (live-synced)

**Sync Behavior**: Device is source of truth; Firebase is kept current for leaderboard

---

## 💾 LOCAL STORAGE ONLY (SharedPreferences)

### User Profile
**Key**: `user_profile`
- Stores: name, age, height, weight, daily step goal
- Source: Local only, with optional best-effort mirror to Firebase
- Sync: One-way to Firebase (never pulls back)

### Step History
**Key**: `daily_step_history` (JSON)
- Stores: Map of `{date: steps}` for last 90 days
- Used for: Calculating streak days
- Local only (not synced to cloud)

### Today's Steps
**Key**: `today_steps`
- Current day's step count from device sensor
- Never synced to cloud directly (only via family leaderboard if in a family)

### Journey/Yatra Data
**Key**: `journeys` (JSON list)
- All user journeys (past, current, archived)
- Stores: destination, start date, sankalp, progress, distance
- Local only - NOT synced to Firebase
- **Note**: This is a critical gap for multi-device support

### Onboarding Status
**Key**: `hasCompletedOnboarding`
- Boolean flag
- Local only - per device

### Profile Setup Status
**Key**: `hasCompletedProfileSetup`
- Boolean flag
- Local only - per device

### Sankalp Daily Check-ins
**Key**: `sankalp_checkin_{journeyId}_{date}`
- Boolean: whether user "recited" their Sankalp today
- Local only - not synced

### Mantra Recitations
**Key**: `mantra_recitations` (JSON)
- List of `{mantraId, date}` when user recited each mantra
- Local only - not synced

### Step Sensor State
**Keys**: 
- `step_date` - Today's date
- `initial_sensor_steps` - Device sensor value at start of day
- `total_steps_before_today` - All-time bank from previous days

---

## 🔗 Firebase Authentication

**Service**: Firebase Auth (Email + Password + Phone OTP)

**Stored**:
- Email address
- Phone number
- Display name
- UID (unique identifier)
- Password (hashed, managed by Firebase)

**Access**: Used for:
- Login/signup
- User identification across devices
- Cross-device profile sync (via `users/{uid}`)

---

## 📊 Data Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    YatraWalk User                       │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  DEVICE A (Local)              DEVICE B (Local)          │
│  ─────────────────             ─────────────────         │
│  • Journeys                    • Journeys                │
│  • Steps history               • Steps history           │
│  • Sankalp check-ins           • Sankalp check-ins       │
│  • Mantra recitations          • Mantra recitations      │
│  • Profile (cached)            • Profile (cached)        │
│                                                           │
│         ↓ (Sync Up)                   ↓ (Sync Up)        │
│         └───────────────┬───────────────┘               │
│                         ↓                                │
│            ┌──────────────────────┐                      │
│            │  Firebase Online     │                      │
│            ├──────────────────────┤                      │
│            │ users/{uid}          │ ◄─ Profile sync      │
│            │ • name               │     (best-effort)    │
│            │ • email              │                      │
│            │ • familyId           │                      │
│            │ • dailyGoal          │                      │
│            │ • age, height, weight│                      │
│            │                      │                      │
│            │ families/{familyId}  │ ◄─ If in family:     │
│            │  └─ members/{uid}    │     Live step sync   │
│            │     • totalSteps     │                      │
│            │     • todaySteps     │                      │
│            │     • updatedAt      │                      │
│            └──────────────────────┘                      │
│                      ↑                                   │
│            Pull for: Leaderboard, Family info           │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## ⚠️ CRITICAL DATA GAPS & SYNC ISSUES

### 1. **Journeys NOT Synced to Cloud** 🔴
- User's journey history (completed Yatras) is local-only
- **Problem**: If user uninstalls/switches devices, all journey history is lost
- **Recommendation**: Sync journey data to `users/{uid}/journeys/{journeyId}` collection

### 2. **Multi-Device Profile Inconsistency**
- Profile setup status (`hasCompletedProfileSetup`) is local
- User might need to re-setup profile on each device
- **Recommendation**: Query `users/{uid}` to check if profile exists instead of local flag

### 3. **No Cross-Device Journey Sync**
- If user is on Yatra on Device A, Device B won't know about it
- Step counts work locally, but journey context is lost
- **Recommendation**: Store active journey ID on cloud, sync to all devices

### 4. **Sankalp Daily Check-ins Not Persistent**
- Stored locally only
- Not backed up to cloud
- **Recommendation**: Sync to `users/{uid}/sankalp_checkins/{date}`

### 5. **Onboarding Per-Device**
- Each device has its own onboarding state
- User needs to re-onboard on new device
- **Recommendation**: Set a flag in `users/{uid}` for onboarding completion

### 6. **No Account Recovery**
- Journeys, steps, mantras all lost if app data is cleared
- No export or account backup mechanism
- **Recommendation**: Add data export/import feature

---

## 🔒 Privacy & Permissions Implications

### What's Shared in Family Mode
When user joins a family:
- Display name
- Avatar emoji
- Total steps (all-time)
- Today's steps
- Last updated timestamp

### What's NOT Shared
- Email address
- Phone number
- Individual journey details
- Mantra recitation history
- Sankalp text
- Age, height, weight (except for profile display)

### What Can Be Inferred
- Rough activity level from step counts
- Time zones (from updatedAt timestamps)
- Device switching patterns

---

## 📱 Firebase Firestore Rules

**Current state**: Not reviewed in this analysis

**Should implement**:
- Users can only read/write their own `users/{uid}` doc
- Members can read family members' stats but not modify
- Family creator can delete family
- Prevent uid spoofing (use Firebase Auth UID as document owner)

---

## 🚀 Recommendations Before Release

### High Priority (Do Before Release)
1. ✅ Implement journey data sync to cloud
2. ✅ Add Firestore security rules
3. ✅ Decide: Cloud vs Local priority for profile conflicts

### Medium Priority (First Update)
4. ✅ Sync sankalp check-ins to cloud
5. ✅ Centralize onboarding status to cloud
6. ✅ Fix multi-device profile inconsistency

### Low Priority (Future)
7. Data export/import feature
8. Account recovery mechanism
9. Analytics dashboard (anonymous step trends)

---

## 📋 Summary Table

| Data Type | Storage | Synced | Real-time | Multi-device |
|-----------|---------|--------|-----------|--------------|
| Profile (name, age, etc) | Local + Cloud | Best-effort | No | ❌ Conflicts |
| Journey history | Local only | ❌ | No | ❌ Lost |
| Daily steps | Local + Cloud (if family) | Via family | ✅ Yes | ✅ (family) |
| Sankalp check-ins | Local only | ❌ | No | ❌ Lost |
| Mantra recitations | Local only | ❌ | No | ❌ Lost |
| Family member stats | Cloud only | ✅ Real-time | ✅ Yes | ✅ Yes |
| Auth tokens | Cloud (Firebase) | N/A | ✅ Real-time | ✅ Yes |
| Onboarding status | Local only | ❌ | No | ❌ Per-device |

---

**Generated**: Pre-release analysis
**Status**: Document the cloud data sync architecture to inform release decisions
