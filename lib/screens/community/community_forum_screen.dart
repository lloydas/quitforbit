import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/social_models.dart';
import '../../models/user_model.dart';
import '../../models/habit_category.dart';
import '../../widgets/common/custom_button.dart';

class CommunityForumScreen extends ConsumerStatefulWidget {
  const CommunityForumScreen({super.key});

  @override
  ConsumerState<CommunityForumScreen> createState() =>
      _CommunityForumScreenState();
}

class _CommunityForumScreenState extends ConsumerState<CommunityForumScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  PostCategory selectedCategory = PostCategory.general;
  PostType? selectedPostType;

  // Mock data for demonstration
  final List<CommunityForum> forums = CommunityForum.getDefaultForums();
  final List<CommunityPost> mockPosts = _getMockPosts();
  final List<LeaderboardEntry> mockLeaderboard = _getMockLeaderboard();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text(
          'Community',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF7931A),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Forums'),
            Tab(text: 'Leaderboard'),
            Tab(text: 'Partners'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForumsTab(),
          _buildLeaderboardTab(),
          _buildPartnersTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFFF7931A),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'New Post',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildForumsTab() {
    return CustomScrollView(
      slivers: [
        // Forum categories
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recovery Communities',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildForumCategoriesGrid(),
              ],
            ),
          ),
        ),

        // Recent posts header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Posts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<PostCategory>(
                  value: selectedCategory,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  underline: Container(),
                  items: PostCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        _getCategoryDisplayName(category),
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),

        // Posts list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = mockPosts
                  .where((p) =>
                      selectedCategory == PostCategory.general ||
                      p.category == selectedCategory)
                  .toList()[index];
              return _buildPostCard(post);
            },
            childCount: mockPosts
                .where((p) =>
                    selectedCategory == PostCategory.general ||
                    p.category == selectedCategory)
                .length,
          ),
        ),
      ],
    );
  }

  Widget _buildForumCategoriesGrid() {
    final filteredForums = forums.where((f) => f.isDefault).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: filteredForums.length,
      itemBuilder: (context, index) {
        final forum = filteredForums[index];
        return _buildForumCard(forum);
      },
    );
  }

  Widget _buildForumCard(CommunityForum forum) {
    return GestureDetector(
      onTap: () => _navigateToForum(forum),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: forum.color.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: forum.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    forum.icon,
                    color: forum.color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: forum.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${forum.memberCount}',
                    style: TextStyle(
                      color: forum.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              forum.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                forum.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${forum.postCount} posts',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: post.typeInfo.color,
                child: post.authorPhotoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          post.authorPhotoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        post.authorName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.isAnonymous ? 'Anonymous User' : post.authorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: post.typeInfo.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Level ${post.authorLevel}',
                            style: TextStyle(
                              color: post.typeInfo.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          post.authorTitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${post.timeAgo}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Post type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: post.typeInfo.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      post.typeInfo.icon,
                      color: post.typeInfo.color,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.typeInfo.name,
                      style: TextStyle(
                        color: post.typeInfo.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Post content
          Text(
            post.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            post.content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          // Post metadata
          if (post.metadata.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPostMetadata(post),
          ],

          const SizedBox(height: 16),

          // Post actions
          Row(
            children: [
              _buildPostAction(
                Icons.thumb_up_outlined,
                '${post.likesCount}',
                () => _likePost(post),
              ),
              const SizedBox(width: 24),
              _buildPostAction(
                Icons.chat_bubble_outline,
                '${post.commentsCount}',
                () => _navigateToPost(post),
              ),
              const SizedBox(width: 24),
              _buildPostAction(
                Icons.share_outlined,
                'Share',
                () => _sharePost(post),
              ),
              const Spacer(),
              if (post.isPinned)
                Icon(
                  Icons.push_pin,
                  color: const Color(0xFFF7931A),
                  size: 16,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostMetadata(CommunityPost post) {
    final metadata = post.metadata;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (metadata['streak_days'] != null) ...[
            Icon(
              Icons.local_fire_department,
              color: const Color(0xFFFF5722),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${metadata['streak_days']} days clean',
              style: const TextStyle(
                color: Color(0xFFFF5722),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (metadata['habit_type'] != null) ...[
            if (metadata['streak_days'] != null) const SizedBox(width: 16),
            Icon(
              Icons.category,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              HabitCategory.getByType(
                          HabitType.values.byName(metadata['habit_type']))
                      ?.name ??
                  'Custom',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Community Leaders',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'See who\'s leading the recovery journey',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // Leaderboard type selector
          _buildLeaderboardTypeSelector(),
          const SizedBox(height: 24),

          // Top 3 podium
          _buildTopThreePodium(),
          const SizedBox(height: 24),

          // Rest of leaderboard
          _buildLeaderboardList(),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildLeaderboardTypeButton('Streak', true),
          ),
          Expanded(
            child: _buildLeaderboardTypeButton('XP', false),
          ),
          Expanded(
            child: _buildLeaderboardTypeButton('Badges', false),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTypeButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF7931A) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTopThreePodium() {
    final topThree = mockLeaderboard.take(3).toList();

    return Container(
      height: 200,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Second place (left)
          if (topThree.length > 1)
            Positioned(
              left: 0,
              bottom: 20,
              child: _buildPodiumPosition(topThree[1], 2, 120),
            ),

          // First place (center)
          if (topThree.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: _buildPodiumPosition(topThree[0], 1, 160),
            ),

          // Third place (right)
          if (topThree.length > 2)
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildPodiumPosition(topThree[2], 3, 100),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(
      LeaderboardEntry entry, int position, double height) {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];

    return Column(
      children: [
        // User avatar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors[position - 1],
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: position == 1 ? 30 : 25,
            backgroundColor: const Color(0xFF1E293B),
            child: entry.userPhotoUrl != null
                ? ClipOval(
                    child: Image.network(
                      entry.userPhotoUrl!,
                      width: position == 1 ? 60 : 50,
                      height: position == 1 ? 60 : 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    entry.userName[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: position == 1 ? 24 : 20,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),

        // User name
        Text(
          entry.userName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Score
        Text(
          entry.formattedScore,
          style: TextStyle(
            color: colors[position - 1],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),

        // Podium
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: colors[position - 1].withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            border: Border.all(
              color: colors[position - 1],
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              entry.rankDisplay,
              style: TextStyle(
                color: colors[position - 1],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList() {
    final remainingEntries = mockLeaderboard.skip(3).toList();

    return Column(
      children: remainingEntries
          .map((entry) => _buildLeaderboardEntry(entry))
          .toList(),
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF7931A).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: const TextStyle(
                  color: Color(0xFFF7931A),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF334155),
            child: entry.userPhotoUrl != null
                ? ClipOval(
                    child: Image.network(
                      entry.userPhotoUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    entry.userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  entry.userTitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Text(
            entry.formattedScore,
            style: const TextStyle(
              color: Color(0xFFF7931A),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accountability Partners',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect with others on similar recovery journeys',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // Find partner button
          CustomButton(
            text: 'Find an Accountability Partner',
            onPressed: _showPartnerMatchingDialog,
            isLoading: false,
          ),
          const SizedBox(height: 24),

          // Current partners section
          const Text(
            'Your Partners',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // No partners placeholder
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.people_outline,
                  color: Colors.white.withOpacity(0.5),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No accountability partners yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect with someone who shares your recovery goals for mutual support and motivation.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getCategoryDisplayName(PostCategory category) {
    switch (category) {
      case PostCategory.general:
        return 'All Posts';
      case PostCategory.smoking:
        return 'Quit Smoking';
      case PostCategory.alcohol:
        return 'Alcohol Recovery';
      case PostCategory.drugs:
        return 'Drug Recovery';
      case PostCategory.socialMedia:
        return 'Digital Detox';
      case PostCategory.gambling:
        return 'Gambling Recovery';
      case PostCategory.custom:
        return 'Custom Habits';
      case PostCategory.newbies:
        return 'Newcomers';
      case PostCategory.veterans:
        return 'Veterans';
    }
  }

  // Action methods
  void _showSearchDialog() {
    // Implement search functionality
  }

  void _showFilterDialog() {
    // Implement filter options
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0E27),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Post',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Post type selection
            const Text(
              'Post Type',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PostType.values.map((type) {
                final typeInfo = CommunityPost(
                  id: '',
                  authorId: '',
                  authorName: '',
                  authorLevel: 1,
                  authorTitle: '',
                  title: '',
                  content: '',
                  type: type,
                  category: PostCategory.general,
                  createdAt: DateTime.now(),
                ).typeInfo;

                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        typeInfo.icon,
                        size: 16,
                        color: selectedPostType == type
                            ? Colors.white
                            : typeInfo.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        typeInfo.name,
                        style: TextStyle(
                          color: selectedPostType == type
                              ? Colors.white
                              : typeInfo.color,
                        ),
                      ),
                    ],
                  ),
                  selected: selectedPostType == type,
                  onSelected: (selected) {
                    setState(() {
                      selectedPostType = selected ? type : null;
                    });
                  },
                  backgroundColor: const Color(0xFF1E293B),
                  selectedColor: typeInfo.color,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Continue',
              onPressed: selectedPostType != null
                  ? () => _navigateToCreatePost()
                  : null,
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }

  void _showPartnerMatchingDialog() {
    // Implement partner matching functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Find Accountability Partner',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'We\'ll match you with someone who has similar recovery goals and is in a compatible time zone. This feature is coming soon!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToForum(CommunityForum forum) {
    // Navigate to specific forum
  }

  void _navigateToPost(CommunityPost post) {
    // Navigate to post detail view
  }

  void _navigateToCreatePost() {
    Navigator.pop(context);
    // Navigate to create post screen
  }

  void _likePost(CommunityPost post) {
    // Implement like functionality
  }

  void _sharePost(CommunityPost post) {
    // Implement share functionality
  }

  // Mock data generators
  static List<CommunityPost> _getMockPosts() {
    return [
      CommunityPost(
        id: '1',
        authorId: 'user1',
        authorName: 'Sarah Recovery',
        authorLevel: 3,
        authorTitle: 'Motivated',
        title: 'Just hit 30 days smoke-free! 🎉',
        content:
            'I can\'t believe I made it this far! The first week was the hardest, but with support from this community and the Bitcoin rewards keeping me motivated, I\'ve officially hit 30 days without a cigarette.',
        type: PostType.milestone,
        category: PostCategory.smoking,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 24,
        commentsCount: 8,
        viewsCount: 156,
        metadata: {
          'streak_days': 30,
          'habit_type': 'smoking',
        },
      ),
      CommunityPost(
        id: '2',
        authorId: 'user2',
        authorName: 'Mike Strong',
        authorLevel: 5,
        authorTitle: 'Warrior',
        title: 'Tips for dealing with triggers?',
        content:
            'I\'m 14 days sober and doing well, but I\'m going to a wedding this weekend where there will be a lot of drinking. Any tips for staying strong? I\'ve already planned my escape route and will have a sober friend with me.',
        type: PostType.support,
        category: PostCategory.alcohol,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        likesCount: 12,
        commentsCount: 15,
        viewsCount: 89,
        metadata: {
          'streak_days': 14,
          'habit_type': 'alcohol',
        },
      ),
      CommunityPost(
        id: '3',
        authorId: 'user3',
        authorName: 'Alex Digital',
        authorLevel: 2,
        authorTitle: 'Beginner',
        title: 'One week without social media!',
        content:
            'This might seem small compared to other addictions, but for me, breaking my social media habit has been huge. I\'ve read 2 books this week and actually had real conversations with friends.',
        type: PostType.celebration,
        category: PostCategory.socialMedia,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        likesCount: 18,
        commentsCount: 6,
        viewsCount: 67,
        metadata: {
          'streak_days': 7,
          'habit_type': 'socialMedia',
        },
      ),
    ];
  }

  static List<LeaderboardEntry> _getMockLeaderboard() {
    return [
      LeaderboardEntry(
        userId: 'user1',
        userName: 'RecoveryChampion',
        userLevel: 8,
        userTitle: 'Legend',
        rank: 1,
        score: 365,
        scoreLabel: 'days',
        habitType: HabitType.smoking,
      ),
      LeaderboardEntry(
        userId: 'user2',
        userName: 'SoberSarah',
        userLevel: 7,
        userTitle: 'Hero',
        rank: 2,
        score: 287,
        scoreLabel: 'days',
        habitType: HabitType.alcohol,
      ),
      LeaderboardEntry(
        userId: 'user3',
        userName: 'CleanAndFree',
        userLevel: 6,
        userTitle: 'Champion',
        rank: 3,
        score: 203,
        scoreLabel: 'days',
        habitType: HabitType.drugs,
      ),
      LeaderboardEntry(
        userId: 'user4',
        userName: 'DigitalDetoxer',
        userLevel: 4,
        userTitle: 'Determined',
        rank: 4,
        score: 156,
        scoreLabel: 'days',
        habitType: HabitType.socialMedia,
      ),
      LeaderboardEntry(
        userId: 'user5',
        userName: 'GambleFree',
        userLevel: 5,
        userTitle: 'Warrior',
        rank: 5,
        score: 134,
        scoreLabel: 'days',
        habitType: HabitType.gambling,
      ),
    ];
  }
}
