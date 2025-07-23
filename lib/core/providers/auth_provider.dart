import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth/auth_service.dart';
import '../../services/firestore/firestore_service.dart';
import '../../models/user_model.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Stream provider for Firebase Auth state
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user provider with UserModel
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final firestoreService = ref.read(firestoreServiceProvider);

  return authState.when(
    data: (firebaseUser) {
      if (firebaseUser == null) {
        return Stream.value(null);
      } else {
        return firestoreService.getUserStream(firebaseUser.uid);
      }
    },
    loading: () => Stream.value(null),
    error: (error, stackTrace) {
      print('Error in currentUserProvider: $error');
      return Stream.value(null);
    },
  );
});

// Auth notifier for handling authentication actions
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier(this._authService, this._firestoreService)
    : super(const AsyncValue.loading());

  final AuthService _authService;
  final FirestoreService _firestoreService;

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();

      final userCredential = await _authService.signInWithGoogle();

      if (userCredential?.user != null) {
        final user = userCredential!.user!;

        // Create or update user in Firestore
        final userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoUrl: user.photoURL,
          isPremiumUser: false,
          bitcoinWalletAddress: '',
          onboardingData: {},
          paidMilestones: [],
          preferences: {'notifications': true, 'analytics': true},
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestoreService.createUser(userModel);

        // Log analytics event
        await _firestoreService.logAnalyticsEvent('user_sign_in', {
          'method': 'google',
          'user_id': user.uid,
        });

        state = AsyncValue.data(userModel);
        return true;
      }

      state = const AsyncValue.data(null);
      return false;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      state = const AsyncValue.loading();

      final userCredential = await _authService.signInWithApple();

      if (userCredential?.user != null) {
        final user = userCredential!.user!;

        // Create or update user in Firestore
        final userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoUrl: user.photoURL,
          isPremiumUser: false,
          bitcoinWalletAddress: '',
          onboardingData: {},
          paidMilestones: [],
          preferences: {'notifications': true, 'analytics': true},
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestoreService.createUser(userModel);

        // Log analytics event
        await _firestoreService.logAnalyticsEvent('user_sign_in', {
          'method': 'apple',
          'user_id': user.uid,
        });

        state = AsyncValue.data(userModel);
        return true;
      }

      state = const AsyncValue.data(null);
      return false;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // Sign out
  Future<bool> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Delete user data from Firestore
        await _firestoreService.deleteUser(currentUser.uid);

        // Delete Firebase Auth account
        await _authService.deleteAccount();
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // Update user profile - kept the old method name for compatibility
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
    String? bitcoinWalletAddress,
    Map<String, dynamic>? onboardingData,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      // Update Firebase Auth profile if needed
      if (displayName != null || photoUrl != null) {
        await _authService.updateUserProfile(
          displayName: displayName,
          photoURL: photoUrl,
        );
      }

      // Also update in Firestore if we have a current user
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final existingUser = await _firestoreService.getUser(currentUser.uid);
        if (existingUser != null) {
          final updatedUser = existingUser.copyWith(
            displayName: displayName ?? existingUser.displayName,
            photoUrl: photoUrl ?? existingUser.photoUrl,
            bitcoinWalletAddress:
                bitcoinWalletAddress ?? existingUser.bitcoinWalletAddress,
            onboardingData: onboardingData ?? existingUser.onboardingData,
            preferences: preferences ?? existingUser.preferences,
          );
          await _firestoreService.updateUser(updatedUser);
          state = AsyncValue.data(updatedUser);
        }
      }

      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}

// Auth notifier provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
      final authService = ref.watch(authServiceProvider);
      final firestoreService = ref.watch(firestoreServiceProvider);
      return AuthNotifier(authService, firestoreService);
    });
