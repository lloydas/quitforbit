import 'package:flutter/material.dart';

/// Model representing user level and XP system
class UserLevel {
  final int level;
  final int currentXP;
  final int xpToNext;
  final int totalXP;
  final String title;
  final Color color;
  final IconData icon;
  final List<String> unlockedFeatures;
  final Map<String, dynamic> rewards;

  const UserLevel({
    required this.level,
    required this.currentXP,
    required this.xpToNext,
    required this.totalXP,
    required this.title,
    required this.color,
    required this.icon,
    required this.unlockedFeatures,
    required this.rewards,
  });

  /// Calculate user level from total XP
  static UserLevel fromTotalXP(int totalXP) {
    final levels = _getLevelDefinitions();

    for (int i = levels.length - 1; i >= 0; i--) {
      final levelDef = levels[i];
      if (totalXP >= levelDef['requiredXP']) {
        final level = i + 1;
        final requiredXP = levelDef['requiredXP'] as int;
        final currentLevelXP = totalXP - requiredXP;
        final nextLevelXP = i < levels.length - 1
            ? (levels[i + 1]['requiredXP'] as int) - requiredXP
            : 0;

        return UserLevel(
          level: level,
          currentXP: currentLevelXP,
          xpToNext: nextLevelXP - currentLevelXP,
          totalXP: totalXP,
          title: levelDef['title'],
          color: levelDef['color'],
          icon: levelDef['icon'],
          unlockedFeatures: List<String>.from(levelDef['features']),
          rewards: Map<String, dynamic>.from(levelDef['rewards']),
        );
      }
    }

    // Default to level 1
    return UserLevel(
      level: 1,
      currentXP: totalXP,
      xpToNext: 100 - totalXP,
      totalXP: totalXP,
      title: 'Newcomer',
      color: const Color(0xFF9E9E9E),
      icon: Icons.person,
      unlockedFeatures: ['basic_tracking', 'daily_checkin'],
      rewards: {},
    );
  }

  /// Get level definitions
  static List<Map<String, dynamic>> _getLevelDefinitions() {
    return [
      // Level 1
      {
        'requiredXP': 0,
        'title': 'Newcomer',
        'color': const Color(0xFF9E9E9E),
        'icon': Icons.person,
        'features': ['basic_tracking', 'daily_checkin'],
        'rewards': {'welcome_bonus': 1.0},
      },

      // Level 2
      {
        'requiredXP': 100,
        'title': 'Beginner',
        'color': const Color(0xFF4CAF50),
        'icon': Icons.star_border,
        'features': ['achievements', 'basic_stats'],
        'rewards': {'bitcoin_bonus': 2.0},
      },

      // Level 3
      {
        'requiredXP': 250,
        'title': 'Motivated',
        'color': const Color(0xFF2196F3),
        'icon': Icons.trending_up,
        'features': ['daily_challenges', 'triggers_tracking'],
        'rewards': {'challenge_unlock': true},
      },

      // Level 4
      {
        'requiredXP': 500,
        'title': 'Determined',
        'color': const Color(0xFF9C27B0),
        'icon': Icons.fitness_center,
        'features': ['custom_goals', 'advanced_stats'],
        'rewards': {'bitcoin_bonus': 5.0},
      },

      // Level 5
      {
        'requiredXP': 1000,
        'title': 'Warrior',
        'color': const Color(0xFFFF9800),
        'icon': Icons.shield,
        'features': ['social_features', 'leaderboards'],
        'rewards': {'social_unlock': true, 'bitcoin_bonus': 10.0},
      },

      // Level 6
      {
        'requiredXP': 2000,
        'title': 'Champion',
        'color': const Color(0xFFE91E63),
        'icon': Icons.emoji_events,
        'features': ['premium_challenges', 'detailed_analytics'],
        'rewards': {'premium_features': true, 'bitcoin_bonus': 15.0},
      },

      // Level 7
      {
        'requiredXP': 4000,
        'title': 'Hero',
        'color': const Color(0xFF673AB7),
        'icon': Icons.military_tech,
        'features': ['mentoring', 'exclusive_content'],
        'rewards': {'mentoring_unlock': true, 'bitcoin_bonus': 25.0},
      },

      // Level 8
      {
        'requiredXP': 7500,
        'title': 'Legend',
        'color': const Color(0xFFFFD700),
        'icon': Icons.star,
        'features': ['all_features', 'beta_access'],
        'rewards': {'legend_status': true, 'bitcoin_bonus': 50.0},
      },

      // Level 9
      {
        'requiredXP': 15000,
        'title': 'Master',
        'color': const Color(0xFFFF5722),
        'icon': Icons.diamond,
        'features': ['master_privileges', 'early_access'],
        'rewards': {'master_status': true, 'bitcoin_bonus': 75.0},
      },

      // Level 10
      {
        'requiredXP': 30000,
        'title': 'Enlightened',
        'color': const Color(0xFF795548),
        'icon': Icons.psychology,
        'features': ['enlightened_features', 'custom_title'],
        'rewards': {'enlightened_status': true, 'bitcoin_bonus': 100.0},
      },
    ];
  }

