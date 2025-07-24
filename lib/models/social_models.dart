import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'habit_category.dart';

/// Enum for different types of community posts
enum PostType {
  milestone, // Celebrating a milestone
  support, // Asking for support
  motivation, // Sharing motivation
  question, // Asking a question
  story, // Sharing personal story
  tip, // Sharing helpful tips
  relapse, // Dealing with relapse
  celebration, // General celebration
}

/// Enum for post categories based on habit types
enum PostCategory {
  general, // General recovery discussion
  smoking, // Smoking cessation specific
  alcohol, // Alcohol recovery specific
  drugs, // Drug recovery specific
  socialMedia, // Social media detox specific
  gambling, // Gambling addiction specific
  custom, // Custom habits
  newbies, // New user help
  veterans, // Long-term recovery
}

/// Model for community posts
class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final int authorLevel;
  final String authorTitle;
  final HabitType? authorHabitType;
  final String title;
  final String content;
  final PostType type;
  final PostCategory category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool isPinned;
  final bool isAnonymous;
  final Map<String, dynamic> metadata; // Flexible data (streak info, etc.)

  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.authorLevel,
    required this.authorTitle,
    this.authorHabitType,
    required this.title,
    required this.content,
    required this.type,
    required this.category,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.isPinned = false,
    this.isAnonymous = false,
    this.metadata = const {},
  });

  /// Create from Firestore
  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityPost(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      authorPhotoUrl: data['authorPhotoUrl'],
      authorLevel: data['authorLevel'] ?? 1,
      authorTitle: data['authorTitle'] ?? 'Newcomer',
      authorHabitType: data['authorHabitType'] != null
          ? HabitType.values.byName(data['authorHabitType'])
          : null,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      type: PostType.values.byName(data['type'] ?? 'support'),
      category: PostCategory.values.byName(data['category'] ?? 'general'),
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
      isPinned: data['isPinned'] ?? false,
      isAnonymous: data['isAnonymous'] ?? false,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'authorLevel': authorLevel,
      'authorTitle': authorTitle,
      'authorHabitType': authorHabitType?.name,
      'title': title,
      'content': content,
      'type': type.name,
      'category': category.name,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'viewsCount': viewsCount,
      'isPinned': isPinned,
      'isAnonymous': isAnonymous,
      'metadata': metadata,
    };
  }

  /// Get post type display info
  PostTypeInfo get typeInfo {
    switch (type) {
      case PostType.milestone:
        return PostTypeInfo(
          'Milestone',
          Icons.flag,
          const Color(0xFFFFD700),
        );
      case PostType.support:
        return PostTypeInfo(
          'Support',
          Icons.help_outline,
          const Color(0xFF2196F3),
        );
      case PostType.motivation:
        return PostTypeInfo(
          'Motivation',
          Icons.psychology,
          const Color(0xFF9C27B0),
        );
      case PostType.question:
        return PostTypeInfo(
          'Question',
          Icons.quiz,
          const Color(0xFF4CAF50),
        );
      case PostType.story:
        return PostTypeInfo(
          'Story',
          Icons.auto_stories,
          const Color(0xFF673AB7),
        );
      case PostType.tip:
        return PostTypeInfo(
          'Tip',
          Icons.lightbulb,
          const Color(0xFFFF9800),
        );
      case PostType.relapse:
        return PostTypeInfo(
          'Relapse',
          Icons.refresh,
          const Color(0xFF607D8B),
        );
      case PostType.celebration:
        return PostTypeInfo(
          'Celebration',
          Icons.celebration,
          const Color(0xFFE91E63),
        );
    }
  }

  /// Get category display info
  PostCategoryInfo get categoryInfo {
    switch (category) {
      case PostCategory.general:
        return PostCategoryInfo('General', const Color(0xFF607D8B));
      case PostCategory.smoking:
        return PostCategoryInfo('Quit Smoking', const Color(0xFF2E7D32));
      case PostCategory.alcohol:
        return PostCategoryInfo('Quit Drinking', const Color(0xFF1565C0));
      case PostCategory.drugs:
        return PostCategoryInfo('Drug Recovery', const Color(0xFF7B1FA2));
      case PostCategory.socialMedia:
        return PostCategoryInfo('Social Media Detox', const Color(0xFFE65100));
      case PostCategory.gambling:
        return PostCategoryInfo('Quit Gambling', const Color(0xFFD32F2F));
      case PostCategory.custom:
        return PostCategoryInfo('Custom Habits', const Color(0xFF5E35B1));
      case PostCategory.newbies:
        return PostCategoryInfo('Newcomers', const Color(0xFF4CAF50));
      case PostCategory.veterans:
        return PostCategoryInfo('Veterans', const Color(0xFF795548));
    }
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Helper class for post type information
class PostTypeInfo {
  final String name;
  final IconData icon;
  final Color color;

  const PostTypeInfo(this.name, this.icon, this.color);
}

/// Helper class for post category information
class PostCategoryInfo {
  final String name;
  final Color color;

  const PostCategoryInfo(this.name, this.color);
}

/// Model for post comments
class PostComment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final int authorLevel;
  final String authorTitle;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final String? parentCommentId; // For nested replies
  final bool isAnonymous;

  const PostComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.authorLevel,
    required this.authorTitle,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.parentCommentId,
    this.isAnonymous = false,
  });

  /// Create from Firestore
  factory PostComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostComment(
      id: doc.id,
      postId: data['postId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      authorPhotoUrl: data['authorPhotoUrl'],
      authorLevel: data['authorLevel'] ?? 1,
      authorTitle: data['authorTitle'] ?? 'Newcomer',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      likesCount: data['likesCount'] ?? 0,
      parentCommentId: data['parentCommentId'],
      isAnonymous: data['isAnonymous'] ?? false,
    );
  }

  /// Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'authorLevel': authorLevel,
      'authorTitle': authorTitle,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likesCount': likesCount,
      'parentCommentId': parentCommentId,
      'isAnonymous': isAnonymous,
    };
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Enum for leaderboard types
enum LeaderboardType {
  globalStreak, // Global longest streaks
  habitStreak, // Streaks by habit category
  weeklyXP, // Weekly XP earned
  monthlyXP, // Monthly XP earned
  allTimeXP, // All-time XP
  achievements, // Total achievements count
  helpfulness, // Community help score
  consistency, // Check-in consistency
}

