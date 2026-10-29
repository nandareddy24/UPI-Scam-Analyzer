import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth so screens don't touch the SDK directly.
/// The OTP step (see otp_api_service.dart) happens BEFORE we ever call
/// createUserWithEmailAndPassword — by the time this runs, the email is
/// already verified via our own OTP flow.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AuthResult> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult(success: true, user: cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _friendlyError(e));
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult(success: true, user: cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _friendlyError(e));
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists for this email. Try logging in instead.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}

class AuthResult {
  final bool success;
  final User? user;
  final String? message;
  AuthResult({required this.success, this.user, this.message});
}
