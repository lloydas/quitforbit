import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final DateTime? lastCheckIn;
  final bool isPremiumUser;
  final String? bitcoinWalletAddress;
  final int currentStreak;
  final int longestStreak;
  final double totalEarned; // Total USD value earned in Bitcoin
  final double totalBitcoinEarned; // Total BTC amount earned
  final Map<String, dynamic> onboardingData;
  final List<String> paidMilestones;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.lastCheckIn,
    this.isPremiumUser = false,
    this.bitcoinWalletAddress,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalEarned = 0.0,
    this.totalBitcoinEarned = 0.0,
    this.onboardingData = const {},
    this.paidMilestones = const [],
    this.preferences = const {},
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      lastCheckIn:
          data['lastCheckIn'] != null
              ? (data['lastCheckIn'] as Timestamp).toDate()
              : null,
      isPremiumUser: data['isPremiumUser'] ?? false,
      bitcoinWalletAddress: data['bitcoinWalletAddress'],
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      totalEarned: (data['totalEarned'] ?? 0.0).toDouble(),
      totalBitcoinEarned: (data['totalBitcoinEarned'] ?? 0.0).toDouble(),
      onboardingData: Map<String, dynamic>.from(data['onboardingData'] ?? {}),
      paidMilestones: List<String>.from(data['paidMilestones'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'lastCheckIn':
          lastCheckIn != null ? Timestamp.fromDate(lastCheckIn!) : null,
      'isPremiumUser': isPremiumUser,
      'bitcoinWalletAddress': bitcoinWalletAddress,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalEarned': totalEarned,
      'totalBitcoinEarned': totalBitcoinEarned,
      'onboardingData': onboardingData,
      'paidMilestones': paidMilestones,
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? lastLoginAt,
    DateTime? lastCheckIn,
    bool? isPremiumUser,
    String? bitcoinWalletAddress,
    int? currentStreak,
    int? longestStreak,
    double? totalEarned,
    double? totalBitcoinEarned,
    Map<String, dynamic>? onboardingData,
    List<String>? paidMilestones,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      bitcoinWalletAddress: bitcoinWalletAddress ?? this.bitcoinWalletAddress,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalEarned: totalEarned ?? this.totalEarned,
      totalBitcoinEarned: totalBitcoinEarned ?? this.totalBitcoinEarned,
      onboardingData: onboardingData ?? this.onboardingData,
      paidMilestones: paidMilestones ?? this.paidMilestones,
      preferences: preferences ?? this.preferences,
    );
  }

  // Helper methods for MVP
  bool get hasBitcoinWallet =>
      bitcoinWalletAddress != null && bitcoinWalletAddress!.isNotEmpty;
  bool get hasCheckedInToday {
    if (lastCheckIn == null) return false;
    final today = DateTime.now();
    final lastCheckInDate = lastCheckIn!;
    return today.year == lastCheckInDate.year &&
        today.month == lastCheckInDate.month &&
        today.day == lastCheckInDate.day;
  }

  bool get canCheckIn => !hasCheckedInToday;

  String get streakDisplayText {
    if (currentStreak == 0) return 'Start your journey';
    if (currentStreak == 1) return '1 day clean';
    return '$currentStreak days clean';
  }

  String get totalEarnedDisplayText {
    return '\$${totalEarned.toStringAsFixed(2)}';
  }

  // Get next milestone target
  int get nextMilestoneTarget {
    if (currentStreak < 1) return 1;
    if (currentStreak < 7) return 7;
    if (currentStreak < 30) return 30;
    if (currentStreak < 90) return 90;
    if (currentStreak < 180) return 180;
    if (currentStreak < 365) return 365;
    return 730; // 2 years
  }

  int get daysToNextMilestone {
    return nextMilestoneTarget - currentStreak;
  }
}