/// Enum for leaderboard timeframes
enum LeaderboardTimeframe {
  weekly,
  monthly,
  allTime,
}

/// Model for leaderboard entries
class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int userLevel;
  final String userTitle;
  final HabitType? habitType;
  final int rank;
  final double score; // The metric being ranked (streak days, XP, etc.)
  final String scoreLabel; // "days", "XP", "achievements", etc.
  final Map<String, dynamic> metadata; // Additional info

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.userLevel,
    required this.userTitle,
    this.habitType,
    required this.rank,
    required this.score,
    required this.scoreLabel,
    this.metadata = const {},
  });

  /// Create from Firestore
  factory LeaderboardEntry.fromFirestore(Map<String, dynamic> data) {
    return LeaderboardEntry(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userPhotoUrl: data['userPhotoUrl'],
      userLevel: data['userLevel'] ?? 1,
      userTitle: data['userTitle'] ?? 'Newcomer',
      habitType: data['habitType'] != null
          ? HabitType.values.byName(data['habitType'])
          : null,
      rank: data['rank'] ?? 0,
      score: (data['score'] ?? 0).toDouble(),
      scoreLabel: data['scoreLabel'] ?? '',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'userLevel': userLevel,
      'userTitle': userTitle,
      'habitType': habitType?.name,
      'rank': rank,
      'score': score,
      'scoreLabel': scoreLabel,
      'metadata': metadata,
    };
  }

  /// Get formatted score display
  String get formattedScore {
    if (scoreLabel == 'days') {
      return '${score.toInt()} days';
    } else if (scoreLabel == 'XP') {
      return '${score.toInt()} XP';
    } else if (scoreLabel == 'achievements') {
      return '${score.toInt()} badges';
    } else {
      return '${score.toInt()} $scoreLabel';
    }
  }

  /// Get rank display with suffix
  String get rankDisplay {
    if (rank == 1) return '🥇 1st';
    if (rank == 2) return '🥈 2nd';
    if (rank == 3) return '🥉 3rd';
    return '#$rank';
  }
}

/// Model for accountability partnerships
class AccountabilityPartnership {
  final String id;
  final String user1Id;
  final String user2Id;
  final String user1Name;
  final String user2Name;
  final String? user1PhotoUrl;
  final String? user2PhotoUrl;
  final HabitType? sharedHabitType;
  final DateTime createdAt;
  final DateTime? lastInteraction;
  final bool isActive;
  final int checkinStreak; // Days both users checked in
  final Map<String, dynamic> preferences; // Communication prefs, etc.

  const AccountabilityPartnership({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.user1Name,
    required this.user2Name,
    this.user1PhotoUrl,
    this.user2PhotoUrl,
    this.sharedHabitType,
    required this.createdAt,
    this.lastInteraction,
    this.isActive = true,
    this.checkinStreak = 0,
    this.preferences = const {},
  });

