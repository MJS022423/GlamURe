// lib/profile/profile_page.dart
import 'package:flutter/material.dart';

import '../data/account_store.dart';
import '../homepage-modules/create_post_components/create_post_module.dart';
import '../homepage-modules/expanded_post_page.dart';
import '../data/user_actions_store.dart';
import '../login-register-setup/login_screen.dart';
import '../utils/app_bar_builder.dart';

import 'widgets/header_panel.dart';
import 'widgets/top_designs.dart';
import 'widgets/recent_posts.dart';

class ProfilePage extends StatefulWidget {
  /// If [user] is provided, this page will show that user's profile.
  /// If null, it will show the currently signed-in user's profile (the "own" profile).
  final Map<String, dynamic>? user;

  const ProfilePage({super.key, this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool showPostModal = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Resolve which user this page should display.
  /// Priority: widget.user -> AccountStore.currentUser -> empty map
  Map<String, dynamic> get _profileOwner {
    if (widget.user != null) return widget.user!;
    try {
      final current = AccountStore.currentUser;
      if (current is Map<String, dynamic>) return current;
    } catch (_) {}
    return <String, dynamic>{};
  }

  /// Returns true if the page is showing the signed-in user's own profile.
  bool get _isOwnProfile {
    final owner = _profileOwner;
    final ownerUsername =
        (owner['username'] ?? owner['handle'] ?? owner['authorUsername'])?.toString();
    final currentUsername = AccountStore.currentUsername;
    if (ownerUsername == null || currentUsername == null) {
      // if we can't tell, assume own profile when widget.user == null
      return widget.user == null;
    }
    return ownerUsername == currentUsername;
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Logout")),
        ],
      ),
    );

    if (confirm == true) {
      try {
        UserActionsStore.clearCurrentUser();
      } catch (_) {}

      AccountStore.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (r) => false,
      );
    }
  }

  void _openCreatePost() => setState(() => showPostModal = true);
  void _closeCreatePost() => setState(() => showPostModal = false);
  void _refresh() => setState(() {});

  /// Builds an AppBar that shows a back button when viewing another user's profile.
  PreferredSizeWidget _buildAppBar(String title) {
    // If viewing a specific user (pushed via Navigator.push with user), show default AppBar with back button.
    if (widget.user != null) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
      );
    }

    // Otherwise (own profile used from bottom nav), use the custom app bar.
    return buildCustomAppBar(title);
  }

  @override
  Widget build(BuildContext context) {
    final owner = _profileOwner;
    final title = (owner['displayName'] ?? owner['name'] ?? owner['username'] ?? 'Profile').toString();
    final isOwn = _isOwnProfile;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xfffde2e4),
          appBar: _buildAppBar(title),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // HeaderPanel: show but disable create/logout when viewing another user
                  HeaderPanel(
                    fadeAnimation: _fadeAnimation,
                    onLogout: isOwn ? _confirmLogout : () {},
                    onCreatePost: isOwn ? _openCreatePost : () {},
                  ),

                  const SizedBox(height: 18),

                  // Top designs for the owner (filtered inside TopDesigns)
                  TopDesigns(
                    owner: owner,
                    onOpenPost: (post) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return ExpandedPostPage(
                          post: post,
                          likesState: const {},
                          bookmarksState: const {},
                          commentsState: const {},
                          commentControllers: const {},
                          setLike: (id, val) => _refresh(),
                          setBookmark: (id, val) => _refresh(),
                          addComment: (_) => _refresh(),
                        );
                      }));
                    },
                  ),

                  // Recent posts for the owner (filtered inside RecentPosts)
                  RecentPosts(
                    owner: owner,
                    onOpenPost: (post) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return ExpandedPostPage(
                          post: post,
                          likesState: const {},
                          bookmarksState: const {},
                          commentsState: const {},
                          commentControllers: const {},
                          setLike: (id, val) => _refresh(),
                          setBookmark: (id, val) => _refresh(),
                          addComment: (_) => _refresh(),
                        );
                      }));
                    },
                    onChanged: _refresh,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),

        // Create post modal only when viewing own profile
        if (showPostModal && isOwn)
          CreatePostModule(
            onClose: _closeCreatePost,
            addPost: (p) {
              _closeCreatePost();
              _refresh();
            },
          ),
      ],
    );
  }
}
