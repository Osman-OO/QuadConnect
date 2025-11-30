import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/models/user_model.dart';
import '../core/constants/app_constants.dart';

/// Authentication result with optional error message
class AuthResult {
  final bool success;
  final String? errorMessage;
  final UserModel? user;

  AuthResult({required this.success, this.errorMessage, this.user});

  factory AuthResult.failure(String message) =>
      AuthResult(success: false, errorMessage: message);

  factory AuthResult.successful(UserModel user) =>
      AuthResult(success: true, user: user);
}

/// Handles all authentication logic for QuadConnect
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current Firebase user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create the auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return AuthResult.failure(
          'Failed to create account. Please try again.',
        );
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);

      // Create user document in Firestore
      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email.trim(),
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

      return AuthResult.successful(userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return AuthResult.failure('Failed to sign in. Please try again.');
      }

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return AuthResult.failure('User profile not found.');
      }

      // Update last active
      await userDoc.reference.update({
        'lastActive': FieldValue.serverTimestamp(),
      });

      return AuthResult.successful(UserModel.fromFirestore(userDoc));
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  // Note: Google Sign-In v7+ requires new initialization patterns.
  // For this MVP, we focus on email/password auth which is working.
  // Google auth can be added after platform-specific configuration.

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(
        'Failed to send reset email. Please try again.',
      );
    }
  }

  /// Get current user model
  Future<UserModel?> getCurrentUserModel() async {
    if (currentUser == null) return null;

    final doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(currentUser!.uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Convert Firebase Auth error codes to friendly messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password sign in is not enabled.';
      case 'weak-password':
        return 'Please choose a stronger password (at least 8 characters).';
      case 'user-disabled':
        return 'This account has been disabled. Contact support for help.';
      case 'user-not-found':
        return 'No account found with this email. Sign up to get started!';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
