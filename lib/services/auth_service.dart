import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around Firebase Auth (email/password) used by the Family
/// feature. The rest of the app (steps, Yatra tracking) stays fully local
/// and never needs to touch this - only Family sync requires an account.
class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name.trim());

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'phoneNumber': null,
      'familyId': null,
      'dailyGoal': 10000,
      'age': null,
      'heightCm': null,
      'weightKg': null,
      'onboardingCompleted': false,
      'profileSetupCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Starts phone verification. [onCodeSent] is called with the
  /// verificationId once Firebase has sent the OTP SMS. [onAutoVerified]
  /// fires on Android if the SMS is auto-read and no manual code entry is
  /// needed. [onFailed] surfaces a user-readable error.
  Future<void> startPhoneVerification({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function() onAutoVerified,
    required void Function(String message) onFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber.trim(),
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        onAutoVerified();
      },
      verificationFailed: (FirebaseAuthException e) {
        onFailed(friendlyError(e));
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> confirmOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Ensures a complete `users/{uid}` Firestore doc exists for the signed-in
  /// user with all required fields for multi-device sync (covers phone
  /// sign-in, which doesn't go through [signUp]).
  Future<void> ensureUserDocExists() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = _firestore.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'name': user.displayName ?? '',
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'familyId': null,
        'dailyGoal': 10000,
        'age': null,
        'heightCm': null,
        'weightKg': null,
        'onboardingCompleted': false,
        'profileSetupCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Turns a raw FirebaseAuthException into copy a user can actually read.
  String friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'That email is already registered. Try signing in instead.';
        case 'invalid-email':
          return 'That email address looks invalid.';
        case 'weak-password':
          return 'Please choose a stronger password (6+ characters).';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'invalid-phone-number':
          return 'That phone number looks invalid. Include country code, e.g. +91XXXXXXXXXX.';
        case 'invalid-verification-code':
          return 'That code is incorrect. Please check and try again.';
        case 'session-expired':
        case 'code-expired':
          return 'This code expired. Please request a new one.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return error.message ?? 'Something went wrong. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
