import 'package:flutter/material.dart';

/// Enum for different types of achievements
enum AchievementType {
  streak, // Based on consecutive days
  milestone, // Specific day targets
  social, // Community interactions
  challenge, // Daily/weekly challenges
  personal, // Custom achievements
  financial, // Bitcoin earnings
  health, // Health improvements
  special // Limited time events
}

/// Enum for achievement rarity/difficulty
enum AchievementRarity {
  common, // Easy to get
  uncommon, // Moderate effort
  rare, // Significant effort
  epic, // Major milestone
  legendary // Extraordinary achievement
}

/// Model representing an individual achievement
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementType type;
  final AchievementRarity rarity;
  final int xpReward;
  final double? bitcoinReward;
  final Map<String, dynamic> criteria; // Flexible criteria system
  final List<String> tags;
  final bool isHidden; // Hidden until unlocked
  final DateTime? availableFrom;
  final DateTime? availableUntil;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.rarity,
    required this.xpReward,
    this.bitcoinReward,
    required this.criteria,
    this.tags = const [],
    this.isHidden = false,
    this.availableFrom,
    this.availableUntil,
  });

  /// Get all predefined achievements
  static List<Achievement> getAllAchievements() {
    return [
      // STREAK ACHIEVEMENTS
      Achievement(
        id: 'first_day',
        title: 'First Step',
        description: 'Complete your first day clean',
        icon: Icons.baby_changing_station,
        color: const Color(0xFF4CAF50),
        type: AchievementType.streak,
        rarity: AchievementRarity.common,
        xpReward: 50,
        bitcoinReward: 1.0,
        criteria: {'streak_days': 1},
        tags: ['beginner', 'milestone'],
      ),

      Achievement(
        id: 'week_warrior',
        title: 'Week Warrior',
        description: 'Stay clean for 7 consecutive days',
        icon: Icons.calendar_view_week,
        color: const Color(0xFF2196F3),
        type: AchievementType.streak,
        rarity: AchievementRarity.uncommon,
        xpReward: 200,
        bitcoinReward: 5.0,
        criteria: {'streak_days': 7},
        tags: ['week', 'consistency'],
      ),

      Achievement(
        id: 'month_master',
        title: 'Month Master',
        description: 'Achieve 30 days of freedom',
        icon: Icons.calendar_month,
        color: const Color(0xFF9C27B0),
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        xpReward: 500,
        bitcoinReward: 15.0,
        criteria: {'streak_days': 30},
        tags: ['month', 'major'],
      ),

      Achievement(
        id: 'quarter_champion',
        title: 'Quarter Champion',
        description: 'Maintain 90 days of sobriety',
        icon: Icons.emoji_events,
        color: const Color(0xFFFF9800),
        type: AchievementType.streak,
        rarity: AchievementRarity.epic,
        xpReward: 1000,
        bitcoinReward: 50.0,
        criteria: {'streak_days': 90},
        tags: ['quarter', 'champion'],
      ),

      Achievement(
        id: 'year_legend',
        title: 'Year Legend',
        description: 'One full year of recovery',
        icon: Icons.star,
        color: const Color(0xFFFFD700),
        type: AchievementType.streak,
        rarity: AchievementRarity.legendary,
        xpReward: 5000,
        bitcoinReward: 200.0,
        criteria: {'streak_days': 365},
        tags: ['year', 'legendary'],
      ),

      // SOCIAL ACHIEVEMENTS
      Achievement(
        id: 'helpful_friend',
        title: 'Helpful Friend',
        description: 'Help 5 community members',
        icon: Icons.people_alt,
        color: const Color(0xFF4CAF50),
        type: AchievementType.social,
        rarity: AchievementRarity.uncommon,
        xpReward: 300,
        criteria: {'helps_given': 5},
        tags: ['community', 'helping'],
      ),

      Achievement(
        id: 'motivator',
        title: 'Motivator',
        description: 'Receive 25 likes on your posts',
        icon: Icons.thumb_up,
        color: const Color(0xFF2196F3),
        type: AchievementType.social,
        rarity: AchievementRarity.rare,
        xpReward: 400,
        criteria: {'likes_received': 25},
        tags: ['social', 'popular'],
      ),

      // CHALLENGE ACHIEVEMENTS
      Achievement(
        id: 'daily_champion',
        title: 'Daily Champion',
        description: 'Complete 7 daily challenges',
        icon: Icons.task_alt,
        color: const Color(0xFFE91E63),
        type: AchievementType.challenge,
        rarity: AchievementRarity.uncommon,
        xpReward: 250,
        criteria: {'daily_challenges_completed': 7},
        tags: ['challenge', 'consistent'],
      ),

      Achievement(
        id: 'challenge_master',
        title: 'Challenge Master',
        description: 'Complete 30 daily challenges',
        icon: Icons.psychology,
        color: const Color(0xFF9C27B0),
        type: AchievementType.challenge,
        rarity: AchievementRarity.rare,
        xpReward: 750,
        bitcoinReward: 10.0,
        criteria: {'daily_challenges_completed': 30},
        tags: ['challenge', 'master'],
      ),

      // FINANCIAL ACHIEVEMENTS
      Achievement(
        id: 'first_earnings',
        title: 'First Earnings',
        description: 'Earn your first Bitcoin reward',
        icon: Icons.currency_bitcoin,
        color: const Color(0xFFF7931A),
        type: AchievementType.financial,
        rarity: AchievementRarity.common,
        xpReward: 100,
        criteria: {'total_btc_earned': 0.001},
        tags: ['bitcoin', 'first'],
      ),

      Achievement(
        id: 'bitcoin_collector',
        title: 'Bitcoin Collector',
        description: 'Earn \$100 worth of Bitcoin',
        icon: Icons.account_balance_wallet,
        color: const Color(0xFFF7931A),
        type: AchievementType.financial,
        rarity: AchievementRarity.epic,
        xpReward: 1500,
        criteria: {'total_usd_earned': 100.0},
        tags: ['bitcoin', 'wealth'],
      ),

      // HEALTH ACHIEVEMENTS
      Achievement(
        id: 'health_improver',
        title: 'Health Improver',
        description: 'Track health improvements for 14 days',
        icon: Icons.favorite,
        color: const Color(0xFFE91E63),
        type: AchievementType.health,
        rarity: AchievementRarity.uncommon,
        xpReward: 300,
        criteria: {'health_logs': 14},
        tags: ['health', 'tracking'],
      ),

      // SPECIAL ACHIEVEMENTS
      Achievement(
        id: 'early_adopter',
        title: 'Early Adopter',
        description: 'Joined QuitForBit in its first month',
        icon: Icons.rocket_launch,
        color: const Color(0xFF673AB7),
        type: AchievementType.special,
        rarity: AchievementRarity.legendary,
        xpReward: 2000,
        bitcoinReward: 25.0,
        criteria: {'joined_before': '2024-02-01'},
        tags: ['special', 'exclusive'],
        isHidden: true,
      ),

      Achievement(
        id: 'comeback_kid',
        title: 'Comeback Kid',
        description: 'Start a new streak after a relapse',
        icon: Icons.refresh,
        color: const Color(0xFF607D8B),
        type: AchievementType.personal,
        rarity: AchievementRarity.uncommon,
        xpReward: 200,
        criteria: {'comebacks': 1},
        tags: ['resilience', 'comeback'],
      ),
    ];
  }

  /// Get achievements by type
  static List<Achievement> getByType(AchievementType type) {
    return getAllAchievements().where((a) => a.type == type).toList();
  }

  /// Get achievements by rarity
  static List<Achievement> getByRarity(AchievementRarity rarity) {
    return getAllAchievements().where((a) => a.rarity == rarity).toList();
  }

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return getAllAchievements().firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if user meets criteria for this achievement
  bool checkCriteria(Map<String, dynamic> userStats) {
    for (var criterion in criteria.entries) {
      final key = criterion.key;
      final required = criterion.value;
      final userValue = userStats[key];

      if (userValue == null) return false;

      // Handle different data types
      if (required is num && userValue is num) {
        if (userValue < required) return false;
      } else if (required is String && userValue is String) {
        if (userValue != required) return false;
      } else if (required is DateTime && userValue is DateTime) {
        if (userValue.isAfter(required)) return false;
      }
    }
    return true;
  }

  /// Get display text for rarity
  String get rarityText {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.uncommon:
        return 'Uncommon';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  /// Get rarity color
  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return const Color(0xFF9E9E9E);
      case AchievementRarity.uncommon:
        return const Color(0xFF4CAF50);
      case AchievementRarity.rare:
        return const Color(0xFF2196F3);
      case AchievementRarity.epic:
        return const Color(0xFF9C27B0);
      case AchievementRarity.legendary:
        return const Color(0xFFFFD700);
    }
  }

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, rarity: $rarity)';
  }
}

