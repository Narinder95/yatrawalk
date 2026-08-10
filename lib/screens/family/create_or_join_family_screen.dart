import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/family_service.dart';

class CreateOrJoinFamilyScreen extends StatefulWidget {
  const CreateOrJoinFamilyScreen({super.key});

  @override
  State<CreateOrJoinFamilyScreen> createState() =>
      _CreateOrJoinFamilyScreenState();
}

class _CreateOrJoinFamilyScreenState extends State<CreateOrJoinFamilyScreen> {
  final _familyNameController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  bool _isCreating = false;
  bool _isJoining = false;
  String? _errorText;

  @override
  void dispose() {
    _familyNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _createFamily() async {
    setState(() {
      _isCreating = true;
      _errorText = null;
    });

    try {
      await FamilyService().createFamily(_familyNameController.text);
      // FamilyScreen's StreamBuilder on watchMyFamilyId() will pick this up
      // automatically and swap to the leaderboard.
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = _friendlyFamilyError(e));
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _joinFamily() async {
    setState(() {
      _isJoining = true;
      _errorText = null;
    });

    try {
      await FamilyService().joinFamilyByCode(_inviteCodeController.text);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = _friendlyFamilyError(e));
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  String _friendlyFamilyError(Object e) {
    final message = e.toString().replaceFirst("Bad state: ", "");
    if (message.toLowerCase().contains('permission-denied')) {
      return "Couldn't reach your family's data (Firestore security rules "
          "need to allow signed-in reads/writes). Ask whoever set up the "
          "app's Firebase project to check the rules.";
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text("Family Yatra"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            tooltip: "Sign out",
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Start or join a family",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Create a new family group, or join one with an invite code "
              "from a family member.",
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),

            // --- Create a family ---
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Create a new family",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _familyNameController,
                    decoration: const InputDecoration(
                      labelText: "Family name (e.g. The Sharmas)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isCreating ? null : _createFamily,
                      child: _isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Create Family"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text("or", style: TextStyle(color: Colors.grey.shade600)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),

            // --- Join a family ---
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Join with an invite code",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _inviteCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: "6-character invite code",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _isJoining ? null : _joinFamily,
                      child: _isJoining
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Join Family"),
                    ),
                  ),
                ],
              ),
            ),

            if (_errorText != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
