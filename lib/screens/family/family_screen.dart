import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/family_service.dart';
import 'create_or_join_family_screen.dart';
import 'family_leaderboard_screen.dart';
import 'family_sign_in_screen.dart';

/// Top-level router for the Family tab:
///
/// not signed in -> [FamilySignInScreen]
/// signed in, no family yet -> [CreateOrJoinFamilyScreen]
/// signed in, has a family -> [FamilyLeaderboardScreen]
///
/// The rest of the app (Steps, Yatra tracking) never needs an account -
/// this is the only feature that requires one, because it's the only one
/// that needs data to be visible across more than one phone.
class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const FamilySignInScreen();
        }

        return const _FamilyMembershipRouter();
      },
    );
  }
}

class _FamilyMembershipRouter extends StatelessWidget {
  const _FamilyMembershipRouter();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: FamilyService().watchMyFamilyId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }

        final familyId = snapshot.data;

        if (familyId == null) {
          return const CreateOrJoinFamilyScreen();
        }

        return FamilyLeaderboardScreen(familyId: familyId);
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF8F0),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
