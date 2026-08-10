# Cloud Data Sync Implementation Plan

## Overview
Implement comprehensive Firebase Firestore sync for all user data to enable multi-device support and data persistence.

## Firestore Data Model (New)

```
users/{uid}/
  ├── profile/
  │   ├── name, email, phone, dailyGoal, age, height, weight
  │   ├── createdAt, updatedAt
  │   └── (mirrors local profile)
  │
  ├── step_history/{date}
  │   ├── steps: int
  │   ├── date: string (YYYY-MM-DD)
  │   └── lastUpdated: timestamp
  │
  ├── journeys/{journeyId}
  │   ├── id, startLocation, destinationName, destinationLocation
  │   ├── latitude, longitude, totalDistanceKm
  │   ├── startDate, startStepsSnapshot
  │   ├── sankalp, completed
  │   ├── createdAt, updatedAt
  │   └── (full journey sync)
  │
  ├── sankalp_checkins/{journeyId}_{date}
  │   ├── journeyId, date, checkedIn: bool
  │   └── timestamp
  │
  ├── mantra_recitations/{mantraId}_{date}
  │   ├── mantraId, date, recitedAt: timestamp
  │   └── (sparse - only recorded dates)
  │
  └── onboarding/
      ├── completed: bool
      ├── completedAt: timestamp
      └── (single doc per user)

families/{familyId}/
  ├── name, inviteCode, createdBy, createdAt
  └── members/{uid}
      ├── name, avatarEmoji, totalSteps, todaySteps, updatedAt
      └── (already implemented)
```

## Implementation Tasks

### Phase 1: Foundation (Days 1-2)
- [ ] Update AuthService to ensure full user profile doc exists
- [ ] Update UserProfileService to sync profile to cloud
- [ ] Create StepHistoryService for cloud sync
- [ ] Create JourneyCloudService for cloud operations

### Phase 2: Data Sync (Days 2-4)
- [ ] Update StepService to sync daily history
- [ ] Update JourneyService to sync journeys
- [ ] Update SankalpService to sync check-ins
- [ ] Update MantraService to sync recitations

### Phase 3: Multi-device Support (Days 4-5)
- [ ] Update StartupScreen to pull onboarding status from cloud
- [ ] Add conflict resolution for profile conflicts
- [ ] Handle offline scenarios gracefully

### Phase 4: Security & Testing (Days 5-6)
- [ ] Create Firestore security rules
- [ ] Test multi-device sync
- [ ] Test offline mode
- [ ] Performance testing

## Implementation Details

### AuthService Changes
- Expand user doc creation to include all fields
- Mark document structure version for migrations

### StepService Changes
- After daily step recording, push to `users/{uid}/step_history/{date}`
- No blocking - fail silently if network down
- Pull history on app start for cross-device consistency

### JourneyService Changes
- After journey creation/update, sync to `users/{uid}/journeys/{journeyId}`
- Allow local-first writes, background sync
- Pull journeys from cloud on startup

### Cloud-First vs Local-First Strategy
**DECISION**: Local-first with background sync
- Local SharedPreferences is always source of truth
- Cloud is asynchronous mirror
- Network failures don't block user experience
- On startup, merge cloud data back to device

## Testing Checklist
- [ ] Create journey on Device A, see it on Device B
- [ ] Delete journey on Device A, reflected on Device B
- [ ] Step sync works with poor network
- [ ] Offline mode still works (caches sync until online)
- [ ] No data loss on logout/login
- [ ] Profile sync consistent across devices
- [ ] Sankalp check-ins sync
- [ ] Mantra recitations sync

## Risk Mitigation
- All cloud writes are fire-and-forget (no blocking)
- Local data always works, cloud sync is best-effort
- Version migrations planned for future data model changes
- Conflict resolution: Device timestamp wins (last write wins)
