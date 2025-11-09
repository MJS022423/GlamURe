// myapp/lib/bookmark.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'data/post_store.dart';
import 'data/user_actions_store.dart';
import 'data/account_store.dart';
import 'homepage-modules/expanded_post_page.dart';

/// BookmarkPage - shows posts bookmarked by the currently signed-in user.
/// Relies on:
///  - AccountStore.currentUsername to identify the user
///  - UserActionsStore.isBookmarked(postId) and toggleBookmark(postId, state)
///  - PostStore.getAllPosts() / updatePost for counts
class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  // Get bookmark-only posts for the current user.
  List<Map<String, dynamic>> get _bookmarkedPosts {
    final username = AccountStore.currentUsername;
    if (username == null) return [];
    final all = PostStore.getAllPosts();
    return all
        .where((p) => UserActionsStore.isBookmarked(p['id'] as int, username: username))
        .toList();
  }

  void _openExpanded(Map<String, dynamic> post) {
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
          addComment: (_) => setState(() {}),
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _toggleLike(int postId) {
    final newState = !UserActionsStore.isLiked(postId);
    UserActionsStore.toggleLike(postId, newState);
    setState(() {});
  }

  void _toggleBookmark(int postId) {
    final newState = !UserActionsStore.isBookmarked(postId);
    UserActionsStore.toggleBookmark(postId, newState);
    setState(() {});
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No bookmarks yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 6),
            Text(
              'Tap the bookmark icon on posts to save them here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final postId = post['id'] as int;
    final images = List<dynamic>.from(post['images'] ?? []);
    final img = images.isNotEmpty ? images[0] : null;
    final desc = (post['description'] ?? '').toString();
    final tags =
        (post['tags'] is Iterable) ? List<String>.from(post['tags']) : <String>[];
    final likes = (post['likes'] ?? 0) as int;
    final bookmarks = (post['bookmarks'] ?? 0) as int;
    final isBookmarked = UserActionsStore.isBookmarked(postId);
    final isLiked = UserActionsStore.isLiked(postId);

    return GestureDetector(
      onTap: () => _openExpanded(post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (img != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: img is Uint8List
                    ? Image.memory(img, width: double.infinity, fit: BoxFit.cover)
                    : Image.network(img,
                        width: double.infinity, fit: BoxFit.cover),
              ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (desc.isNotEmpty)
                    Text(desc,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: tags
                        .map((t) => Chip(
                              label: Text(t,
                                  style: const TextStyle(fontSize: 11)),
                              backgroundColor: Colors.pink.shade50,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Like + Bookmark Row
                      Row(children: [
                        InkWell(
                          onTap: () => _toggleLike(postId),
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              AnimatedScale(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.elasticOut,
                                scale: isLiked ? 1.2 : 1.0,
                                child: SvgPicture.asset(
                                  isLiked
                                      ? 'assets/likediconheart.svg'
                                      : 'assets/unlikeiconheart.svg',
                                  width: 22,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('$likes'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        InkWell(
                          onTap: () => _toggleBookmark(postId),
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              AnimatedScale(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.elasticOut,
                                scale: isBookmarked ? 1.2 : 1.0,
                                child: SvgPicture.asset(
                                  'assets/bookmark.svg',
                                  width: 22,
                                  colorFilter: ColorFilter.mode(
                                      isBookmarked
                                          ? Colors.pinkAccent
                                          : Colors.black54,
                                      BlendMode.srcIn),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('$bookmarks'),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = _bookmarkedPosts;

    return Scaffold(
      backgroundColor: const Color(0xfffde2e4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Bookmarks',
            style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: posts.isEmpty
            ? _buildEmpty()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (context, i) => _buildPostCard(posts[i]),
              ),
      ),
    );
  }
}
