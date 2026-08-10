import 'package:flutter/material.dart';

import '../../models/family_member.dart';
import '../../services/auth_service.dart';
import '../../services/family_service.dart';

class FamilyLeaderboardScreen extends StatefulWidget {
  final String familyId;

  const FamilyLeaderboardScreen({super.key, required this.familyId});

  @override
  State<FamilyLeaderboardScreen> createState() =>
      _FamilyLeaderboardScreenState();
}

class _FamilyLeaderboardScreenState extends State<FamilyLeaderboardScreen> {
  String? _familyName;
  String? _inviteCode;

  @override
  void initState() {
    super.initState();

    // Start pushing this device's live steps up to the shared family doc.
    FamilyService().startSyncingSteps(widget.familyId);

    FamilyService().getFamilyInfo(widget.familyId).then((info) {
      if (!mounted || info == null) return;
      setState(() {
        _familyName = info['name'] as String?;
        _inviteCode = info['inviteCode'] as String?;
      });
    });
  }

  @override
  void dispose() {
    FamilyService().stopSyncingSteps();
    super.dispose();
  }

  void _showInviteCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Invite a family member"),
        content: Text(
          "Share this code so they can join ${_familyName ?? 'your family'}:"
          "\n\n${_inviteCode ?? '...'}",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLeaveFamily() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Leave this family?"),
        content: const Text(
          "You'll stop sharing your steps with this group. You can rejoin "
          "later with the invite code.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Leave"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FamilyService().leaveFamily(widget.familyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(_familyName ?? "Family Yatra"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            tooltip: "Invite family",
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: _showInviteCode,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'leave') _confirmLeaveFamily();
              if (value == 'signout') AuthService().signOut();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'leave', child: Text("Leave family")),
              PopupMenuItem(value: 'signout', child: Text("Sign out")),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<FamilyMember>>(
        stream: FamilyService().watchFamilyMembers(widget.familyId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _FamilyLoadError(error: snapshot.error);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final members = [...snapshot.data!]
            ..sort((a, b) => b.totalSteps.compareTo(a.totalSteps));

          final combinedSteps =
              members.fold<int>(0, (sum, m) => sum + m.totalSteps);
          final combinedKm = combinedSteps * 0.0008;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF9800), Color(0xFFF4511E)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Combined Family Steps",
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$combinedSteps",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${combinedKm.toStringAsFixed(1)} km walked together",
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Leaderboard",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              if (members.length == 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "It's just you so far - tap the invite icon above to "
                    "bring your family in! 🙏",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ...members.asMap().entries.map((entry) {
                return _LeaderboardTile(rank: entry.key + 1, member: entry.value);
              }),
            ],
          );
        },
      ),
    );
  }
}

class _FamilyLoadError extends StatelessWidget {
  final Object? error;

  const _FamilyLoadError({this.error});

  @override
  Widget build(BuildContext context) {
    final isPermissionError =
        error.toString().toLowerCase().contains('permission-denied');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 40, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              isPermissionError
                  ? "Couldn't load your family's steps"
                  : "Something went wrong loading this family",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isPermissionError
                  ? "This is a Firestore security rules issue, not a bug in "
                      "your data - the app's Cloud Firestore rules need to "
                      "allow signed-in users to read family member documents."
                  : "Please check your connection and try again.",
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final FamilyMember member;

  const _LeaderboardTile({required this.rank, required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: member.isCurrentUser
            ? Border.all(color: Colors.deepOrange, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              "#$rank",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.orange.shade50,
            child: Text(member.avatarEmoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.isCurrentUser ? "${member.name} (You)" : member.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${member.distanceKm.toStringAsFixed(1)} km walked",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            "${member.totalSteps}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }
}
