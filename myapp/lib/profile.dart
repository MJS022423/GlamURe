// myapp/lib/profile.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'data/post_store.dart';
import 'data/user_actions_store.dart';
import 'data/account_store.dart';
import 'homepage-modules/create_post_module.dart';
import 'homepage-modules/expanded_post_page.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool showPostModal = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Called by CreatePostModule to refresh UI after adding posts
  void addPost(Map<String, dynamic> newPost) {
    setState(() {}); // refresh UI (PostStore is global)
  }

  /// Logout confirmation and flow
  void _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      AccountStore.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  /// Helper to build avatar widget from base64 or fallback
  Widget _buildAvatar(double size) {
    final current = AccountStore.currentUser;
    final profileBase64 = current?['profileImage'] as String?;
    if (profileBase64 != null && profileBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(profileBase64);
        return ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover),
        );
      } catch (e) {
        // decode failed — fall back to icon
      }
    }

    // fallback circle with icon
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFACED9),
      ),
      child: const Icon(Icons.person, size: 40, color: Colors.black),
    );
  }

  /// Top header: avatar + display name + email + logout menu
  Widget _buildHeader() {
    final current = AccountStore.currentUser;
    final displayName = (current != null && (current['displayName'] ?? '').toString().isNotEmpty)
        ? current['displayName']
        : (current != null ? current['username'] : 'Designer');
    final email = current != null ? (current['email'] ?? '') : '';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            _buildAvatar(90),

            const SizedBox(width: 16),

            // Name / Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName ?? 'Designer',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email.isNotEmpty ? email : 'No email provided',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            // Logout popup/menu
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') _confirmLogout();
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text("Logout"),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  /// Simple user info section (not a card) — shows additional public info if available
  Widget _buildUserInfoRows() {
    final current = AccountStore.currentUser;
    if (current == null) {
      return const SizedBox.shrink();
    }

    final gender = current['gender'] ?? 'N/A';
    final role = current['role'] ?? 'N/A';
    final contact = current['contact'] ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.info_outline, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
            Text("Role: $role", style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.male, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
            Text("Gender: $gender"),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.phone, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
            Text("Contact: $contact"),
          ]),
        ],
      ),
    );
  }

  Widget _buildTop3Designs() {
    final currentUsername = AccountStore.currentUsername ?? AccountStore.currentUser?['username'];
    final userPosts = currentUsername != null ? PostStore.getPostsByUser(currentUsername) : <Map<String, dynamic>>[];
    if (userPosts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text("No designs yet",
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    final top3 = [...userPosts];
    top3.sort((a, b) => ((b['likes'] ?? 0) as int).compareTo(((a['likes'] ?? 0) as int)));
    final take = top3.take(3).toList();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text("Top 3 Designs",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink)),
                SizedBox(width: 6),
                Text("🔥", style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: take.length,
              itemBuilder: (_, i) {
                final p = take[i];
                final img = p['images'][0];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExpandedPostPage(
                          post: p,
                          likesState: const {},
                          bookmarksState: const {},
                          commentsState: const {},
                          commentControllers: const {},
                          setLike: (id, val) => setState(() {}),
                          setBookmark: (id, val) => setState(() {}),
                          addComment: (_) {},
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'post-${p['id']}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: img is Uint8List
                          ? Image.memory(img, fit: BoxFit.cover)
                          : Image.network(img, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPosts() {
    final currentUsername = AccountStore.currentUsername ?? AccountStore.currentUser?['username'];
    final posts = currentUsername != null ? PostStore.getPostsByUser(currentUsername) : <Map<String, dynamic>>[];

    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
            child: Text("No recent posts yet",
                style: TextStyle(fontSize: 16, color: Colors.grey))),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recent Posts",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (_, i) {
                final post = posts[i];
                final postId = post['id'] as int;
                final img = post['images'][0];
                final desc = post['description'] ?? '';
                final likes = (post['likes'] ?? 0) as int;
                final bookmarks = (post['bookmarks'] ?? 0) as int;
                final isLiked = UserActionsStore.isLiked(postId);
                final isBookmarked = UserActionsStore.isBookmarked(postId);
                final tags = List<String>.from(post['tags'] ?? []);

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: 1.0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExpandedPostPage(
                            post: post,
                            likesState: const {},
                            bookmarksState: const {},
                            commentsState: const {},
                            commentControllers: const {},
                            setLike: (id, val) => setState(() {}),
                            setBookmark: (id, val) => setState(() {}),
                            addComment: (_) {},
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            child: img is Uint8List
                                ? Image.memory(img, width: double.infinity, fit: BoxFit.cover)
                                : Image.network(img, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (desc.isNotEmpty)
                                  Text(desc,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: tags
                                      .map((t) => Chip(
                                            label: Text(t, style: const TextStyle(fontSize: 11)),
                                            backgroundColor: Colors.pink.shade50,
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        final newState = !UserActionsStore.isLiked(postId);
                                        UserActionsStore.toggleLike(postId, newState);
                                        setState(() {
                                          post['likes'] = (post['likes'] ?? 0) + (newState ? 1 : -1);
                                          if (post['likes'] < 0) post['likes'] = 0;
                                          PostStore.updatePost(postId, {'likes': post['likes']});
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/heart.svg',
                                            width: 22,
                                            colorFilter: ColorFilter.mode(
                                              isLiked ? Colors.red : Colors.black54,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text('$likes'),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        final newState = !UserActionsStore.isBookmarked(postId);
                                        UserActionsStore.toggleBookmark(postId, newState);
                                        setState(() {
                                          post['bookmarks'] = (post['bookmarks'] ?? 0) + (newState ? 1 : -1);
                                          if (post['bookmarks'] < 0) post['bookmarks'] = 0;
                                          PostStore.updatePost(postId, {'bookmarks': post['bookmarks']});
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/bookmark.svg',
                                            width: 22,
                                            colorFilter: ColorFilter.mode(
                                              isBookmarked ? Colors.pinkAccent : Colors.black54,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text('$bookmarks'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xfffde2e4),
          appBar: GFAppBar(
            backgroundColor: const Color.fromARGB(255, 224, 224, 224),
            title: const Text("PROFILE",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(),
                  const SizedBox(height: 6),
                  _buildUserInfoRows(),
                  const SizedBox(height: 8),
                  _buildTop3Designs(),
                  _buildRecentPosts(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        if (showPostModal)
          CreatePostModule(
            onClose: () => setState(() => showPostModal = false),
            addPost: addPost,
          ),
      ],
    );
  }
}
