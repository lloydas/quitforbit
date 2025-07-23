import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { milestone, signup, referral, bonus, send, receive }

enum TransactionStatus { pending, processing, completed, failed, cancelled }

class BitcoinTransactionModel {
  final String id;
  final String userId;
  final String? milestoneId;
  final TransactionType type;
  final double amount; // USD value
  final double bitcoinAmount; // BTC amount
  final String? bitcoinAddress;
  final String? transactionHash;
  final TransactionStatus status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic> metadata;

  const BitcoinTransactionModel({
    required this.id,
    required this.userId,
    this.milestoneId,
    required this.type,
    required this.amount,
    required this.bitcoinAmount,
    this.bitcoinAddress,
    this.transactionHash,
    this.status = TransactionStatus.pending,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
    this.metadata = const {},
  });

  factory BitcoinTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BitcoinTransactionModel(
      id: doc.id,
      userId: data['userId'],
      milestoneId: data['milestoneId'],
      type: TransactionType.values.byName(data['type']),
      amount: (data['amount'] as num).toDouble(),
      bitcoinAmount: (data['bitcoinAmount'] as num).toDouble(),
      bitcoinAddress: data['bitcoinAddress'],
      transactionHash: data['transactionHash'],
      status: TransactionStatus.values.byName(data['status']),
      errorMessage: data['errorMessage'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt:
          data['completedAt'] != null
              ? (data['completedAt'] as Timestamp).toDate()
              : null,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'milestoneId': milestoneId,
      'type': type.name,
      'amount': amount,
      'bitcoinAmount': bitcoinAmount,
      'bitcoinAddress': bitcoinAddress,
      'transactionHash': transactionHash,
      'status': status.name,
      'errorMessage': errorMessage,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'metadata': metadata,
    };
  }

  BitcoinTransactionModel copyWith({
    String? userId,
    String? milestoneId,
    TransactionType? type,
    double? amount,
    double? bitcoinAmount,
    String? bitcoinAddress,
    String? transactionHash,
    TransactionStatus? status,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return BitcoinTransactionModel(
      id: id,
      userId: userId ?? this.userId,
      milestoneId: milestoneId ?? this.milestoneId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      bitcoinAmount: bitcoinAmount ?? this.bitcoinAmount,
      bitcoinAddress: bitcoinAddress ?? this.bitcoinAddress,
      transactionHash: transactionHash ?? this.transactionHash,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isPending =>
      status == TransactionStatus.pending ||
      status == TransactionStatus.processing;
  bool get hasFailed =>
      status == TransactionStatus.failed ||
      status == TransactionStatus.cancelled;

  String get statusDisplayText {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get typeDisplayText {
    switch (type) {
      case TransactionType.milestone:
        return 'Milestone Reward';
      case TransactionType.signup:
        return 'Welcome Bonus';
      case TransactionType.referral:
        return 'Referral Bonus';
      case TransactionType.bonus:
        return 'Special Bonus';
      case TransactionType.send:
        return 'Sent Bitcoin';
      case TransactionType.receive:
        return 'Received Bitcoin';
    }
  }

  // Factory methods for common transactions
  static BitcoinTransactionModel createMilestoneTransaction({
    required String userId,
    required String milestoneId,
    required double amount,
    required double bitcoinAmount,
    String? bitcoinAddress,
  }) {
    return BitcoinTransactionModel(
      id: '',
      userId: userId,
      milestoneId: milestoneId,
      type: TransactionType.milestone,
      amount: amount,
      bitcoinAmount: bitcoinAmount,
      bitcoinAddress: bitcoinAddress,
      createdAt: DateTime.now(),
    );
  }

  static BitcoinTransactionModel createSignupTransaction({
    required String userId,
    required double amount,
    required double bitcoinAmount,
    String? bitcoinAddress,
  }) {
    return BitcoinTransactionModel(
      id: '',
      userId: userId,
      type: TransactionType.signup,
      amount: amount,
      bitcoinAmount: bitcoinAmount,
      bitcoinAddress: bitcoinAddress,
      createdAt: DateTime.now(),
    );
  }

  static BitcoinTransactionModel createSendTransaction({
    required String userId,
    required double amount,
    required double bitcoinAmount,
    required String recipientAddress,
    double? networkFee,
  }) {
    return BitcoinTransactionModel(
      id: '',
      userId: userId,
      type: TransactionType.send,
      amount: amount,
      bitcoinAmount: bitcoinAmount,
      bitcoinAddress: recipientAddress,
      createdAt: DateTime.now(),
      metadata: {
        'networkFee': networkFee ?? 0.0,
        'recipientAddress': recipientAddress,
      },
    );
  }
}
