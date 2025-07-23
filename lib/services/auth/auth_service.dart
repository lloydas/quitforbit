import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

import '../../config/oauth_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Web client ID from OAuth config
    clientId: OAuthConfig.googleClientIdWeb,
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔍 DEBUG: Starting Google sign-in...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('📧 DEBUG: Google user: ${googleUser?.email}');

      if (googleUser == null) {
        print('❌ DEBUG: User cancelled Google sign-in');
        return null;
      }

      print('🔑 DEBUG: Getting Google authentication...');
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('🔗 DEBUG: Creating Firebase credential...');
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔥 DEBUG: Signing in to Firebase...');
      // Once signed in, return the UserCredential
      final result = await _auth.signInWithCredential(credential);
      print('✅ DEBUG: Google sign-in successful: ${result.user?.email}');

      return result;
    } catch (e, stackTrace) {
      print('❌ DEBUG: Google sign-in error: $e');
      print('📍 DEBUG: Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Apple Sign In
  Future<UserCredential?> signInWithApple() async {
    try {
      print('🔍 DEBUG: Starting Apple sign-in...');

      // Check if Apple Sign-in is available
      if (!await SignInWithApple.isAvailable()) {
        print('❌ DEBUG: Apple Sign-in not available on this platform');
        throw Exception('Apple Sign-in not available');
      }

      // To prevent replay attacks with the credential returned from Apple, we
      // include a nonce in the credential request. When signing in with
      // Firebase, the nonce in the id token returned by Apple, is expected to
      // match the sha256 hash of the original nonce.
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      print('🔑 DEBUG: Generated nonce for Apple sign-in');

      print('🍎 DEBUG: Requesting Apple credential...');
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      print('📧 DEBUG: Apple credential received: ${appleCredential.email}');

      print('🔗 DEBUG: Creating Firebase credential...');
      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider(
        "apple.com",
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      print('🔥 DEBUG: Signing in to Firebase...');
      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final result = await _auth.signInWithCredential(oauthCredential);
      print('✅ DEBUG: Apple sign-in successful: ${result.user?.email}');

      return result;
    } catch (e, stackTrace) {
      print('❌ DEBUG: Apple sign-in error: $e');
      print('📍 DEBUG: Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Helper functions for Apple Sign In
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        await user.reload();
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Get user display name
  String? get userDisplayName => _auth.currentUser?.displayName;

  // Get user email
  String? get userEmail => _auth.currentUser?.email;

  // Get user photo URL
  String? get userPhotoURL => _auth.currentUser?.photoURL;
}
