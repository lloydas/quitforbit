enum QuestionType { singleChoice, multipleChoice, slider, scale }

class OnboardingOption {
  final String id;
  final String text;
  final int score;
  final String? description;

  OnboardingOption({
    required this.id,
    required this.text,
    required this.score,
    this.description,
  });
}

class OnboardingQuestion {
  final String id;
  final String title;
  final String question;
  final QuestionType type;
  final List<OnboardingOption>? options;
  final double? minValue;
  final double? maxValue;
  final String? minLabel;
  final String? maxLabel;
  final String? explanation;
  final bool isRequired;

  OnboardingQuestion({
    required this.id,
    required this.title,
    required this.question,
    required this.type,
    this.options,
    this.minValue,
    this.maxValue,
    this.minLabel,
    this.maxLabel,
    this.explanation,
    this.isRequired = true,
  });

  static List<OnboardingQuestion> getQuestions() {
    return [
      OnboardingQuestion(
        id: 'motivation',
        title: 'Your Journey Starts Here',
        question: 'What motivated you to start this journey today?',
        type: QuestionType.singleChoice,
        explanation:
            'Understanding your motivation helps us personalize your experience and provide relevant support.',
        options: [
          OnboardingOption(
            id: 'relationships',
            text: 'Improve my relationships',
            score: 3,
            description: 'Building deeper, more meaningful connections',
          ),
          OnboardingOption(
            id: 'mental_health',
            text: 'Better mental health',
            score: 3,
            description: 'Reducing anxiety, depression, and shame',
          ),
          OnboardingOption(
            id: 'productivity',
            text: 'Increase productivity',
            score: 2,
            description: 'More focus and energy for important goals',
          ),
          OnboardingOption(
            id: 'spirituality',
            text: 'Spiritual/religious reasons',
            score: 3,
            description: 'Aligning with personal values and beliefs',
          ),
          OnboardingOption(
            id: 'self_control',
            text: 'Regain self-control',
            score: 3,
            description: 'Taking back power over your choices',
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'usage_frequency',
        title: 'Understanding Your Current Situation',
        question: 'How often have you been consuming pornography recently?',
        type: QuestionType.singleChoice,
        explanation:
            'This helps us understand your starting point. Remember, there\'s no judgment here - only support.',
        options: [
          OnboardingOption(
            id: 'multiple_daily',
            text: 'Multiple times per day',
            score: 5,
          ),
          OnboardingOption(id: 'daily', text: 'Once daily', score: 4),
          OnboardingOption(
            id: 'few_times_week',
            text: 'A few times per week',
            score: 3,
          ),
          OnboardingOption(id: 'weekly', text: 'About once per week', score: 2),
          OnboardingOption(
            id: 'rarely',
            text: 'Rarely, but want to quit completely',
            score: 1,
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'addiction_level',
        title: 'Self-Assessment',
        question: 'How much do you feel pornography controls your life?',
        type: QuestionType.slider,
        minValue: 0,
        maxValue: 10,
        minLabel: 'No control',
        maxLabel: 'Complete control',
        explanation:
            'Rate from 0-10 where 0 means it has no control over you, and 10 means it completely controls your daily life.',
      ),
      OnboardingQuestion(
        id: 'previous_attempts',
        title: 'Your Experience',
        question: 'Have you tried to quit pornography before?',
        type: QuestionType.singleChoice,
        explanation:
            'Previous attempts teach us valuable lessons. Every try is progress, not failure.',
        options: [
          OnboardingOption(
            id: 'never_tried',
            text: 'This is my first attempt',
            score: 1,
          ),
          OnboardingOption(
            id: 'few_attempts',
            text: 'Yes, a few times',
            score: 2,
          ),
          OnboardingOption(
            id: 'many_attempts',
            text: 'Yes, many times',
            score: 3,
          ),
          OnboardingOption(
            id: 'continuous_struggle',
            text: 'I\'ve been struggling for years',
            score: 4,
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'longest_streak',
        title: 'Your Best Achievement',
        question: 'What\'s your longest streak without pornography?',
        type: QuestionType.singleChoice,
        explanation:
            'Celebrating past successes builds confidence for future achievements.',
        options: [
          OnboardingOption(
            id: 'never_quit',
            text: 'I\'ve never quit before',
            score: 0,
          ),
          OnboardingOption(id: 'few_days', text: '1-7 days', score: 1),
          OnboardingOption(id: 'few_weeks', text: '1-4 weeks', score: 2),
          OnboardingOption(id: 'few_months', text: '1-6 months', score: 3),
          OnboardingOption(
            id: 'long_term',
            text: 'More than 6 months',
            score: 4,
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'triggers',
        title: 'Identifying Triggers',
        question:
            'What situations typically trigger your urges? (Select all that apply)',
        type: QuestionType.multipleChoice,
        explanation:
            'Recognizing triggers is the first step to managing them effectively.',
        options: [
          OnboardingOption(id: 'stress', text: 'Stress or anxiety', score: 1),
          OnboardingOption(id: 'boredom', text: 'Boredom', score: 1),
          OnboardingOption(id: 'loneliness', text: 'Loneliness', score: 1),
          OnboardingOption(id: 'social_media', text: 'Social media', score: 1),
          OnboardingOption(
            id: 'late_night',
            text: 'Late night hours',
            score: 1,
          ),
          OnboardingOption(id: 'devices', text: 'Alone with devices', score: 1),
          OnboardingOption(
            id: 'relationship_issues',
            text: 'Relationship problems',
            score: 1,
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'support_system',
        title: 'Your Support Network',
        question: 'Do you have people in your life who support your recovery?',
        type: QuestionType.singleChoice,
        explanation:
            'Having support greatly increases your chances of success. If you don\'t have support yet, this app community can help.',
        options: [
          OnboardingOption(
            id: 'strong_support',
            text: 'Yes, strong support system',
            score: 3,
          ),
          OnboardingOption(
            id: 'some_support',
            text: 'Some supportive people',
            score: 2,
          ),
          OnboardingOption(
            id: 'limited_support',
            text: 'Very limited support',
            score: 1,
          ),
          OnboardingOption(
            id: 'no_support',
            text: 'No support system',
            score: 0,
          ),
        ],
      ),
      OnboardingQuestion(
        id: 'commitment_level',
        title: 'Your Commitment',
        question: 'How committed are you to overcoming this addiction?',
        type: QuestionType.scale,
        minValue: 1,
        maxValue: 10,
        minLabel: 'Somewhat committed',
        maxLabel: 'Absolutely committed',
        explanation:
            'Your commitment level helps us understand how to best support you on this journey.',
      ),
    ];
  }
}
