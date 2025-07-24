import 'package:flutter/material.dart';

/// Enum representing different habit categories for addiction recovery
enum HabitType {
  smoking,
  alcohol,
  drugs,
  socialMedia,
  gambling,
  shopping,
  gaming,
  pornography,
  fastFood,
  caffeine,
  custom
}

/// Model representing a habit category with specific properties and rewards
class HabitCategory {
  final HabitType type;
  final String name;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color accentColor;
  final List<String> commonTriggers;
  final List<String> replacementActivities;
  final Map<int, double> milestoneRewards; // Day -> Bitcoin amount
  final List<String> motivationalQuotes;
  final String healthBenefit;
  final String financialSaving;

  const HabitCategory({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.accentColor,
    required this.commonTriggers,
    required this.replacementActivities,
    required this.milestoneRewards,
    required this.motivationalQuotes,
    required this.healthBenefit,
    required this.financialSaving,
  });

  /// Get predefined habit categories
  static List<HabitCategory> getAllCategories() {
    return [
      // Smoking Cessation
      HabitCategory(
        type: HabitType.smoking,
        name: 'Quit Smoking',
        description:
            'Break free from nicotine addiction and improve your health',
        icon: Icons.smoke_free,
        primaryColor: const Color(0xFF2E7D32), // Green
        accentColor: const Color(0xFF66BB6A),
        commonTriggers: [
          'Stress at work',
          'Social situations',
          'After meals',
          'Drinking alcohol',
          'Morning coffee',
          'Break time',
          'Driving'
        ],
        replacementActivities: [
          'Deep breathing exercises',
          'Chew gum or toothpicks',
          'Go for a walk',
          'Drink water',
          'Call a friend',
          'Do push-ups',
          'Practice meditation'
        ],
        milestoneRewards: {
          1: 5.0, // $5 for day 1
          3: 10.0, // $10 for 3 days
          7: 25.0, // $25 for 1 week
          14: 50.0, // $50 for 2 weeks
          30: 100.0, // $100 for 1 month
          90: 200.0, // $200 for 3 months
          365: 500.0, // $500 for 1 year
        },
        motivationalQuotes: [
          'Every cigarette you don\'t smoke is saving your life',
          'You\'re stronger than your addiction',
          'Clean lungs, clear mind, brighter future',
          'Today is a smoke-free victory'
        ],
        healthBenefit: 'Lungs begin healing within 20 minutes',
        financialSaving: 'Save \$2,000+ per year',
      ),

      // Alcohol Recovery
      HabitCategory(
        type: HabitType.alcohol,
        name: 'Quit Drinking',
        description: 'Overcome alcohol dependency and reclaim your life',
        icon: Icons.local_bar_outlined,
        primaryColor: const Color(0xFF1565C0), // Blue
        accentColor: const Color(0xFF42A5F5),
        commonTriggers: [
          'Social gatherings',
          'Stress and anxiety',
          'After work',
          'Weekend activities',
          'Emotional distress',
          'Peer pressure',
          'Celebrations'
        ],
        replacementActivities: [
          'Drink sparkling water',
          'Exercise or yoga',
          'Meet sober friends',
          'Attend AA meetings',
          'Practice hobbies',
          'Journal writing',
          'Meditation'
        ],
        milestoneRewards: {
          1: 10.0,
          7: 50.0,
          14: 100.0,
          30: 200.0,
          60: 300.0,
          90: 500.0,
          365: 1000.0,
        },
        motivationalQuotes: [
          'Sobriety is the greatest gift you can give yourself',
          'Clear mind, clear choices, clear future',
          'One day at a time, one choice at a time',
          'Your future self will thank you'
        ],
        healthBenefit: 'Liver function improves significantly',
        financialSaving: 'Save \$3,000+ per year',
      ),

      // Drug Recovery
      HabitCategory(
        type: HabitType.drugs,
        name: 'Drug Recovery',
        description: 'Break free from substance dependency with support',
        icon: Icons.healing,
        primaryColor: const Color(0xFF7B1FA2), // Purple
        accentColor: const Color(0xFFAB47BC),
        commonTriggers: [
          'Emotional pain',
          'Social pressure',
          'Stress and trauma',
          'Boredom',
          'Depression',
          'Certain locations',
          'Old friend groups'
        ],
        replacementActivities: [
          'Call your sponsor',
          'Attend support groups',
          'Physical exercise',
          'Creative activities',
          'Volunteer work',
          'Learn new skills',
          'Professional counseling'
        ],
        milestoneRewards: {
          1: 15.0,
          3: 30.0,
          7: 75.0,
          14: 150.0,
          30: 300.0,
          90: 600.0,
          365: 1500.0,
        },
        motivationalQuotes: [
          'Recovery is possible, you are worth it',
          'Every clean day is a victory',
          'Strength grows in the moments you think you can\'t go on',
          'Your life has value beyond addiction'
        ],
        healthBenefit: 'Body and mind begin natural healing',
        financialSaving: 'Save thousands per year',
      ),

      // Social Media Detox
      HabitCategory(
        type: HabitType.socialMedia,
        name: 'Social Media Detox',
        description: 'Reclaim your time and mental health from social media',
        icon: Icons.phone_android_outlined,
        primaryColor: const Color(0xFFE65100), // Orange
        accentColor: const Color(0xFFFF9800),
        commonTriggers: [
          'Boredom',
          'Waiting in lines',
          'Before bed',
          'After waking up',
          'Feeling lonely',
          'Work breaks',
          'Habit checking'
        ],
        replacementActivities: [
          'Read a book',
          'Call a real friend',
          'Go for a walk',
          'Practice a hobby',
          'Exercise',
          'Write in a journal',
          'Learn something new'
        ],
        milestoneRewards: {
          1: 2.0,
          3: 5.0,
          7: 15.0,
          14: 30.0,
          30: 60.0,
          90: 150.0,
          365: 400.0,
        },
        motivationalQuotes: [
          'Real life happens offline',
          'Your worth isn\'t measured in likes',
          'Focus on connections, not comparisons',
          'Time is your most valuable asset'
        ],
        healthBenefit: 'Reduced anxiety and better sleep',
        financialSaving: 'Save time worth thousands in productivity',
      ),

      // Gambling Recovery
      HabitCategory(
        type: HabitType.gambling,
        name: 'Quit Gambling',
        description: 'Break the cycle of gambling addiction and financial loss',
        icon: Icons.casino_outlined,
        primaryColor: const Color(0xFFD32F2F), // Red
        accentColor: const Color(0xFFEF5350),
        commonTriggers: [
          'Financial stress',
          'Emotional distress',
          'Boredom',
          'Social pressure',
          'Winning streaks',
          'Chasing losses',
          'Special events'
        ],
        replacementActivities: [
          'Call gambling helpline',
          'Exercise vigorously',
          'Meet supportive friends',
          'Engage in hobbies',
          'Budget planning',
          'Attend GA meetings',
          'Practice mindfulness'
        ],
        milestoneRewards: {
          1: 20.0,
          7: 100.0,
          14: 200.0,
          30: 400.0,
          60: 600.0,
          90: 800.0,
          365: 2000.0,
        },
        motivationalQuotes: [
          'The house always wins, but you can choose not to play',
          'Your financial freedom is worth more than any jackpot',
          'Small steps lead to big recoveries',
          'Every dollar saved is a victory'
        ],
        healthBenefit: 'Reduced stress and anxiety levels',
        financialSaving: 'Could save tens of thousands per year',
      ),

      // Custom Habit
      HabitCategory(
        type: HabitType.custom,
        name: 'Custom Habit',
        description: 'Create your own personalized habit tracking',
        icon: Icons.edit_outlined,
        primaryColor: const Color(0xFF5E35B1), // Deep Purple
        accentColor: const Color(0xFF7E57C2),
        commonTriggers: ['Define your own triggers'],
        replacementActivities: ['Define your own alternatives'],
        milestoneRewards: {
          1: 1.0,
          7: 10.0,
          30: 50.0,
          90: 100.0,
          365: 300.0,
        },
        motivationalQuotes: [
          'You have the power to change your life',
          'Small changes lead to big transformations',
          'Consistency is the key to success',
          'Every day is a new opportunity'
        ],
        healthBenefit: 'Improved overall well-being',
        financialSaving: 'Savings depend on your habit',
      ),
    ];
  }

  /// Get category by type
  static HabitCategory? getByType(HabitType type) {
    try {
      return getAllCategories().firstWhere((category) => category.type == type);
    } catch (e) {
      return null;
    }
  }

  /// Get total potential reward for reaching all milestones
  double get totalPotentialReward {
    return milestoneRewards.values.fold(0.0, (sum, reward) => sum + reward);
  }

  /// Get next milestone day and reward
  MapEntry<int, double>? getNextMilestone(int currentStreak) {
    for (var entry in milestoneRewards.entries) {
      if (entry.key > currentStreak) {
        return entry;
      }
    }
    return null; // All milestones completed
  }

  /// Get reward for specific day if it exists
  double? getRewardForDay(int day) {
    return milestoneRewards[day];
  }

  @override
  String toString() {
    return 'HabitCategory(type: $type, name: $name)';
  }
}
