import 'package:cloud_firestore/cloud_firestore.dart';

enum MilestoneType { streak, signup, educational, community }

enum MilestoneStatus { pending, achieved, paid, failed }

class MilestoneModel {
  final String id;
  final String userId;
  final MilestoneType type;
  final int targetValue; // days for streak, points for other types
  final double bitcoinAmount; // in USD value
  final String title;
  final String description;
  final DateTime? achievedAt;
  final DateTime? paidAt;
  final MilestoneStatus status;
  final String? transactionId;
  final Map<String, dynamic> metadata;

  const MilestoneModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.targetValue,
    required this.bitcoinAmount,
    required this.title,
    required this.description,
    this.achievedAt,
    this.paidAt,
    this.status = MilestoneStatus.pending,
    this.transactionId,
    this.metadata = const {},
  });

  factory MilestoneModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MilestoneModel(
      id: doc.id,
      userId: data['userId'],
      type: MilestoneType.values.byName(data['type']),
      targetValue: data['targetValue'],
      bitcoinAmount: (data['bitcoinAmount'] as num).toDouble(),
      title: data['title'],
      description: data['description'],
      achievedAt:
          data['achievedAt'] != null
              ? (data['achievedAt'] as Timestamp).toDate()
              : null,
      paidAt:
          data['paidAt'] != null
              ? (data['paidAt'] as Timestamp).toDate()
              : null,
      status: MilestoneStatus.values.byName(data['status']),
      transactionId: data['transactionId'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'targetValue': targetValue,
      'bitcoinAmount': bitcoinAmount,
      'title': title,
      'description': description,
      'achievedAt': achievedAt != null ? Timestamp.fromDate(achievedAt!) : null,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'status': status.name,
      'transactionId': transactionId,
      'metadata': metadata,
    };
  }

  MilestoneModel copyWith({
    String? userId,
    MilestoneType? type,
    int? targetValue,
    double? bitcoinAmount,
    String? title,
    String? description,
    DateTime? achievedAt,
    DateTime? paidAt,
    MilestoneStatus? status,
    String? transactionId,
    Map<String, dynamic>? metadata,
  }) {
    return MilestoneModel(
      id: id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      bitcoinAmount: bitcoinAmount ?? this.bitcoinAmount,
      title: title ?? this.title,
      description: description ?? this.description,
      achievedAt: achievedAt ?? this.achievedAt,
      paidAt: paidAt ?? this.paidAt,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods for milestone logic
  bool get isAchieved =>
      status == MilestoneStatus.achieved || status == MilestoneStatus.paid;
  bool get isPaid => status == MilestoneStatus.paid;
  bool get isPending => status == MilestoneStatus.pending;

  // Factory methods for common milestones
  static MilestoneModel createSignupMilestone(String userId) {
    return MilestoneModel(
      id: '',
      userId: userId,
      type: MilestoneType.signup,
      targetValue: 1,
      bitcoinAmount: 1.0,
      title: 'Welcome Bonus',
      description:
          'Complete your account setup and receive your first Bitcoin reward',
    );
  }

  static MilestoneModel createStreakMilestone(
    String userId,
    int days,
    double bitcoinAmount,
  ) {
    return MilestoneModel(
      id: '',
      userId: userId,
      type: MilestoneType.streak,
      targetValue: days,
      bitcoinAmount: bitcoinAmount,
      title: '$days Day${days == 1 ? '' : 's'} Clean',
      description:
          'Maintain a $days-day streak to earn \$${bitcoinAmount.toStringAsFixed(2)} in Bitcoin',
    );
  }

  // Default milestone schedule
  static List<MilestoneModel> getDefaultMilestones(String userId) {
    return [
      createSignupMilestone(userId),
      createStreakMilestone(userId, 1, 1.0),
      createStreakMilestone(userId, 7, 5.0),
      createStreakMilestone(userId, 30, 25.0),
      createStreakMilestone(userId, 90, 100.0),
      createStreakMilestone(userId, 180, 200.0),
      createStreakMilestone(userId, 365, 500.0),
    ];
  }
}