  /// Get progress percentage to next level (0.0 to 1.0)
  double get progressPercentage {
    if (xpToNext <= 0) return 1.0;
    final totalNeeded = currentXP + xpToNext;
    return totalNeeded > 0 ? currentXP / totalNeeded : 0.0;
  }

  /// Check if user has a specific feature unlocked
  bool hasFeature(String feature) {
    return unlockedFeatures.contains(feature);
  }

  /// Get display text for current XP progress
  String get xpDisplayText {
    return '$currentXP XP';
  }

  /// Get next level info
  UserLevel? get nextLevel {
    final levels = _getLevelDefinitions();
    if (level < levels.length) {
      return fromTotalXP(levels[level]['requiredXP']);
    }
    return null;
  }

  @override
  String toString() {
    return 'UserLevel(level: $level, title: $title, totalXP: $totalXP)';
  }
}

/// Daily challenge types
enum ChallengeType {
  streak, // Maintain streak
  mindfulness, // Meditation/breathing
  physical, // Exercise/movement
  social, // Community interaction
  learning, // Educational content
  creative, // Creative activities
  gratitude, // Gratitude practice
  goal, // Personal goals
}

/// Model for daily challenges
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final IconData icon;
  final Color color;
  final int xpReward;
  final double? bitcoinReward;
  final int difficulty; // 1-5 scale
  final Map<String, dynamic> criteria;
  final List<String> tips;
  final Duration estimatedTime;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    required this.color,
    required this.xpReward,
    this.bitcoinReward,
    required this.difficulty,
    required this.criteria,
    required this.tips,
    required this.estimatedTime,
  });

  /// Get all available daily challenges
  static List<DailyChallenge> getAllChallenges() {
    return [
      // STREAK CHALLENGES
      DailyChallenge(
        id: 'maintain_streak',
        title: 'Stay Strong',
        description: 'Maintain your current streak for another day',
        type: ChallengeType.streak,
        icon: Icons.local_fire_department,
        color: const Color(0xFFFF5722),
        xpReward: 50,
        bitcoinReward: 0.5,
        difficulty: 2,
        criteria: {'check_in': true},
        tips: [
          'Remember why you started',
          'Take it one day at a time',
          'Celebrate small wins'
        ],
        estimatedTime: Duration(minutes: 5),
      ),

      // MINDFULNESS CHALLENGES
      DailyChallenge(
        id: 'meditation_5min',
        title: 'Mindful Moment',
        description: 'Practice 5 minutes of meditation or deep breathing',
        type: ChallengeType.mindfulness,
        icon: Icons.self_improvement,
        color: const Color(0xFF9C27B0),
        xpReward: 75,
        difficulty: 2,
        criteria: {'meditation_minutes': 5},
        tips: [
          'Find a quiet space',
          'Focus on your breath',
          'Use a meditation app if helpful'
        ],
        estimatedTime: Duration(minutes: 5),
      ),

      DailyChallenge(
        id: 'gratitude_practice',
        title: 'Gratitude List',
        description: 'Write down 3 things you\'re grateful for today',
        type: ChallengeType.gratitude,
        icon: Icons.favorite,
        color: const Color(0xFFE91E63),
        xpReward: 60,
        difficulty: 1,
        criteria: {'gratitude_items': 3},
        tips: [
          'Think about people who support you',
          'Appreciate small daily moments',
          'Consider your health improvements'
        ],
        estimatedTime: Duration(minutes: 10),
      ),

      // PHYSICAL CHALLENGES
      DailyChallenge(
        id: 'walk_10min',
        title: 'Fresh Air Walk',
        description: 'Take a 10-minute walk outside',
        type: ChallengeType.physical,
        icon: Icons.directions_walk,
        color: const Color(0xFF4CAF50),
        xpReward: 80,
        difficulty: 2,
        criteria: {'walk_minutes': 10},
        tips: [
          'Leave your phone at home',
          'Notice your surroundings',
          'Breathe deeply'
        ],
        estimatedTime: Duration(minutes: 10),
      ),

      DailyChallenge(
        id: 'exercise_15min',
        title: 'Body Movement',
        description: 'Do 15 minutes of any physical exercise',
        type: ChallengeType.physical,
        icon: Icons.fitness_center,
        color: const Color(0xFF2196F3),
        xpReward: 100,
        difficulty: 3,
        criteria: {'exercise_minutes': 15},
        tips: [
          'Try yoga or stretching',
          'Do bodyweight exercises',
          'Dance to your favorite music'
        ],
        estimatedTime: Duration(minutes: 15),
      ),

      // SOCIAL CHALLENGES
      DailyChallenge(
        id: 'help_someone',
        title: 'Helping Hand',
        description: 'Help or encourage someone in the community',
        type: ChallengeType.social,
        icon: Icons.people_alt,
        color: const Color(0xFFFF9800),
        xpReward: 120,
        difficulty: 3,
        criteria: {'community_help': 1},
        tips: [
          'Share your experience',
          'Offer support to newcomers',
          'Leave an encouraging comment'
        ],
        estimatedTime: Duration(minutes: 15),
      ),

      // LEARNING CHALLENGES
      DailyChallenge(
        id: 'read_article',
        title: 'Knowledge Seeker',
        description: 'Read an article about addiction recovery',
        type: ChallengeType.learning,
        icon: Icons.menu_book,
        color: const Color(0xFF673AB7),
        xpReward: 70,
        difficulty: 2,
        criteria: {'articles_read': 1},
        tips: [
          'Check our resource library',
          'Look for evidence-based content',
          'Take notes on key insights'
        ],
        estimatedTime: Duration(minutes: 20),
      ),

      // CREATIVE CHALLENGES
      DailyChallenge(
        id: 'journal_entry',
        title: 'Daily Reflection',
        description: 'Write a journal entry about your recovery journey',
        type: ChallengeType.creative,
        icon: Icons.edit,
        color: const Color(0xFF795548),
        xpReward: 90,
        difficulty: 2,
        criteria: {'journal_words': 50},
        tips: [
          'Write about your feelings',
          'Note any challenges you faced',
          'Celebrate your progress'
        ],
        estimatedTime: Duration(minutes: 15),
      ),

      // GOAL CHALLENGES
      DailyChallenge(
        id: 'plan_tomorrow',
        title: 'Tomorrow\'s Plan',
        description: 'Plan 3 healthy activities for tomorrow',
        type: ChallengeType.goal,
        icon: Icons.schedule,
        color: const Color(0xFF607D8B),
        xpReward: 65,
        difficulty: 1,
        criteria: {'planned_activities': 3},
        tips: [
          'Include one fun activity',
          'Schedule exercise or movement',
          'Plan time for relaxation'
        ],
        estimatedTime: Duration(minutes: 10),
      ),
    ];
  }

  /// Get challenges by type
  static List<DailyChallenge> getByType(ChallengeType type) {
    return getAllChallenges().where((c) => c.type == type).toList();
  }

  /// Get challenges by difficulty
  static List<DailyChallenge> getByDifficulty(int difficulty) {
    return getAllChallenges().where((c) => c.difficulty == difficulty).toList();
  }

  /// Get random challenges for daily selection
  static List<DailyChallenge> getDailyChallenges({int count = 3}) {
    final allChallenges = getAllChallenges();
    allChallenges.shuffle();
    return allChallenges.take(count).toList();
  }

  /// Get difficulty text
  String get difficultyText {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Moderate';
      case 3:
        return 'Challenging';
      case 4:
        return 'Hard';
      case 5:
        return 'Expert';
      default:
        return 'Unknown';
    }
  }

  /// Get estimated time text
  String get estimatedTimeText {
    final minutes = estimatedTime.inMinutes;
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = estimatedTime.inHours;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0
          ? '${hours}h ${remainingMinutes}min'
          : '${hours}h';
    }
  }

  @override
  String toString() {
    return 'DailyChallenge(id: $id, title: $title, type: $type)';
  }
}

