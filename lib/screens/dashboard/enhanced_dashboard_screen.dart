import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../models/user_model.dart';
import '../../models/achievement.dart';
import '../../models/level_system.dart';
import '../../models/habit_category.dart';
import '../../widgets/common/custom_button.dart';
import '../community/community_forum_screen.dart';

class EnhancedDashboardScreen extends ConsumerStatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  ConsumerState<EnhancedDashboardScreen> createState() =>
      _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState
    extends ConsumerState<EnhancedDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _pulseController;
  late Animation<double> _heroFadeAnimation;
  late Animation<double> _heroScaleAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _pulseAnimation;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _heroFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _heroScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _heroAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _cardAnimationController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Mock user data for demonstration
  UserModel get mockUser => UserModel(
        id: 'user123',
        email: 'user@example.com',
        displayName: 'Recovery Champion',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
        currentStreak: 14,
        longestStreak: 30,
        totalEarned: 245.50,
        totalBitcoinEarned: 0.00523,
        habitType: HabitType.smoking,
        habitStartDate: DateTime.now().subtract(const Duration(days: 14)),
        selectedTriggers: [
          'Stress at work',
          'After meals',
          'Social situations'
        ],
        selectedAlternatives: ['Deep breathing', 'Chew gum', 'Go for a walk'],
        dailyGoalStreak: 365,
        totalXP: 2450,
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
          UserAchievement(
            achievementId: 'streak_legend',
            unlockedAt: DateTime.now().subtract(const Duration(hours: 2)),
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
        helpsGiven: 28,
        likesReceived: 142,
        journalEntries: 24,
      );

  @override
  Widget build(BuildContext context) {
    final user = mockUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0B0D),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(user),
      body: _buildBody(user),
      floatingActionButton: _buildFloatingActionButton(user),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(UserModel user) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: const Icon(
            Icons.menu_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Stack(
              children: [
                const Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                if (user.newAchievements.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          onPressed: () => _showNotifications(),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => _showProfile(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    user.habitCategory?.primaryColor ?? const Color(0xFF6366F1),
                    user.habitCategory?.accentColor ?? const Color(0xFF8B5CF6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  user.displayName?[0].toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(UserModel user) {
    return Container(
      decoration: _buildBackgroundGradient(user),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Hero Section
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _heroAnimationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _heroFadeAnimation,
                    child: ScaleTransition(
                      scale: _heroScaleAnimation,
                      child: _buildHeroSection(user),
                    ),
                  );
                },
              ),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _cardAnimationController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _cardSlideAnimation,
                    child: FadeTransition(
                      opacity: _cardFadeAnimation,
                      child: _buildMainContent(user),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundGradient(UserModel user) {
    final primaryColor =
        user.habitCategory?.primaryColor ?? const Color(0xFF6366F1);
    final accentColor =
        user.habitCategory?.accentColor ?? const Color(0xFF8B5CF6);

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0A0B0D),
          primaryColor.withOpacity(0.1),
          const Color(0xFF0A0B0D),
          accentColor.withOpacity(0.08),
          const Color(0xFF0A0B0D),
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ),
    );
  }

  Widget _buildHeroSection(UserModel user) {
    final userLevel = user.userLevel;
    final habitCategory = user.habitCategory;

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Text
          Text(
            'Welcome back,',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.displayName ?? 'Recovery Champion',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),

          // Level Progress Card
          _buildGlassMorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            userLevel.color,
                            userLevel.color.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: userLevel.color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        userLevel.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level ${userLevel.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userLevel.title,
                            style: TextStyle(
                              color: userLevel.color,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${user.totalXP}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total XP',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // XP Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress to Level ${userLevel.level + 1}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${userLevel.xpToNext} XP to go',
                          style: TextStyle(
                            color: userLevel.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: userLevel.progressPercentage,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    userLevel.color,
                                    userLevel.color.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: userLevel.color.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildMainContent(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // New Achievements Banner
          if (user.newAchievements.isNotEmpty) ...[
            _buildNewAchievementsBanner(user),
            const SizedBox(height: 20),
          ],

          // Stats Overview
          _buildStatsOverview(user),
          const SizedBox(height: 24),

          // Today's Focus
          _buildTodaysFocus(user),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(user),
          const SizedBox(height: 24),

          // Community Insights
          _buildCommunityInsights(user),
          const SizedBox(height: 24),

          // Habit Journey
          _buildHabitJourney(user),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildGlassMorphicCard({
    required Widget child,
    EdgeInsets? padding,
    Color? borderColor,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }

  Widget _buildNewAchievementsBanner(UserModel user) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFFF8A00),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎉 Achievement Unlocked!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.newAchievements.length} new badge${user.newAchievements.length == 1 ? '' : 's'} earned',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsOverview(UserModel user) {
    return _buildGlassMorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '${user.currentStreak}',
                  'Days Clean',
                  Icons.local_fire_department_rounded,
                  const Color(0xFFFF6B35),
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withOpacity(0.1),
              ),
              Expanded(
                child: _buildStatItem(
                  '\$${user.totalEarned.toStringAsFixed(0)}',
                  'Earned',
                  Icons.currency_bitcoin_rounded,
                  const Color(0xFFF7931A),
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withOpacity(0.1),
              ),
              Expanded(
                child: _buildStatItem(
                  '${user.achievements.length}',
                  'Badges',
                  Icons.emoji_events_rounded,
                  const Color(0xFFFFD700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysFocus(UserModel user) {
    final todaysChallenges = user.todaysChallenges.take(2).toList();

    return _buildGlassMorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Focus',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${user.completedChallengesCount}/${todaysChallenges.length} Complete',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (todaysChallenges.isEmpty)
            _buildEmptyState(
              icon: Icons.task_alt_rounded,
              title: 'All challenges completed!',
              subtitle: 'Great job! New challenges tomorrow.',
            )
          else
            Column(
              children: todaysChallenges
                  .map((challenge) => _buildChallengeCard(challenge))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(UserChallenge userChallenge) {
    final challenge = userChallenge.challenge;
    if (challenge == null) return const SizedBox();

    final progress = userChallenge.getProgressPercentage();
    final isCompleted = userChallenge.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF4CAF50).withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: challenge.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : challenge.icon,
              color: isCompleted ? const Color(0xFF4CAF50) : challenge.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                if (!isCompleted) ...[
                  Text(
                    challenge.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(challenge.color),
                    minHeight: 4,
                  ),
                ],
              ],
            ),
          ),
          Text(
            '+${challenge.xpReward} XP',
            style: TextStyle(
              color: isCompleted
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFF7931A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(UserModel user) {
    return _buildGlassMorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Community',
                  Icons.people_rounded,
                  const Color(0xFF6366F1),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommunityForumScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Analytics',
                  Icons.bar_chart_rounded,
                  const Color(0xFF8B5CF6),
                  () => _showAnalytics(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Wallet',
                  Icons.account_balance_wallet_rounded,
                  const Color(0xFFF7931A),
                  () => _navigateToWallet(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityInsights(UserModel user) {
    return _buildGlassMorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Community Impact',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active Helper',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSocialStat(
                  '${user.helpsGiven}',
                  'Helps Given',
                  Icons.favorite_rounded,
                  const Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSocialStat(
                  '${user.likesReceived}',
                  'Likes Received',
                  Icons.thumb_up_rounded,
                  const Color(0xFF4ECDC4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSocialStat(
                  '${user.journalEntries}',
                  'Journal Entries',
                  Icons.edit_note_rounded,
                  const Color(0xFFFFBE0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialStat(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHabitJourney(UserModel user) {
    final habitCategory = user.habitCategory;
    if (habitCategory == null) return const SizedBox();

    return _buildGlassMorphicCard(
      borderColor: habitCategory.primaryColor.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      habitCategory.primaryColor,
                      habitCategory.accentColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  habitCategory.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habitCategory.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Day ${user.currentStreak} of your journey',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Daily motivation
          if (user.motivationalQuote != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: habitCategory.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: habitCategory.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Motivation',
                    style: TextStyle(
                      color: habitCategory.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${user.motivationalQuote}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.5),
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(UserModel user) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: FloatingActionButton.extended(
        onPressed: user.canCheckIn ? () => _performDailyCheckIn(user) : null,
        backgroundColor: user.canCheckIn
            ? const Color(0xFF4CAF50)
            : Colors.grey.withOpacity(0.3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        label: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                user.canCheckIn
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                user.canCheckIn
                    ? 'Complete Daily Check-in'
                    : 'Already Checked In Today',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action methods
  void _showNotifications() {
    // Show notifications
  }

  void _showProfile() {
    // Show user profile
  }

  void _showAnalytics() {
    // Show analytics screen
  }

  void _navigateToWallet() {
    // Navigate to wallet
  }

  void _performDailyCheckIn(UserModel user) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Daily check-in completed! +50 XP earned',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}
