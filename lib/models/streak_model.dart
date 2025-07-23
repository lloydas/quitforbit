import 'package:cloud_firestore/cloud_firestore.dart';

class StreakModel {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final int daysCount;
  final String? endReason;
  final Map<String, dynamic> metadata;

  StreakModel({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.daysCount,
    this.endReason,
    this.metadata = const {},
  });

  factory StreakModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StreakModel(
      id: doc.id,
      userId: data['userId'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate:
          data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
      isActive: data['isActive'] ?? true,
      daysCount: data['daysCount'] ?? 0,
      endReason: data['endReason'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isActive': isActive,
      'daysCount': daysCount,
      'endReason': endReason,
      'metadata': metadata,
    };
  }

  StreakModel copyWith({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? daysCount,
    String? endReason,
    Map<String, dynamic>? metadata,
  }) {
    return StreakModel(
      id: id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      daysCount: daysCount ?? this.daysCount,
      endReason: endReason ?? this.endReason,
      metadata: metadata ?? this.metadata,
    );
  }

  Duration get duration {
    final endTime = endDate ?? DateTime.now();
    return endTime.difference(startDate);
  }

  int get currentDays {
    if (!isActive) return daysCount;
    return DateTime.now().difference(startDate).inDays;
  }

  bool get hasReachedMilestone {
    final days = currentDays;
    return days >= 30 || days >= 90 || days >= 180 || days >= 365;
  }

  List<int> get availableMilestones {
    final days = currentDays;
    List<int> milestones = [];
    if (days >= 30) milestones.add(30);
    if (days >= 90) milestones.add(90);
    if (days >= 180) milestones.add(180);
    if (days >= 365) milestones.add(365);
    return milestones;
  }
}