/// Model for user's daily challenge progress
class UserChallenge {
  final String challengeId;
  final DateTime assignedDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final Map<String, dynamic> progress;
  final bool isNew;

  const UserChallenge({
    required this.challengeId,
    required this.assignedDate,
    this.isCompleted = false,
    this.completedAt,
    this.progress = const {},
    this.isNew = true,
  });

  /// Create from Firestore data
  factory UserChallenge.fromFirestore(Map<String, dynamic> data) {
    return UserChallenge(
      challengeId: data['challengeId'] ?? '',
      assignedDate: DateTime.parse(
          data['assignedDate'] ?? DateTime.now().toIso8601String()),
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null
          ? DateTime.parse(data['completedAt'])
          : null,
      progress: Map<String, dynamic>.from(data['progress'] ?? {}),
      isNew: data['isNew'] ?? true,
    );
  }

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'challengeId': challengeId,
      'assignedDate': assignedDate.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'progress': progress,
      'isNew': isNew,
    };
  }

  /// Get the challenge details
  DailyChallenge? get challenge {
    return DailyChallenge.getAllChallenges()
        .where((c) => c.id == challengeId)
        .firstOrNull;
  }

  /// Calculate progress percentage (0.0 to 1.0)
  double getProgressPercentage() {
    if (isCompleted) return 1.0;

    final challenge = this.challenge;
    if (challenge == null) return 0.0;

    double totalProgress = 0.0;
    int criteriaCount = challenge.criteria.length;

    for (var criterion in challenge.criteria.entries) {
      final key = criterion.key;
      final required = criterion.value;
      final userValue = progress[key] ?? 0;

      if (required is num && userValue is num) {
        final progressValue = (userValue / required).clamp(0.0, 1.0);
        totalProgress += progressValue;
      } else if (required is bool && userValue is bool) {
        totalProgress += userValue ? 1.0 : 0.0;
      }
    }

    return criteriaCount > 0 ? totalProgress / criteriaCount : 0.0;
  }

  /// Check if challenge can be completed
  bool canComplete() {
    return !isCompleted && getProgressPercentage() >= 1.0;
  }
}
