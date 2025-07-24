import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../models/achievement.dart';
import '../../models/level_system.dart';
import '../../widgets/common/custom_button.dart';

class EnhancedDashboardScreen extends ConsumerStatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  ConsumerState<EnhancedDashboardScreen> createState() =>
      _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState
    extends ConsumerState<EnhancedDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Mock user data for demonstration
  UserModel get mockUser => UserModel(
        id: 'user123',
        email: 'user@example.com',
        displayName: 'Recovery Warrior',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
        currentStreak: 14,
        longestStreak: 30,
        totalEarned: 45.50,
        totalBitcoinEarned: 0.00123,
        habitType: HabitType.smoking,
        habitStartDate: DateTime.now().subtract(const Duration(days: 14)),
        selectedTriggers: [
          'Stress at work',
          'After meals',
          'Social situations'
        ],
        selectedAlternatives: ['Deep breathing', 'Chew gum', 'Go for a walk'],
        dailyGoalStreak: 365,
        totalXP: 1250,
        achievements: [
          UserAchievement(
            achievementId: 'first_day',
            unlockedAt: DateTime.now().subtract(const Duration(days: 13)),
          ),
          UserAchievement(
            achievementId: 'week_warrior',
            unlockedAt: DateTime.now().subtract(const Duration(days: 7)),
            isNew: true,
          ),
        ],
        dailyChallenges: [
          UserChallenge(
            challengeId: 'maintain_streak',
            assignedDate: DateTime.now(),
            isCompleted: true,
            completedAt: DateTime.now(),
          ),
          UserChallenge(
            challengeId: 'meditation_5min',
            assignedDate: DateTime.now(),
          ),
          UserChallenge(
            challengeId: 'walk_10min',
            assignedDate: DateTime.now(),
          ),
        ],
        helpsGiven: 3,
        likesReceived: 12,
        journalEntries: 8,
      );

  @override
  Widget build(BuildContext context) {
    final user = mockUser; // In real app, get from provider

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          slivers: [
            // App Bar with level display
            _buildSliverAppBar(user),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // New achievements notification
                  if (user.newAchievements.isNotEmpty)
                    _buildNewAchievementsBanner(user),

                  const SizedBox(height: 20),

                  // Main stats cards
                  _buildStatsGrid(user),

                  const SizedBox(height: 24),

                  // Daily challenges
                  _buildDailyChallengesSection(user),

                  const SizedBox(height: 24),

                  // Habit-specific content
                  _buildHabitSpecificSection(user),

                  const SizedBox(height: 24),

                  // Recent achievements
                  _buildRecentAchievements(user),

                  const SizedBox(height: 24),

                  // Social features preview
                  _buildSocialPreview(user),

                  const SizedBox(height: 24),

                  // Motivational section
                  _buildMotivationalSection(user),

                  const SizedBox(height: 100), // Bottom padding
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(user),
    );
  }

  Widget _buildSliverAppBar(UserModel user) {
    final userLevel = user.userLevel;
    final habitCategory = user.habitCategory;

    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: habitCategory?.primaryColor ?? const Color(0xFF1E293B),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Level ${userLevel.level} ${userLevel.title}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                habitCategory?.primaryColor ?? const Color(0xFF1E293B),
                habitCategory?.accentColor ?? const Color(0xFF334155),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Row(
              children: [
                // Level icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    userLevel.icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // XP progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${user.totalXP} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // XP Progress bar
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: userLevel.progressPercentage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${userLevel.xpToNext} XP to next level',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events),
          onPressed: () => _showAchievementsBottomSheet(),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
      ],
    );
  }

  Widget _buildNewAchievementsBanner(UserModel user) {
    final newAchievements = user.newAchievements;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.stars,
                  color: Color(0xFF0A0E27),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Achievement Unlocked!',
                        style: TextStyle(
                          color: Color(0xFF0A0E27),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${newAchievements.length} new badge${newAchievements.length == 1 ? '' : 's'} earned',
                        style: const TextStyle(
                          color: Color(0xFF0A0E27),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showAchievementsBottomSheet(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A0E27),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(UserModel user) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          'Current Streak',
          '${user.currentStreak}',
          'days clean',
          Icons.local_fire_department,
          const Color(0xFFFF5722),
          onTap: () => _showStreakDetails(user),
        ),
        _buildStatCard(
          'Total Earned',
          '\$${user.totalEarned.toStringAsFixed(0)}',
          '${(user.totalBitcoinEarned * 1000000).toStringAsFixed(0)} sats',
          Icons.currency_bitcoin,
          const Color(0xFFF7931A),
          onTap: () => Navigator.pushNamed(context, '/wallet'),
        ),
        _buildStatCard(
          'Level Progress',
          'Level ${user.userLevel.level}',
          '${user.userLevel.xpToNext} XP to go',
          user.userLevel.icon,
          user.userLevel.color,
          onTap: () => _showLevelDetails(user),
        ),
        _buildStatCard(
          'Achievements',
          '${user.achievements.length}',
          'badges earned',
          Icons.emoji_events,
          const Color(0xFFFFD700),
          onTap: () => _showAchievementsBottomSheet(),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String mainValue,
    String subValue,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              mainValue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subValue,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallengesSection(UserModel user) {
    final todaysChallenges = user.todaysChallenges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Challenges',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/challenges'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (todaysChallenges.isEmpty)
          _buildNoChallengesCard()
        else
          Column(
            children: todaysChallenges
                .map((challenge) => _buildChallengeCard(challenge))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildNoChallengesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            color: Colors.white.withOpacity(0.5),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'No challenges today',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New challenges will be available tomorrow',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(UserChallenge userChallenge) {
    final challenge = userChallenge.challenge;
    if (challenge == null) return const SizedBox();

    final progress = userChallenge.getProgressPercentage();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: userChallenge.isCompleted
              ? const Color(0xFF4CAF50)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Challenge icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: challenge.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              challenge.icon,
              color: challenge.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Challenge content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        challenge.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (userChallenge.isCompleted)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  challenge.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                // Progress bar
                if (!userChallenge.isCompleted)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(challenge.color),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toInt()}% complete',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '+${challenge.xpReward} XP',
                            style: const TextStyle(
                              color: Color(0xFFF7931A),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitSpecificSection(UserModel user) {
    final habitCategory = user.habitCategory;
    if (habitCategory == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            habitCategory.primaryColor.withOpacity(0.1),
            habitCategory.accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: habitCategory.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                habitCategory.icon,
                color: habitCategory.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  habitCategory.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quote of the day
          if (user.motivationalQuote != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Motivation',
                    style: TextStyle(
                      color: habitCategory.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${user.motivationalQuote}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Health benefit
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: habitCategory.accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  habitCategory.healthBenefit,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Financial benefit
          Row(
            children: [
              const Icon(
                Icons.savings,
                color: Color(0xFFF7931A),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  habitCategory.financialSaving,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements(UserModel user) {
    final recentAchievements = user.achievements.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Achievements',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _showAchievementsBottomSheet(),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentAchievements.isEmpty)
          _buildNoAchievementsCard()
        else
          Column(
            children: recentAchievements
                .map(
                    (userAchievement) => _buildAchievementCard(userAchievement))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildNoAchievementsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.white.withOpacity(0.5),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'No achievements yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first day to earn your first badge!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(UserAchievement userAchievement) {
    final achievement = userAchievement.achievement;
    if (achievement == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.rarityColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Achievement icon with rarity border
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: achievement.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: achievement.rarityColor,
                width: 2,
              ),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Achievement content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (userAchievement.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5722),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NEW!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      achievement.rarityText,
                      style: TextStyle(
                        color: achievement.rarityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '+${achievement.xpReward} XP',
                      style: const TextStyle(
                        color: Color(0xFFF7931A),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialPreview(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Community',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/community'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSocialStat(
                  'Helps Given',
                  '${user.helpsGiven}',
                  Icons.helping_hand,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSocialStat(
                  'Likes Received',
                  '${user.likesReceived}',
                  Icons.thumb_up,
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalSection(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9C27B0).withOpacity(0.2),
            const Color(0xFF673AB7).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF9C27B0).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.rocket_launch,
            color: Color(0xFF9C27B0),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Keep Going!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re ${user.daysToNextMilestone} days away from your next milestone!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'View Progress',
            onPressed: () => _showProgressDetails(user),
            isLoading: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(UserModel user) {
    return FloatingActionButton.extended(
      onPressed: user.canCheckIn ? () => _performDailyCheckIn(user) : null,
      backgroundColor: user.canCheckIn ? const Color(0xFFF7931A) : Colors.grey,
      icon: Icon(
        user.canCheckIn ? Icons.check_circle : Icons.check_circle_outline,
        color: Colors.white,
      ),
      label: Text(
        user.canCheckIn ? 'Check In' : 'Checked In',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Action methods
  void _showAchievementsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0E27),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: const Column(
          children: [
            Text(
              'Achievements',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Add achievements list here
          ],
        ),
      ),
    );
  }

  void _showStreakDetails(UserModel user) {
    // Show streak details dialog
  }

  void _showLevelDetails(UserModel user) {
    // Show level progression dialog
  }

  void _showProgressDetails(UserModel user) {
    // Show detailed progress view
  }

  void _performDailyCheckIn(UserModel user) {
    // Perform daily check-in logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daily check-in completed! +50 XP earned'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }
}
