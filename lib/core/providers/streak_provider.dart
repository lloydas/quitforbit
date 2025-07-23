import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/user_model.dart';
import '../../models/milestone_model.dart';
import '../../models/bitcoin_transaction_model.dart';
import '../../services/firestore/firestore_service.dart';
import '../../services/bitcoin_service.dart';
import 'auth_provider.dart';

// Bitcoin service provider
final bitcoinServiceProvider = Provider<BitcoinService>((ref) {
  return BitcoinService();
});

// User milestones provider
final userMilestonesProvider = StreamProvider<List<MilestoneModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserMilestonesStream(user.id);
});

// User Bitcoin transactions provider
final userTransactionsProvider = FutureProvider<List<BitcoinTransactionModel>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];

  final bitcoinService = ref.read(bitcoinServiceProvider);
  return await bitcoinService.getUserTransactions(user.id);
});

// Current Bitcoin price provider
final bitcoinPriceProvider = FutureProvider<double>((ref) async {
  final bitcoinService = ref.read(bitcoinServiceProvider);
  return await bitcoinService.getBitcoinPrice();
});

// Streak notifier for managing streak actions with Bitcoin integration
class StreakNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  StreakNotifier(this._firestoreService, this._bitcoinService, this._userId)
    : super(const AsyncValue.loading()) {
    _loadUser();
  }

  final FirestoreService _firestoreService;
  final BitcoinService _bitcoinService;
  final String _userId;

  Future<void> _loadUser() async {
    try {
      final user = await _firestoreService.getUser(_userId);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Perform daily check-in and update streak
  Future<bool> checkIn() async {
    try {
      final currentUser = state.value;
      if (currentUser == null) return false;

      // Check if user already checked in today
      if (currentUser.hasCheckedInToday) {
        return false; // Already checked in
      }

      state = const AsyncValue.loading();

      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      // Calculate new streak
      int newStreak;
      if (currentUser.lastCheckIn != null &&
          _isSameDay(currentUser.lastCheckIn!, yesterday)) {
        // Consecutive day - increment streak
        newStreak = currentUser.currentStreak + 1;
      } else {
        // First check-in or broken streak - start over
        newStreak = 1;
      }

      // Update longest streak if necessary
      final newLongestStreak =
          newStreak > currentUser.longestStreak
              ? newStreak
              : currentUser.longestStreak;

      // Update user in database
      final updatedUser = currentUser.copyWith(
        currentStreak: newStreak,
        longestStreak: newLongestStreak,
        lastCheckIn: now,
      );

      await _firestoreService.updateUserData(
        _userId,
        updatedUser.toFirestore(),
      );
      state = AsyncValue.data(updatedUser);

      // Check for milestone rewards
      await _checkAndProcessMilestone(updatedUser);

      // Log analytics
      await _firestoreService.logAnalyticsEvent('daily_checkin', {
        'user_id': _userId,
        'streak_day': newStreak,
        'checkin_date': now.toIso8601String(),
      });

      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // Handle relapse - reset streak with compassion
  Future<bool> handleRelapse({String reason = 'relapse'}) async {
    try {
      final currentUser = state.value;
      if (currentUser == null) return false;

      state = const AsyncValue.loading();

      // Reset streak but keep longest streak and earnings
      final updatedUser = currentUser.copyWith(
        currentStreak: 0,
        lastCheckIn: null, // Allow immediate restart
      );

      await _firestoreService.updateUserData(
        _userId,
        updatedUser.toFirestore(),
      );
      state = AsyncValue.data(updatedUser);

      // Log analytics event
      await _firestoreService.logAnalyticsEvent('relapse_occurred', {
        'user_id': _userId,
        'previous_streak': currentUser.currentStreak,
        'reason': reason,
        'relapse_date': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // Set up Bitcoin wallet for user
  Future<bool> setupBitcoinWallet() async {
    try {
      print('💰 DEBUG: Starting Bitcoin wallet setup...');

      final currentUser = state.value;
      if (currentUser == null) {
        print('❌ DEBUG: Current user is null in setupBitcoinWallet');
        return false;
      }

      print('👤 DEBUG: Current user in wallet setup: ${currentUser.email}');

      // Generate Bitcoin testnet address
      print('🔗 DEBUG: Generating testnet address...');
      final address = _bitcoinService.generateTestnetAddress();
      print('🔗 DEBUG: Generated address: $address');

      // Update user with Bitcoin address
      print('💾 DEBUG: Updating user with Bitcoin address...');
      final updatedUser = currentUser.copyWith(bitcoinWalletAddress: address);
      print('💾 DEBUG: Updated user model created');

      await _firestoreService.updateUserData(
        _userId,
        updatedUser.toFirestore(),
      );
      print('💾 DEBUG: User data updated in Firestore');

      state = AsyncValue.data(updatedUser);
      print('💾 DEBUG: State updated with new user data');

      // Process signup bonus
      print('🎁 DEBUG: Processing signup bonus...');
      await _bitcoinService.processSignupBonus(
        userId: _userId,
        bitcoinAddress: address,
      );
      print('🎁 DEBUG: Signup bonus processed successfully');

      print('✅ DEBUG: Bitcoin wallet setup completed successfully');
      return true;
    } catch (e, stackTrace) {
      print('❌ DEBUG: Bitcoin wallet setup error: $e');
      print('❌ DEBUG: Bitcoin wallet error type: ${e.runtimeType}');
      print('❌ DEBUG: Bitcoin wallet stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // Check and process milestone rewards
  Future<void> _checkAndProcessMilestone(UserModel user) async {
    try {
      if (!user.hasBitcoinWallet) return;

      // Get default milestones for this user
      final defaultMilestones = MilestoneModel.getDefaultMilestones(_userId);

      // Find milestone that matches current streak
      final matchedMilestone = defaultMilestones.firstWhere(
        (milestone) =>
            milestone.type == MilestoneType.streak &&
            milestone.targetValue == user.currentStreak,
        orElse: () => defaultMilestones[0], // Return dummy if not found
      );

      // Check if this is a valid milestone and not already processed
      if (matchedMilestone.targetValue == user.currentStreak &&
          !user.paidMilestones.contains('streak_${user.currentStreak}')) {
        // Create milestone in database
        final milestone = matchedMilestone.copyWith(userId: _userId);
        final milestoneId = await _firestoreService.createMilestone(milestone);

        // Process Bitcoin reward
        await _bitcoinService.processMilestoneReward(
          userId: _userId,
          milestone: milestone.copyWith(
            status: MilestoneStatus.achieved,
            achievedAt: DateTime.now(),
          ),
          bitcoinAddress: user.bitcoinWalletAddress!,
        );

        // Update user's paid milestones list
        final updatedMilestones = [
          ...user.paidMilestones,
          'streak_${user.currentStreak}',
        ];
        final updatedUser = user.copyWith(paidMilestones: updatedMilestones);

        await _firestoreService.updateUserData(
          _userId,
          updatedUser.toFirestore(),
        );
        state = AsyncValue.data(updatedUser);

        // Log milestone achievement
        await _firestoreService.logAnalyticsEvent('milestone_achieved', {
          'user_id': _userId,
          'milestone_type': 'streak',
          'milestone_value': user.currentStreak,
          'bitcoin_amount': milestone.bitcoinAmount,
        });
      }
    } catch (e) {
      print('Error processing milestone: $e');
      // Don't throw error - milestone processing shouldn't break check-in
    }
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Get next milestone info for UI
  Map<String, dynamic> getNextMilestoneInfo() {
    final user = state.value;
    if (user == null) {
      return {'target': 1, 'daysLeft': 1, 'reward': 1.0, 'title': 'First Day'};
    }

    final nextTarget = user.nextMilestoneTarget;
    final daysLeft = user.daysToNextMilestone;

    // Get reward amount based on target
    double reward = 1.0;
    String title = 'Start Journey';

    switch (nextTarget) {
      case 1:
        reward = 1.0;
        title = 'First Day';
        break;
      case 7:
        reward = 5.0;
        title = 'One Week';
        break;
      case 30:
        reward = 25.0;
        title = 'One Month';
        break;
      case 90:
        reward = 100.0;
        title = 'Three Months';
        break;
      case 180:
        reward = 200.0;
        title = 'Six Months';
        break;
      case 365:
        reward = 500.0;
        title = 'One Year';
        break;
      case 730:
        reward = 1000.0;
        title = 'Two Years';
        break;
    }

    return {
      'target': nextTarget,
      'daysLeft': daysLeft,
      'reward': reward,
      'title': title,
    };
  }

  // Refresh user data
  Future<void> refresh() async {
    await _loadUser();
  }
}

// Streak provider factory
final streakProvider =
    StateNotifierProvider<StreakNotifier, AsyncValue<UserModel?>>((ref) {
      final user = ref.watch(currentUserProvider).value;
      if (user == null) {
        return StreakNotifier(
          ref.read(firestoreServiceProvider),
          ref.read(bitcoinServiceProvider),
          'dummy',
        );
      }

      return StreakNotifier(
        ref.read(firestoreServiceProvider),
        ref.read(bitcoinServiceProvider),
        user.id,
      );
    });

// Helper provider for next milestone info
final nextMilestoneProvider = Provider<Map<String, dynamic>>((ref) {
  final streakNotifier = ref.read(streakProvider.notifier);
  return streakNotifier.getNextMilestoneInfo();
});
