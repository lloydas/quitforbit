import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/streak_model.dart';
import '../../models/milestone_model.dart';
import '../../core/constants/app_constants.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Operations
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toFirestore());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userId)
              .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Method for updating user with data map (MVP)
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(data);
    } catch (e) {
      print('Error updating user with data: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // Delete user document
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .delete();

      // Delete all user's streaks
      final streaksQuery =
          await _firestore
              .collection(AppConstants.streaksCollection)
              .where('userId', isEqualTo: userId)
              .get();

      final batch = _firestore.batch();
      for (final doc in streaksQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete all user's milestones
      final milestonesQuery =
          await _firestore
              .collection(AppConstants.milestonesCollection)
              .where('userId', isEqualTo: userId)
              .get();

      for (final doc in milestonesQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Streak Operations
  Future<String> createStreak(StreakModel streak) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.streaksCollection)
          .add(streak.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating streak: $e');
      rethrow;
    }
  }

  Future<StreakModel?> getCurrentStreak(String userId) async {
    try {
      final query =
          await _firestore
              .collection(AppConstants.streaksCollection)
              .where('userId', isEqualTo: userId)
              .where('isActive', isEqualTo: true)
              .orderBy('startDate', descending: true)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        return StreakModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting current streak: $e');
      rethrow;
    }
  }

  Future<List<StreakModel>> getUserStreaks(String userId) async {
    try {
      final query =
          await _firestore
              .collection(AppConstants.streaksCollection)
              .where('userId', isEqualTo: userId)
              .orderBy('startDate', descending: true)
              .get();

      return query.docs.map((doc) => StreakModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting user streaks: $e');
      rethrow;
    }
  }

  Future<void> updateStreak(StreakModel streak) async {
    try {
      await _firestore
          .collection(AppConstants.streaksCollection)
          .doc(streak.id)
          .update(streak.toFirestore());
    } catch (e) {
      print('Error updating streak: $e');
      rethrow;
    }
  }

  Future<void> endStreak(String streakId, String reason) async {
    try {
      await _firestore
          .collection(AppConstants.streaksCollection)
          .doc(streakId)
          .update({
            'isActive': false,
            'endDate': Timestamp.now(),
            'endReason': reason,
          });
    } catch (e) {
      print('Error ending streak: $e');
      rethrow;
    }
  }

  // Milestone Operations
  Future<String> createMilestone(MilestoneModel milestone) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.milestonesCollection)
          .add(milestone.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating milestone: $e');
      rethrow;
    }
  }

  Future<List<MilestoneModel>> getUserMilestones(String userId) async {
    try {
      final query =
          await _firestore
              .collection(AppConstants.milestonesCollection)
              .where('userId', isEqualTo: userId)
              .orderBy('achievedAt', descending: true)
              .get();

      return query.docs
          .map((doc) => MilestoneModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting user milestones: $e');
      rethrow;
    }
  }

  Future<void> updateMilestone(MilestoneModel milestone) async {
    try {
      await _firestore
          .collection(AppConstants.milestonesCollection)
          .doc(milestone.id)
          .update(milestone.toFirestore());
    } catch (e) {
      print('Error updating milestone: $e');
      rethrow;
    }
  }

  Future<List<MilestoneModel>> getPendingMilestones() async {
    try {
      final query =
          await _firestore
              .collection(AppConstants.milestonesCollection)
              .where('status', isEqualTo: MilestoneStatus.pending.toString())
              .get();

      return query.docs
          .map((doc) => MilestoneModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting pending milestones: $e');
      rethrow;
    }
  }

  // Analytics Operations
  Future<void> logAnalyticsEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    try {
      await _firestore.collection(AppConstants.analyticsCollection).add({
        'eventName': eventName,
        'parameters': parameters,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error logging analytics event: $e');
      rethrow;
    }
  }

  // Utility Methods
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final streaks = await getUserStreaks(userId);
      final milestones = await getUserMilestones(userId);

      int totalStreaks = streaks.length;
      int longestStreak = 0;
      int totalDaysClean = 0;
      int milestonesAchieved = milestones.length;

      for (final streak in streaks) {
        final days = streak.currentDays;
        if (days > longestStreak) {
          longestStreak = days;
        }
        totalDaysClean += days;
      }

      return {
        'totalStreaks': totalStreaks,
        'longestStreak': longestStreak,
        'totalDaysClean': totalDaysClean,
        'milestonesAchieved': milestonesAchieved,
        'currentStreak':
            streaks.isNotEmpty && streaks.first.isActive
                ? streaks.first.currentDays
                : 0,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      rethrow;
    }
  }

  // Stream methods for real-time updates
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Stream<StreakModel?> getCurrentStreakStream(String userId) {
    return _firestore
        .collection(AppConstants.streaksCollection)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('startDate', descending: true)
        .limit(1)
        .snapshots()
        .map(
          (query) =>
              query.docs.isNotEmpty
                  ? StreakModel.fromFirestore(query.docs.first)
                  : null,
        );
  }

  Stream<List<MilestoneModel>> getUserMilestonesStream(String userId) {
    return _firestore
        .collection(AppConstants.milestonesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('achievedAt', descending: true)
        .snapshots()
        .map(
          (query) =>
              query.docs
                  .map((doc) => MilestoneModel.fromFirestore(doc))
                  .toList(),
        );
  }
}
