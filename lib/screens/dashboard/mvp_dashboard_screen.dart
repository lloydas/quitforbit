import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/streak_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../wallet/send_bitcoin_screen.dart';

class MVPDashboardScreen extends ConsumerStatefulWidget {
  const MVPDashboardScreen({super.key});

  @override
  ConsumerState<MVPDashboardScreen> createState() => _MVPDashboardScreenState();
}

class _MVPDashboardScreenState extends ConsumerState<MVPDashboardScreen> {
  bool _isCheckingIn = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(streakProvider);
    final nextMilestone = ref.watch(nextMilestoneProvider);
    final bitcoinPriceAsync = ref.watch(bitcoinPriceProvider);
    final balanceAsync = ref.watch(userBitcoinBalanceProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'QuitForBit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showProfileMenu(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(streakProvider.notifier).refresh();
        },
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Retry',
                      onPressed:
                          () => ref.read(streakProvider.notifier).refresh(),
                    ),
                  ],
                ),
              ),
          data: (user) {
            if (user == null) {
              return const Center(child: Text('No user data'));
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome message
                  _buildWelcomeCard(user.displayName),
                  const SizedBox(height: 24),

                  // Main streak counter
                  _buildStreakCard(user),
                  const SizedBox(height: 24),

                  // Bitcoin balance card
                  _buildBitcoinCard(user, bitcoinPriceAsync, balanceAsync),
                  const SizedBox(height: 24),

                  // Next milestone card
                  _buildNextMilestoneCard(nextMilestone),
                  const SizedBox(height: 24),

                  // Daily check-in button
                  _buildCheckInButton(user),
                  const SizedBox(height: 16),

                  // Panic button
                  _buildPanicButton(),
                  const SizedBox(height: 24),

                  // Quick stats
                  _buildQuickStats(user),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String displayName) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${displayName.split(' ').first}! 👋',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Every day clean is a victory. Keep building your streak and earning Bitcoin!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(user) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              user.currentStreak.toString(),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.streakDisplayText,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (user.longestStreak > user.currentStreak) ...[
              const SizedBox(height: 12),
              Text(
                'Personal best: ${user.longestStreak} days',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBitcoinCard(
    user,
    AsyncValue<double> bitcoinPriceAsync,
    AsyncValue<double> balanceAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '₿',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Bitcoin Wallet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'TESTNET',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Current Balance
            const Text(
              'Current Balance',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            balanceAsync.when(
              data:
                  (balance) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${balance.toStringAsFixed(8)} BTC',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      bitcoinPriceAsync.when(
                        data:
                            (price) => Text(
                              '≈ \$${(balance * price).toStringAsFixed(2)} USD',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                        loading: () => const Text('Loading USD value...'),
                        error: (_, __) => const Text('USD value unavailable'),
                      ),
                    ],
                  ),
              loading: () => const Text('Loading balance...'),
              error: (_, __) => const Text('Balance unavailable'),
            ),
            const SizedBox(height: 16),
            // Total Earned
            const Text(
              'Total Earned',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              user.totalEarnedDisplayText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            // Action buttons
            if (!user.hasBitcoinWallet) ...[
              CustomButton(
                text: 'Set Up Bitcoin Wallet',
                onPressed: () => _setupBitcoinWallet(),
                backgroundColor: Colors.orange,
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Send Bitcoin',
                      onPressed: () => _navigateToSendBitcoin(),
                      backgroundColor: Colors.orange,
                      icon: Icons.send,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'History',
                      onPressed: () => _showTransactionHistory(),
                      isOutlined: true,
                      icon: Icons.history,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNextMilestoneCard(Map<String, dynamic> nextMilestone) {
    final target = nextMilestone['target'] as int;
    final daysLeft = nextMilestone['daysLeft'] as int;
    final reward = nextMilestone['reward'] as double;
    final title = nextMilestone['title'] as String;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Next Milestone',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (daysLeft > 0)
              Text(
                '$daysLeft day${daysLeft == 1 ? '' : 's'} to go',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              )
            else
              const Text(
                'Achieved! Check in to claim reward',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    '\$${reward.toStringAsFixed(2)} Bitcoin Reward',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInButton(user) {
    final canCheckIn = user.canCheckIn;

    return CustomButton(
      text:
          _isCheckingIn
              ? 'Checking in...'
              : canCheckIn
              ? 'Daily Check-in'
              : 'Already checked in today ✓',
      onPressed: canCheckIn && !_isCheckingIn ? _performCheckIn : null,
      backgroundColor: canCheckIn ? Colors.green : Colors.grey,
      isLoading: _isCheckingIn,
    );
  }

  Widget _buildPanicButton() {
    return CustomButton(
      text: '😰 Panic Button',
      onPressed: () => _showPanicDialog(),
      backgroundColor: Colors.red,
    );
  }

  Widget _buildQuickStats(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Current Streak',
                    '${user.currentStreak} days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Personal Best',
                    '${user.longestStreak} days',
                    Icons.emoji_events,
                    Colors.yellow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Earned',
                    user.totalEarnedDisplayText,
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Member Since',
                    _formatDate(user.createdAt),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _performCheckIn() async {
    setState(() {
      _isCheckingIn = true;
    });

    try {
      final success = await ref.read(streakProvider.notifier).checkIn();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Check-in successful! Keep up the great work!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingIn = false;
        });
      }
    }
  }

  Future<void> _setupBitcoinWallet() async {
    try {
      final success =
          await ref.read(streakProvider.notifier).setupBitcoinWallet();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 Bitcoin wallet set up! You earned your first \$1!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting up wallet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPanicDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('🛑 Take a Deep Breath'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You\'re feeling an urge right now. That\'s normal. Remember:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  '• This feeling will pass\n'
                  '• You\'ve come this far\n'
                  '• Your Bitcoin rewards are waiting\n'
                  '• You are stronger than this urge',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('I\'m OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startBreathingExercise();
                },
                child: const Text('Breathing Exercise'),
              ),
            ],
          ),
    );
  }

  void _startBreathingExercise() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const BreathingExerciseDialog(),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text('Transaction History'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to transaction history
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: const Text('Reset Streak'),
                  onTap: () {
                    Navigator.pop(context);
                    _showResetDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(authNotifierProvider.notifier).signOut();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Streak'),
            content: const Text(
              'Are you sure you want to reset your streak? This action cannot be undone, but you\'ll keep your Bitcoin earnings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await ref.read(streakProvider.notifier).handleRelapse();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  void _navigateToSendBitcoin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SendBitcoinScreen()));
  }

  void _showTransactionHistory() {
    // TODO: Implement transaction history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Transaction history will be available in a future update',
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// Simple breathing exercise widget
class BreathingExerciseDialog extends StatefulWidget {
  const BreathingExerciseDialog({super.key});

  @override
  State<BreathingExerciseDialog> createState() =>
      _BreathingExerciseDialogState();
}

class _BreathingExerciseDialogState extends State<BreathingExerciseDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _cycleCount = 0;
  String _instruction = 'Breathe in...';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _instruction = 'Breathe out...';
        });
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _cycleCount++;
          _instruction = 'Breathe in...';
        });
        if (_cycleCount < 5) {
          _animationController.forward();
        } else {
          Navigator.pop(context);
        }
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Breathing Exercise'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_cycleCount + 1}/5',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            _instruction,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