  /// Create from Firestore
  factory AccountabilityPartnership.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AccountabilityPartnership(
      id: doc.id,
      user1Id: data['user1Id'] ?? '',
      user2Id: data['user2Id'] ?? '',
      user1Name: data['user1Name'] ?? '',
      user2Name: data['user2Name'] ?? '',
      user1PhotoUrl: data['user1PhotoUrl'],
      user2PhotoUrl: data['user2PhotoUrl'],
      sharedHabitType: data['sharedHabitType'] != null
          ? HabitType.values.byName(data['sharedHabitType'])
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastInteraction: data['lastInteraction'] != null
          ? (data['lastInteraction'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      checkinStreak: data['checkinStreak'] ?? 0,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
    );
  }

  /// Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'user1Name': user1Name,
      'user2Name': user2Name,
      'user1PhotoUrl': user1PhotoUrl,
      'user2PhotoUrl': user2PhotoUrl,
      'sharedHabitType': sharedHabitType?.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastInteraction':
          lastInteraction != null ? Timestamp.fromDate(lastInteraction!) : null,
      'isActive': isActive,
      'checkinStreak': checkinStreak,
      'preferences': preferences,
    };
  }

  /// Get partner info for a specific user
  PartnerInfo getPartnerInfo(String currentUserId) {
    if (currentUserId == user1Id) {
      return PartnerInfo(user2Id, user2Name, user2PhotoUrl);
    } else {
      return PartnerInfo(user1Id, user1Name, user1PhotoUrl);
    }
  }

  /// Get days since last interaction
  int get daysSinceLastInteraction {
    if (lastInteraction == null) return 0;
    return DateTime.now().difference(lastInteraction!).inDays;
  }
}

/// Helper class for partner information
class PartnerInfo {
  final String id;
  final String name;
  final String? photoUrl;

  const PartnerInfo(this.id, this.name, this.photoUrl);
}

/// Model for user interactions (likes, helps, etc.)
class UserInteraction {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String targetId; // Post ID, Comment ID, etc.
  final InteractionType type;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const UserInteraction({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.targetId,
    required this.type,
    required this.createdAt,
    this.metadata = const {},
  });

  /// Create from Firestore
  factory UserInteraction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserInteraction(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      targetId: data['targetId'] ?? '',
      type: InteractionType.values.byName(data['type'] ?? 'like'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'targetId': targetId,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }
}

/// Enum for user interaction types
enum InteractionType {
  like, // Liked a post/comment
  help, // Helped someone
  follow, // Followed a user
  checkin, // Checked in with accountability partner
  encourage, // Sent encouragement
  share, // Shared achievement
}

/// Model for community forums/groups
class CommunityForum {
  final String id;
  final String name;
  final String description;
  final PostCategory category;
  final IconData icon;
  final Color color;
  final int memberCount;
  final int postCount;
  final bool isDefault; // Default forums that everyone joins
  final List<String> moderatorIds;
  final Map<String, dynamic> rules;

  const CommunityForum({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    this.memberCount = 0,
    this.postCount = 0,
    this.isDefault = false,
    this.moderatorIds = const [],
    this.rules = const {},
  });

  /// Get default community forums
  static List<CommunityForum> getDefaultForums() {
    return [
      CommunityForum(
        id: 'general',
        name: 'General Support',
        description: 'Welcome newcomers and general recovery discussions',
        category: PostCategory.general,
        icon: Icons.forum,
        color: const Color(0xFF607D8B),
        isDefault: true,
      ),
      CommunityForum(
        id: 'smoking',
        name: 'Quit Smoking',
        description: 'Support for breaking free from nicotine addiction',
        category: PostCategory.smoking,
        icon: Icons.smoke_free,
        color: const Color(0xFF2E7D32),
        isDefault: true,
      ),
      CommunityForum(
        id: 'alcohol',
        name: 'Alcohol Recovery',
        description: 'Sobriety support and alcohol-free living',
        category: PostCategory.alcohol,
        icon: Icons.local_bar_outlined,
        color: const Color(0xFF1565C0),
        isDefault: true,
      ),
      CommunityForum(
        id: 'drugs',
        name: 'Drug Recovery',
        description: 'Clean living and substance abuse recovery',
        category: PostCategory.drugs,
        icon: Icons.healing,
        color: const Color(0xFF7B1FA2),
        isDefault: true,
      ),
      CommunityForum(
        id: 'social_media',
        name: 'Digital Detox',
        description: 'Breaking social media and screen addiction',
        category: PostCategory.socialMedia,
        icon: Icons.phone_android_outlined,
        color: const Color(0xFFE65100),
        isDefault: true,
      ),
      CommunityForum(
        id: 'gambling',
        name: 'Gambling Recovery',
        description: 'Financial recovery and gambling addiction support',
        category: PostCategory.gambling,
        icon: Icons.casino_outlined,
        color: const Color(0xFFD32F2F),
        isDefault: true,
      ),
      CommunityForum(
        id: 'newbies',
        name: 'Newcomer Help',
        description: 'First-time users and getting started guidance',
        category: PostCategory.newbies,
        icon: Icons.help_center,
        color: const Color(0xFF4CAF50),
        isDefault: true,
      ),
      CommunityForum(
        id: 'veterans',
        name: 'Long-term Recovery',
        description: 'For those with 90+ days and sharing wisdom',
        category: PostCategory.veterans,
        icon: Icons.star,
        color: const Color(0xFF795548),
        isDefault: false,
      ),
    ];
  }
}