/// Model for user's achievement progress
class UserAchievement {
  final String achievementId;
  final DateTime unlockedAt;
  final bool isNew; // For showing "NEW!" badge
  final Map<String, dynamic> progress; // Current progress toward achievement

  const UserAchievement({
    required this.achievementId,
    required this.unlockedAt,
    this.isNew = false,
    this.progress = const {},
  });

  /// Create from Firestore data
  factory UserAchievement.fromFirestore(Map<String, dynamic> data) {
    return UserAchievement(
      achievementId: data['achievementId'] ?? '',
      unlockedAt: DateTime.parse(
          data['unlockedAt'] ?? DateTime.now().toIso8601String()),
      isNew: data['isNew'] ?? false,
      progress: Map<String, dynamic>.from(data['progress'] ?? {}),
    );
  }

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'achievementId': achievementId,
      'unlockedAt': unlockedAt.toIso8601String(),
      'isNew': isNew,
      'progress': progress,
    };
  }

  /// Get the achievement details
  Achievement? get achievement => Achievement.getById(achievementId);

  /// Calculate progress percentage (0.0 to 1.0)
  double getProgressPercentage(Map<String, dynamic> userStats) {
    final achievement = this.achievement;
    if (achievement == null) return 0.0;

    double totalProgress = 0.0;
    int criteriaCount = achievement.criteria.length;

    for (var criterion in achievement.criteria.entries) {
      final key = criterion.key;
      final required = criterion.value;
      final userValue = userStats[key] ?? 0;

      if (required is num && userValue is num) {
        final progress = (userValue / required).clamp(0.0, 1.0);
        totalProgress += progress;
      } else {
        // For non-numeric criteria, it's either met (1.0) or not (0.0)
        totalProgress += userValue == required ? 1.0 : 0.0;
      }
    }

    return criteriaCount > 0 ? totalProgress / criteriaCount : 0.0;
  }
}
