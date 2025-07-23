import 'package:flutter_test/flutter_test.dart';
import 'package:quitforbit/models/user_model.dart';
import 'package:quitforbit/models/milestone_model.dart';
import 'package:quitforbit/models/bitcoin_transaction_model.dart';
import 'package:quitforbit/services/bitcoin_service.dart';

void main() {
  group('MVP Core Functionality Tests', () {
    test('UserModel should calculate streak info correctly', () {
      final user = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        currentStreak: 15,
        longestStreak: 30,
        totalEarned: 25.0,
      );

      expect(user.streakDisplayText, '15 days clean');
      expect(user.totalEarnedDisplayText, '\$25.00');
      expect(user.nextMilestoneTarget, 30);
      expect(user.daysToNextMilestone, 15);
    });

    test('MilestoneModel should create correct default milestones', () {
      final milestones = MilestoneModel.getDefaultMilestones('user-id');

      expect(milestones.length, 7); // signup + 6 streak milestones
      expect(milestones[0].type, MilestoneType.signup);
      expect(milestones[1].targetValue, 1);
      expect(milestones[2].targetValue, 7);
      expect(milestones[3].targetValue, 30);
    });

    test(
      'BitcoinTransactionModel should create milestone transaction correctly',
      () {
        final transaction = BitcoinTransactionModel.createMilestoneTransaction(
          userId: 'user-id',
          milestoneId: 'milestone-id',
          amount: 25.0,
          bitcoinAmount: 0.0005,
          bitcoinAddress: 'tb1qtest',
        );

        expect(transaction.userId, 'user-id');
        expect(transaction.milestoneId, 'milestone-id');
        expect(transaction.amount, 25.0);
        expect(transaction.type, TransactionType.milestone);
        expect(transaction.status, TransactionStatus.pending);
      },
    );

    test('BitcoinService should validate addresses correctly', () {
      final service = BitcoinService();

      // Testnet addresses should be valid
      expect(service.isValidBitcoinAddress('tb1qtest'), true);
      expect(service.isValidBitcoinAddress('mtest'), true);
      expect(service.isValidBitcoinAddress('ntest'), true);
      expect(service.isValidBitcoinAddress('2test'), true);

      // Invalid addresses
      expect(service.isValidBitcoinAddress(''), false);
      expect(service.isValidBitcoinAddress('invalid'), false);
    });

    test('BitcoinService should generate valid testnet addresses', () {
      final service = BitcoinService();
      final address = service.generateTestnetAddress();

      expect(address.startsWith('tb1q'), true);
      expect(address.length, 29); // tb1q + 25 characters
    });
  });

  group('MVP Edge Cases', () {
    test('UserModel should handle zero streak correctly', () {
      final user = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        currentStreak: 0,
      );

      expect(user.streakDisplayText, 'Start your journey');
      expect(user.nextMilestoneTarget, 1);
      expect(user.daysToNextMilestone, 1);
    });

    test('UserModel should calculate check-in status correctly', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final userCheckedInToday = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        lastCheckIn: today,
      );

      final userCheckedInYesterday = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        lastCheckIn: yesterday,
      );

      expect(userCheckedInToday.hasCheckedInToday, true);
      expect(userCheckedInToday.canCheckIn, false);
      expect(userCheckedInYesterday.hasCheckedInToday, false);
      expect(userCheckedInYesterday.canCheckIn, true);
    });
  });
}
