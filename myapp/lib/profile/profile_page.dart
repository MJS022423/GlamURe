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
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  bool showPostModal = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
      // Clear the current user's transient actions (matches your UserActionsStore API)
      // NOTE: your user_actions_store.dart defines clearCurrentUser(), not clearCurrentUserActions()
      try {
        UserActionsStore.clearCurrentUser();
      } catch (e) {
        // Defensive: if API name changes again, don't crash logout flow.
        debugPrint('Warning while clearing user actions: $e');
      }

      AccountStore.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
    }
  }

  void _openCreatePost() => setState(() => showPostModal = true);
  void _closeCreatePost() => setState(() => showPostModal = false);

  // force rebuild (child widgets read canonical stores)
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xfffde2e4),
          appBar: buildCustomAppBar('Profile'),
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  HeaderPanel(
                    fadeAnimation: _fadeAnimation,
                    onLogout: _confirmLogout,
                    onCreatePost: _openCreatePost,
                  ),
                  const SizedBox(height: 18),
                  TopDesigns(
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
                  RecentPosts(
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

        if (showPostModal)
          CreatePostModule(
            onClose: _closeCreatePost,
            addPost: (p) {
              // new post is already added in PostStore by CreatePostModule
              _closeCreatePost();
              _refresh();
            },
          ),
      ],
    );
  }
}
