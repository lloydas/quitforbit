import 'package:cloud_firestore/cloud_firestore.dart';
import 'habit_category.dart';
import 'achievement.dart';
import 'level_system.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final DateTime? lastCheckIn;
  final bool isPremiumUser;
  final String? bitcoinWalletAddress;
  final int currentStreak;
  final int longestStreak;
  final double totalEarned; // Total USD value earned in Bitcoin
  final double totalBitcoinEarned; // Total BTC amount earned
  final Map<String, dynamic> onboardingData;
  final List<String> paidMilestones;
  final Map<String, dynamic> preferences;

  // Habit category fields
  final HabitType? habitType;
  final DateTime? habitStartDate;
  final String? customHabitName; // For custom habits
  final String? customHabitDescription; // For custom habits
  final List<String> selectedTriggers; // User's identified triggers
  final List<String>
      selectedAlternatives; // User's chosen replacement activities
  final int dailyGoalStreak; // Target streak length

  // Gamification fields
  final int totalXP; // Total experience points earned
  final List<UserAchievement> achievements; // Unlocked achievements
  final List<UserChallenge>
      dailyChallenges; // Current and past daily challenges
  final Map<String, int> socialStats; // Social interaction stats
  final DateTime? lastDailyChallenge; // When last daily challenge was assigned
  final int helpsGiven; // Number of times user helped others
  final int likesReceived; // Likes received on posts/comments
  final int journalEntries; // Number of journal entries
  final int healthLogs; // Number of health tracking entries
  final int articlesRead; // Educational articles read

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.lastCheckIn,
    this.isPremiumUser = false,
    this.bitcoinWalletAddress,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalEarned = 0.0,
    this.totalBitcoinEarned = 0.0,
    this.onboardingData = const {},
    this.paidMilestones = const [],
    this.preferences = const {},
    // Habit category fields
    this.habitType,
    this.habitStartDate,
    this.customHabitName,
    this.customHabitDescription,
    this.selectedTriggers = const [],
    this.selectedAlternatives = const [],
    this.dailyGoalStreak = 365, // Default to 1 year goal
    // Gamification fields
    this.totalXP = 0,
    this.achievements = const [],
    this.dailyChallenges = const [],
    this.socialStats = const {},
    this.lastDailyChallenge,
    this.helpsGiven = 0,
    this.likesReceived = 0,
    this.journalEntries = 0,
    this.healthLogs = 0,
    this.articlesRead = 0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      lastCheckIn: data['lastCheckIn'] != null
          ? (data['lastCheckIn'] as Timestamp).toDate()
          : null,
      isPremiumUser: data['isPremiumUser'] ?? false,
      bitcoinWalletAddress: data['bitcoinWalletAddress'],
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      totalEarned: (data['totalEarned'] ?? 0.0).toDouble(),
      totalBitcoinEarned: (data['totalBitcoinEarned'] ?? 0.0).toDouble(),
      onboardingData: Map<String, dynamic>.from(data['onboardingData'] ?? {}),
      paidMilestones: List<String>.from(data['paidMilestones'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      // Habit category fields
      habitType: data['habitType'] != null
          ? HabitType.values.byName(data['habitType'])
          : null,
      habitStartDate: data['habitStartDate'] != null
          ? (data['habitStartDate'] as Timestamp).toDate()
          : null,
      customHabitName: data['customHabitName'],
      customHabitDescription: data['customHabitDescription'],
      selectedTriggers: List<String>.from(data['selectedTriggers'] ?? []),
      selectedAlternatives:
          List<String>.from(data['selectedAlternatives'] ?? []),
      dailyGoalStreak: data['dailyGoalStreak'] ?? 365,
      // Gamification fields
      totalXP: data['totalXP'] ?? 0,
      achievements: (data['achievements'] as List<dynamic>? ?? [])
          .map((a) =>
              UserAchievement.fromFirestore(Map<String, dynamic>.from(a)))
          .toList(),
      dailyChallenges: (data['dailyChallenges'] as List<dynamic>? ?? [])
          .map((c) => UserChallenge.fromFirestore(Map<String, dynamic>.from(c)))
          .toList(),
      socialStats: Map<String, int>.from(data['socialStats'] ?? {}),
      lastDailyChallenge: data['lastDailyChallenge'] != null
          ? (data['lastDailyChallenge'] as Timestamp).toDate()
          : null,
      helpsGiven: data['helpsGiven'] ?? 0,
      likesReceived: data['likesReceived'] ?? 0,
      journalEntries: data['journalEntries'] ?? 0,
      healthLogs: data['healthLogs'] ?? 0,
      articlesRead: data['articlesRead'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'lastCheckIn':
          lastCheckIn != null ? Timestamp.fromDate(lastCheckIn!) : null,
      'isPremiumUser': isPremiumUser,
      'bitcoinWalletAddress': bitcoinWalletAddress,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalEarned': totalEarned,
      'totalBitcoinEarned': totalBitcoinEarned,
      'onboardingData': onboardingData,
      'paidMilestones': paidMilestones,
      'preferences': preferences,
      // Habit category fields
      'habitType': habitType?.name,
      'habitStartDate':
          habitStartDate != null ? Timestamp.fromDate(habitStartDate!) : null,
      'customHabitName': customHabitName,
      'customHabitDescription': customHabitDescription,
      'selectedTriggers': selectedTriggers,
      'selectedAlternatives': selectedAlternatives,
      'dailyGoalStreak': dailyGoalStreak,
      // Gamification fields
      'totalXP': totalXP,
      'achievements': achievements.map((a) => a.toFirestore()).toList(),
      'dailyChallenges': dailyChallenges.map((c) => c.toFirestore()).toList(),
      'socialStats': socialStats,
      'lastDailyChallenge': lastDailyChallenge != null
          ? Timestamp.fromDate(lastDailyChallenge!)
          : null,
      'helpsGiven': helpsGiven,
      'likesReceived': likesReceived,
      'journalEntries': journalEntries,
      'healthLogs': healthLogs,
      'articlesRead': articlesRead,
    };
  }

  UserModel copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? lastLoginAt,
    DateTime? lastCheckIn,
    bool? isPremiumUser,
    String? bitcoinWalletAddress,
    int? currentStreak,
    int? longestStreak,
    double? totalEarned,
    double? totalBitcoinEarned,
    Map<String, dynamic>? onboardingData,
    List<String>? paidMilestones,
    Map<String, dynamic>? preferences,
    // Habit category fields
    HabitType? habitType,
    DateTime? habitStartDate,
    String? customHabitName,
    String? customHabitDescription,
    List<String>? selectedTriggers,
    List<String>? selectedAlternatives,
    int? dailyGoalStreak,
    // Gamification fields
    int? totalXP,
    List<UserAchievement>? achievements,
    List<UserChallenge>? dailyChallenges,
    Map<String, int>? socialStats,
    DateTime? lastDailyChallenge,
    int? helpsGiven,
    int? likesReceived,
    int? journalEntries,
    int? healthLogs,
    int? articlesRead,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      bitcoinWalletAddress: bitcoinWalletAddress ?? this.bitcoinWalletAddress,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalEarned: totalEarned ?? this.totalEarned,
      totalBitcoinEarned: totalBitcoinEarned ?? this.totalBitcoinEarned,
      onboardingData: onboardingData ?? this.onboardingData,
      paidMilestones: paidMilestones ?? this.paidMilestones,
      preferences: preferences ?? this.preferences,
      // Habit category fields
      habitType: habitType ?? this.habitType,
      habitStartDate: habitStartDate ?? this.habitStartDate,
      customHabitName: customHabitName ?? this.customHabitName,
      customHabitDescription:
          customHabitDescription ?? this.customHabitDescription,
      selectedTriggers: selectedTriggers ?? this.selectedTriggers,
      selectedAlternatives: selectedAlternatives ?? this.selectedAlternatives,
      dailyGoalStreak: dailyGoalStreak ?? this.dailyGoalStreak,
      // Gamification fields
      totalXP: totalXP ?? this.totalXP,
      achievements: achievements ?? this.achievements,
      dailyChallenges: dailyChallenges ?? this.dailyChallenges,
      socialStats: socialStats ?? this.socialStats,
      lastDailyChallenge: lastDailyChallenge ?? this.lastDailyChallenge,
      helpsGiven: helpsGiven ?? this.helpsGiven,
      likesReceived: likesReceived ?? this.likesReceived,
      journalEntries: journalEntries ?? this.journalEntries,
      healthLogs: healthLogs ?? this.healthLogs,
      articlesRead: articlesRead ?? this.articlesRead,
    );
  }

  // Helper methods for MVP
  bool get hasBitcoinWallet =>
      bitcoinWalletAddress != null && bitcoinWalletAddress!.isNotEmpty;
  bool get hasCheckedInToday {
    if (lastCheckIn == null) return false;
    final today = DateTime.now();
    final lastCheckInDate = lastCheckIn!;
    return today.year == lastCheckInDate.year &&
        today.month == lastCheckInDate.month &&
        today.day == lastCheckInDate.day;
  }

  bool get canCheckIn => !hasCheckedInToday;

  // Habit category helper methods
  HabitCategory? get habitCategory {
    if (habitType == null) return null;
    return HabitCategory.getByType(habitType!);
  }

  String get habitDisplayName {
    if (habitType == HabitType.custom && customHabitName != null) {
      return customHabitName!;
    }
    return habitCategory?.name ?? 'Your Habit';
  }

  String get habitDescription {
    if (habitType == HabitType.custom && customHabitDescription != null) {
      return customHabitDescription!;
    }
    return habitCategory?.description ?? 'Breaking a bad habit';
  }

  String get streakDisplayText {
    if (currentStreak == 0) return 'Start your journey';
    if (currentStreak == 1) return '1 day clean';
    return '$currentStreak days clean';
  }

  String get totalEarnedDisplayText {
    return '\$${totalEarned.toStringAsFixed(2)}';
  }

  // Get next milestone target based on habit category
  int get nextMilestoneTarget {
    final category = habitCategory;
    if (category == null) {
      // Default milestones
      if (currentStreak < 1) return 1;
      if (currentStreak < 7) return 7;
      if (currentStreak < 30) return 30;
      if (currentStreak < 90) return 90;
      if (currentStreak < 365) return 365;
      return 730; // 2 years
    }

    // Use category-specific milestones
    for (var milestone in category.milestoneRewards.keys) {
      if (milestone > currentStreak) {
        return milestone;
      }
    }
    return dailyGoalStreak; // Return user's goal if all milestones completed
  }

  int get daysToNextMilestone {
    return nextMilestoneTarget - currentStreak;
  }

  // Get potential reward for next milestone
  double? get nextMilestoneReward {
    final category = habitCategory;
    if (category == null) return null;
    return category.getRewardForDay(nextMilestoneTarget);
  }

  // Check if user has completed onboarding for habit categories
  bool get hasCompletedHabitOnboarding {
    return habitType != null && habitStartDate != null;
  }

  // Get days since starting habit journey
  int get daysSinceStart {
    if (habitStartDate == null) return 0;
    return DateTime.now().difference(habitStartDate!).inDays;
  }

  // Get progress percentage toward daily goal
  double get progressPercentage {
    if (dailyGoalStreak == 0) return 0.0;
    return (currentStreak / dailyGoalStreak).clamp(0.0, 1.0);
  }

  // Get a random motivational quote for user's habit
  String? get motivationalQuote {
    final category = habitCategory;
    if (category == null || category.motivationalQuotes.isEmpty) return null;
    final now = DateTime.now();
    final index =
        (now.day + now.month + now.year) % category.motivationalQuotes.length;
    return category.motivationalQuotes[index];
  }

  // === GAMIFICATION HELPER METHODS ===

  /// Get user's current level based on XP
  UserLevel get userLevel {
    return UserLevel.fromTotalXP(totalXP);
  }

  /// Get new achievements that user has unlocked but hasn't seen yet
  List<UserAchievement> get newAchievements {
    return achievements.where((a) => a.isNew).toList();
  }

  /// Get today's daily challenges
  List<UserChallenge> get todaysChallenges {
    final today = DateTime.now();
    return dailyChallenges.where((c) {
      final assignedDate = c.assignedDate;
      return assignedDate.year == today.year &&
          assignedDate.month == today.month &&
          assignedDate.day == today.day;
    }).toList();
  }

  /// Get completed challenges count
  int get completedChallengesCount {
    return dailyChallenges.where((c) => c.isCompleted).length;
  }

  /// Check if user needs new daily challenges
  bool get needsNewDailyChallenges {
    if (lastDailyChallenge == null) return true;
    final today = DateTime.now();
    final lastChallenge = lastDailyChallenge!;
    return today.year != lastChallenge.year ||
        today.month != lastChallenge.month ||
        today.day != lastChallenge.day;
  }

  /// Get user stats for achievement checking
  Map<String, dynamic> get userStats {
    return {
      'streak_days': currentStreak,
      'total_btc_earned': totalBitcoinEarned,
      'total_usd_earned': totalEarned,
      'helps_given': helpsGiven,
      'likes_received': likesReceived,
      'daily_challenges_completed': completedChallengesCount,
      'health_logs': healthLogs,
      'journal_entries': journalEntries,
      'articles_read': articlesRead,
      'comebacks': socialStats['comebacks'] ?? 0,
      'joined_before': createdAt.toIso8601String(),
    };
  }

  /// Check what achievements user has newly unlocked
  List<Achievement> checkNewAchievements() {
    final allAchievements = Achievement.getAllAchievements();
    final unlockedIds = achievements.map((a) => a.achievementId).toSet();
    final stats = userStats;

    return allAchievements.where((achievement) {
      return !unlockedIds.contains(achievement.id) &&
          achievement.checkCriteria(stats);
    }).toList();
  }

  /// Get achievement progress for not-yet-unlocked achievements
  Map<String, double> get achievementProgress {
    final allAchievements = Achievement.getAllAchievements();
    final unlockedIds = achievements.map((a) => a.achievementId).toSet();
    final stats = userStats;
    final progress = <String, double>{};

    for (var achievement in allAchievements) {
      if (!unlockedIds.contains(achievement.id) && !achievement.isHidden) {
        // Calculate progress for this achievement
        double totalProgress = 0.0;
        int criteriaCount = achievement.criteria.length;

        for (var criterion in achievement.criteria.entries) {
          final key = criterion.key;
          final required = criterion.value;
          final userValue = stats[key] ?? 0;

          if (required is num && userValue is num) {
            final criterionProgress = (userValue / required).clamp(0.0, 1.0);
            totalProgress += criterionProgress;
          } else {
            totalProgress += userValue == required ? 1.0 : 0.0;
          }
        }

        progress[achievement.id] =
            criteriaCount > 0 ? totalProgress / criteriaCount : 0.0;
      }
    }

    return progress;
  }

  /// Get total potential XP from all achievements
  int get totalPotentialXP {
    return Achievement.getAllAchievements()
        .fold(0, (sum, achievement) => sum + achievement.xpReward);
  }

  /// Get XP earned from achievements
  int get achievementXP {
    return achievements.fold(0, (sum, userAchievement) {
      final achievement = userAchievement.achievement;
      return sum + (achievement?.xpReward ?? 0);
    });
  }
}
