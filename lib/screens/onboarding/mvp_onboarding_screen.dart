import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/streak_provider.dart';
import '../../widgets/common/custom_button.dart';

class MVPOnboardingScreen extends ConsumerStatefulWidget {
  const MVPOnboardingScreen({super.key});

  @override
  ConsumerState<MVPOnboardingScreen> createState() =>
      _MVPOnboardingScreenState();
}

class _MVPOnboardingScreenState extends ConsumerState<MVPOnboardingScreen> {
  bool _isSettingUp = false;
  int _currentStep = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Welcome to QuitForBit!',
      description:
          'The first app that pays you in Bitcoin to overcome addiction.',
      icon: Icons.waving_hand,
      color: Colors.blue,
    ),
    OnboardingStep(
      title: 'How It Works',
      description:
          'Check in daily to maintain your streak. Reach milestones to earn real Bitcoin rewards.',
      icon: Icons.monetization_on,
      color: Colors.orange,
    ),
    OnboardingStep(
      title: 'Your Bitcoin Wallet',
      description:
          'We\'ll set up a secure testnet Bitcoin wallet for you to receive rewards.',
      icon: Icons.account_balance_wallet,
      color: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / _steps.length,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 48),

              // Step content
              Expanded(child: _buildStepContent()),

              // Navigation buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    final step = _steps[_currentStep];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: step.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(step.icon, size: 60, color: step.color),
        ),
        const SizedBox(height: 32),

        // Title
        Text(
          step.title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          step.description,
          style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
          textAlign: TextAlign.center,
        ),

        // Additional content for Bitcoin step
        if (_currentStep == 2) ...[
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We use testnet Bitcoin for safety during development. No real money is involved.',
                    style: TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        // Primary button
        CustomButton(
          text:
              _isSettingUp
                  ? 'Setting up...'
                  : _currentStep == _steps.length - 1
                  ? 'Complete Setup'
                  : 'Next',
          onPressed: _isSettingUp ? null : _handleNext,
          isLoading: _isSettingUp,
        ),

        // Secondary button
        if (_currentStep > 0) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isSettingUp ? null : _handleBack,
            child: const Text('Back'),
          ),
        ],
      ],
    );
  }

  void _handleNext() async {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Complete onboarding
      await _completeOnboarding();
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    print('🚀 DEBUG: Starting complete onboarding...');

    setState(() {
      _isSettingUp = true;
    });

    try {
      print('🔍 DEBUG: Getting current user...');
      final currentUser = ref.read(currentUserProvider).value;

      if (currentUser == null) {
        print('❌ DEBUG: Current user is null!');
        throw Exception('User not found');
      }

      print('✅ DEBUG: Current user found: ${currentUser.email}');

      // Set up Bitcoin wallet directly (bypass StreakNotifier state issue)
      print('🔑 DEBUG: Setting up Bitcoin wallet...');
      final bitcoinService = ref.read(bitcoinServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      // Generate Bitcoin testnet address
      print('🔗 DEBUG: Generating testnet address...');
      final address = bitcoinService.generateTestnetAddress();
      print('🔗 DEBUG: Generated address: $address');

      // Update user with Bitcoin address
      print('💾 DEBUG: Updating user with Bitcoin address...');
      await firestoreService.updateUserData(currentUser.id, {
        'bitcoinWalletAddress': address,
      });
      print('💾 DEBUG: User data updated in Firestore');

      // Process signup bonus
      print('🎁 DEBUG: Processing signup bonus...');
      await bitcoinService.processSignupBonus(
        userId: currentUser.id,
        bitcoinAddress: address,
      );
      print('🎁 DEBUG: Signup bonus processed successfully');

      print('🔑 DEBUG: Bitcoin wallet setup result: true');
      final success = true;

      if (success) {
        print('💾 DEBUG: Updating user onboarding data...');

        await ref.read(firestoreServiceProvider).updateUserData(
          currentUser.id,
          {
            'onboardingData': {
              'completed': true,
              'completedAt': DateTime.now(),
              'version': '1.0',
            },
          },
        );

        print('✅ DEBUG: Onboarding data updated successfully!');

        if (mounted) {
          print('🎉 DEBUG: Showing success message...');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '🎉 Welcome! You\'ve earned your first \$1 Bitcoin!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('❌ DEBUG: Bitcoin wallet setup failed');
        throw Exception('Failed to set up Bitcoin wallet');
      }
    } catch (e) {
      print('❌ DEBUG: Complete onboarding error: $e');
      print('❌ DEBUG: Error type: ${e.runtimeType}');
      print('❌ DEBUG: Stack trace: ${StackTrace.current}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Setup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      print('🏁 DEBUG: Complete onboarding finished');
      if (mounted) {
        setState(() {
          _isSettingUp = false;
        });
      }
    }
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
