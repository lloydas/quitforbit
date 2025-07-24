import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/habit_category.dart';
import '../../widgets/common/custom_button.dart';

class HabitCustomizationScreen extends ConsumerStatefulWidget {
  final HabitCategory category;

  const HabitCustomizationScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<HabitCustomizationScreen> createState() =>
      _HabitCustomizationScreenState();
}

class _HabitCustomizationScreenState
    extends ConsumerState<HabitCustomizationScreen>
    with TickerProviderStateMixin {
  // Custom habit fields (for custom category)
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _customDescriptionController =
      TextEditingController();

  // Selected triggers and alternatives
  Set<String> selectedTriggers = {};
  Set<String> selectedAlternatives = {};

  // Goal settings
  int goalStreak = 365; // Default to 1 year

  // Animation
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Page control
  int currentStep = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _customDescriptionController.dispose();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentStep = index;
                    });
                  },
                  children: [
                    _buildCustomNameStep(),
                    _buildTriggersStep(),
                    _buildAlternativesStep(),
                    _buildGoalsStep(),
                  ],
                ),
              ),

              // Navigation
              _buildNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Progress and back button
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: 0.6 + (currentStep * 0.1), // Steps 2-4 of onboarding
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      widget.category.primaryColor),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 24),

          // Category header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.category.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.category.icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Customize your recovery journey',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomNameStep() {
    if (widget.category.type != HabitType.custom) {
      // Skip this step for predefined categories
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _nextStep();
      });
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Name Your Habit',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Give your custom habit a name and description',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),

          // Habit name input
          TextFormField(
            controller: _customNameController,
            decoration: InputDecoration(
              labelText: 'Habit Name',
              hintText: 'e.g., "Quit Vaping", "Stop Nail Biting"',
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            style: const TextStyle(color: Colors.white),
            maxLength: 50,
          ),
          const SizedBox(height: 24),

          // Habit description input
          TextFormField(
            controller: _customDescriptionController,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Why do you want to break this habit?',
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            maxLength: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildTriggersStep() {
    final triggers = widget.category.type == HabitType.custom
        ? [
            'Stress',
            'Boredom',
            'Social situations',
            'Emotions',
            'Specific times',
            'Certain places'
          ]
        : widget.category.commonTriggers;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Identify Your Triggers',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select situations that make you want to engage in this habit',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: triggers
                  .map((trigger) => _buildSelectableItem(
                        text: trigger,
                        isSelected: selectedTriggers.contains(trigger),
                        onTap: () {
                          setState(() {
                            if (selectedTriggers.contains(trigger)) {
                              selectedTriggers.remove(trigger);
                            } else {
                              selectedTriggers.add(trigger);
                            }
                          });
                        },
                        color: widget.category.primaryColor,
                      ))
                  .toList(),
            ),
          ),
          if (selectedTriggers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '${selectedTriggers.length} trigger${selectedTriggers.length == 1 ? '' : 's'} selected',
              style: TextStyle(
                fontSize: 14,
                color: widget.category.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlternativesStep() {
    final alternatives = widget.category.type == HabitType.custom
        ? [
            'Exercise',
            'Deep breathing',
            'Call a friend',
            'Go for a walk',
            'Drink water',
            'Listen to music'
          ]
        : widget.category.replacementActivities;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Alternatives',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select healthy activities to do instead when triggered',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: alternatives
                  .map((alternative) => _buildSelectableItem(
                        text: alternative,
                        isSelected: selectedAlternatives.contains(alternative),
                        onTap: () {
                          setState(() {
                            if (selectedAlternatives.contains(alternative)) {
                              selectedAlternatives.remove(alternative);
                            } else {
                              selectedAlternatives.add(alternative);
                            }
                          });
                        },
                        color: widget.category.accentColor,
                      ))
                  .toList(),
            ),
          ),
          if (selectedAlternatives.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '${selectedAlternatives.length} alternative${selectedAlternatives.length == 1 ? '' : 's'} selected',
              style: TextStyle(
                fontSize: 14,
                color: widget.category.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalsStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set Your Goal',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'How long do you want to stay clean?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),

          // Goal options
          ...[30, 90, 180, 365, 730].map((days) => _buildGoalOption(days)),

          const SizedBox(height: 32),

          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.category.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.category.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Recovery Plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.category.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Summary items
                _buildSummaryItem('Habit', _getHabitName()),
                _buildSummaryItem('Goal', '$goalStreak days clean'),
                _buildSummaryItem(
                    'Triggers', '${selectedTriggers.length} identified'),
                _buildSummaryItem(
                    'Alternatives', '${selectedAlternatives.length} selected'),
                _buildSummaryItem('Potential Reward',
                    '\$${_calculatePotentialReward().toStringAsFixed(0)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableItem({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isSelected ? color.withOpacity(0.1) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? color : Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.8),
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalOption(int days) {
    final isSelected = goalStreak == days;
    final label = _getGoalLabel(days);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            goalStreak = days;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.category.primaryColor.withOpacity(0.1)
                : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? widget.category.primaryColor
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? widget.category.primaryColor
                    : Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      '$days days',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7931A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Up to \$${_calculateRewardForGoal(days).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: CustomButton(
                text: 'Back',
                onPressed: _previousStep,
                isLoading: false,
                isOutlined: true,
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: currentStep == 0 ? 1 : 2,
            child: CustomButton(
              text: _getNextButtonText(),
              onPressed: _canProceed()
                  ? (currentStep < 3 ? _nextStep : _finishCustomization)
                  : null,
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceed() {
    switch (currentStep) {
      case 0: // Custom name step
        return widget.category.type != HabitType.custom ||
            _customNameController.text.isNotEmpty;
      case 1: // Triggers step
        return selectedTriggers.isNotEmpty;
      case 2: // Alternatives step
        return selectedAlternatives.isNotEmpty;
      case 3: // Goals step
        return true;
      default:
        return false;
    }
  }

  String _getNextButtonText() {
    switch (currentStep) {
      case 0:
        return 'Continue to Triggers';
      case 1:
        return 'Continue to Alternatives';
      case 2:
        return 'Set Your Goal';
      case 3:
        return 'Start Your Journey';
      default:
        return 'Continue';
    }
  }

  String _getHabitName() {
    if (widget.category.type == HabitType.custom) {
      return _customNameController.text.isNotEmpty
          ? _customNameController.text
          : 'Custom Habit';
    }
    return widget.category.name;
  }

  String _getGoalLabel(int days) {
    switch (days) {
      case 30:
        return 'One Month';
      case 90:
        return 'Three Months';
      case 180:
        return 'Six Months';
      case 365:
        return 'One Year';
      case 730:
        return 'Two Years';
      default:
        return '$days Days';
    }
  }

  double _calculateRewardForGoal(int goalDays) {
    double total = 0.0;
    for (var entry in widget.category.milestoneRewards.entries) {
      if (entry.key <= goalDays) {
        total += entry.value;
      }
    }
    return total;
  }

  double _calculatePotentialReward() {
    return _calculateRewardForGoal(goalStreak);
  }

  void _finishCustomization() {
    // Navigate to final onboarding step or dashboard
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/bitcoin-setup',
      (route) => false,
      arguments: {
        'category': widget.category,
        'customName': _customNameController.text,
        'customDescription': _customDescriptionController.text,
        'selectedTriggers': selectedTriggers.toList(),
        'selectedAlternatives': selectedAlternatives.toList(),
        'goalStreak': goalStreak,
      },
    );
  }
}
