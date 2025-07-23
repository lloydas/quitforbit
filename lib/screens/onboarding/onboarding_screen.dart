import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/onboarding_question.dart';
import '../../widgets/common/custom_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  late List<OnboardingQuestion> _questions;
  Map<String, dynamic> _answers = {};
  int _currentIndex = 0;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _questions = OnboardingQuestion.getQuestions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.shortAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: AppConstants.shortAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _isCompleting = true;
    });

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.updateProfile(onboardingData: _answers);

      // Navigation will happen automatically via the AppNavigator
      // when the user's onboardingData is no longer empty
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing onboarding: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  void _updateAnswer(String questionId, dynamic answer) {
    setState(() {
      _answers[questionId] = answer;
    });
  }

  bool _canProceed() {
    final currentQuestion = _questions[_currentIndex];
    return _answers.containsKey(currentQuestion.id) &&
        _answers[currentQuestion.id] != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            _currentIndex > 0
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _previousQuestion,
                )
                : null,
        actions: [
          TextButton(
            onPressed: _completeOnboarding,
            child: Text(
              'Skip',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentIndex + 1} of ${_questions.length}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${((_currentIndex + 1) / _questions.length * 100).round()}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingS),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _questions.length,
                  effect: WormEffect(
                    dotHeight: 4,
                    dotWidth: 40,
                    spacing: 8,
                    activeDotColor: AppColors.primary,
                    dotColor: AppColors.textTertiary.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),

          // Questions
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return _buildQuestionPage(question);
              },
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: CustomButton(
              text:
                  _currentIndex == _questions.length - 1
                      ? 'Complete Setup'
                      : 'Continue',
              onPressed: _canProceed() || _isCompleting ? _nextQuestion : null,
              isLoading: _isCompleting,
              backgroundColor:
                  _canProceed() ? AppColors.primary : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(OnboardingQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.title,
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppConstants.paddingM),

          Text(question.question, style: AppTextStyles.h4),
          const SizedBox(height: AppConstants.paddingS),

          if (question.explanation != null) ...[
            Text(
              question.explanation!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
          ],

          // Question UI based on type
          _buildQuestionInput(question),
        ],
      ),
    );
  }

  Widget _buildQuestionInput(OnboardingQuestion question) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoiceInput(question);
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceInput(question);
      case QuestionType.slider:
        return _buildSliderInput(question);
      case QuestionType.scale:
        return _buildScaleInput(question);
    }
  }

  Widget _buildSingleChoiceInput(OnboardingQuestion question) {
    final selectedValue = _answers[question.id];

    return Column(
      children:
          question.options!.map((option) {
            final isSelected = selectedValue == option.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
              child: InkWell(
                onTap: () => _updateAnswer(question.id, option.id),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surface,
                    border: Border.all(
                      color:
                          isSelected
                              ? AppColors.primary
                              : AppColors.textTertiary.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.textTertiary,
                          ),
                          const SizedBox(width: AppConstants.paddingS),
                          Expanded(
                            child: Text(
                              option.text,
                              style: AppTextStyles.subtitle1.copyWith(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (option.description != null) ...[
                        const SizedBox(height: AppConstants.paddingXS),
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Text(
                            option.description!,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildMultipleChoiceInput(OnboardingQuestion question) {
    final selectedValues = (_answers[question.id] as List<String>?) ?? [];

    return Column(
      children:
          question.options!.map((option) {
            final isSelected = selectedValues.contains(option.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
              child: InkWell(
                onTap: () {
                  List<String> newSelection = List.from(selectedValues);
                  if (isSelected) {
                    newSelection.remove(option.id);
                  } else {
                    newSelection.add(option.id);
                  }
                  _updateAnswer(question.id, newSelection);
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surface,
                    border: Border.all(
                      color:
                          isSelected
                              ? AppColors.primary
                              : AppColors.textTertiary.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppConstants.paddingS),
                      Expanded(
                        child: Text(
                          option.text,
                          style: AppTextStyles.subtitle1.copyWith(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSliderInput(OnboardingQuestion question) {
    final value = (_answers[question.id] as double?) ?? question.minValue ?? 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          child: Column(
            children: [
              Text(
                value.round().toString(),
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 48,
                ),
              ),
              Text(
                'out of ${question.maxValue?.round()}',
                style: AppTextStyles.subtitle2.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingL),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.textTertiary.withOpacity(0.3),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value,
            min: question.minValue ?? 0,
            max: question.maxValue ?? 10,
            divisions:
                ((question.maxValue ?? 10) - (question.minValue ?? 0)).round(),
            onChanged: (newValue) => _updateAnswer(question.id, newValue),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(question.minLabel ?? '', style: AppTextStyles.caption),
            Text(question.maxLabel ?? '', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }

  Widget _buildScaleInput(OnboardingQuestion question) {
    final value = (_answers[question.id] as double?) ?? question.minValue ?? 1;
    final min = question.minValue ?? 1;
    final max = question.maxValue ?? 10;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          child: Column(
            children: [
              Text(
                value.round().toString(),
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 48,
                ),
              ),
              Text(
                'out of ${max.round()}',
                style: AppTextStyles.subtitle2.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingL),

        // Scale buttons
        Wrap(
          spacing: AppConstants.paddingS,
          runSpacing: AppConstants.paddingS,
          children: List.generate((max - min + 1).round(), (index) {
            final scaleValue = min + index;
            final isSelected = value.round() == scaleValue.round();

            return InkWell(
              onTap: () => _updateAnswer(question.id, scaleValue),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.textTertiary,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Center(
                  child: Text(
                    scaleValue.round().toString(),
                    style: AppTextStyles.subtitle1.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: AppConstants.paddingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(question.minLabel ?? '', style: AppTextStyles.caption),
            Text(question.maxLabel ?? '', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }
}
