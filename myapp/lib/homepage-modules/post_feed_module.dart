// myapp/lib/homepage-modules/post_feed_module.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart'; // <-- needed for rootBundle
import '../data/post_store.dart';
import '../data/user_actions_store.dart';
import 'expanded_post_page.dart';

class PostFeedModule extends StatefulWidget {
  final List<Map<String, dynamic>>? posts;
  const PostFeedModule({super.key, this.posts});

  @override
  State<PostFeedModule> createState() => _PostFeedModuleState();
}

class _PostFeedModuleState extends State<PostFeedModule> {
  // canonical list (falls back to PostStore)
  List<Map<String, dynamic>> get _posts => widget.posts ?? PostStore.getAllPosts();

  void _toggleLike(int postId) {
    final currentlyLiked = UserActionsStore.isLiked(postId);
    final newState = !currentlyLiked;

    UserActionsStore.toggleLike(postId, newState);

    // get the freshly updated post
    final updated = PostStore.getAllPosts().firstWhere((p) => p['id'] == postId);
    final index = _posts.indexWhere((p) => p['id'] == postId);
    if (index != -1) _posts[index] = updated;

    setState(() {});
  }

  void _toggleBookmark(int postId) {
    final currentlyBookmarked = UserActionsStore.isBookmarked(postId);
    final newState = !currentlyBookmarked;

    UserActionsStore.toggleBookmark(postId, newState);

    final updated = PostStore.getAllPosts().firstWhere((p) => p['id'] == postId);
    final index = _posts.indexWhere((p) => p['id'] == postId);
    if (index != -1) _posts[index] = updated;

    setState(() {});
  }

  List<String> _buildDisplayTags(Map<String, dynamic> post) {
    final seen = <String>{};
    final result = <String>[];

    void addIfUnique(String? v) {
      if (v == null) return;
      final val = v.trim();
      if (val.isEmpty) return;
      final key = val.toLowerCase();
      if (!seen.contains(key)) {
        seen.add(key);
        result.add(val);
      }
    }

    addIfUnique(post['gender']);
    addIfUnique(post['style']);
    if (post['tags'] is Iterable) {
      for (final t in post['tags']) {
        addIfUnique(t?.toString());
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final posts = _posts;
    if (posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Text("No posts yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final postId = post['id'] as int;
        final images = List<dynamic>.from(post['images'] ?? []);
        final displayTags = _buildDisplayTags(post);
        final displayTagText = (displayTags.isNotEmpty) ? displayTags.take(3).join(' | ') : '';
        // read canonical counts from the post map
        final likesCount = (post['likes'] ?? 0) as int;
        final bookmarksCount = (post['bookmarks'] ?? 0) as int;
        final isLiked = UserActionsStore.isLiked(postId);
        final isBookmarked = UserActionsStore.isBookmarked(postId);

        return GestureDetector(
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
                  // pass real id parameters (do NOT capture outer postId here)
                  setLike: (id, val) {
                    // id comes from ExpandedPostPage; keep feed in sync
                    _toggleLike(id);
                  },
                  setBookmark: (id, val) {
                    _toggleBookmark(id);
                  },
                  addComment: (_) {},
                ),
              ),
            ).then((_) {
              // when returning from expanded page, refresh to pick up any changes
              if (mounted) setState(() {});
            });
          },
          child: GFCard(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            margin: const EdgeInsets.only(bottom: 16),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (images.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        image: DecorationImage(
                          image: images[0] is Uint8List
                              ? MemoryImage(images[0])
                              : NetworkImage(images[0]) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(post['description'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 4),
                if (displayTagText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(displayTagText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Like
                      InkWell(
                        onTap: () => _toggleLike(postId),
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          children: [
                            AnimatedScale(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.elasticOut,
                              scale: isLiked ? 1.2 : 1.0,
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: _SvgAssetOrIcon(
                                  assetPath: isLiked ? 'assets/likediconheart.svg' : 'assets/unlikeiconheart.svg',
                                  fallbackIcon: isLiked ? Icons.favorite : Icons.favorite_border,
                                  iconColor: isLiked ? Colors.pinkAccent : Colors.black54,
                                  width: 22,
                                  height: 22,
                                  // hearts usually don't need tinting; uncomment to enable:
                                  // colorFilter: ColorFilter.mode(isLiked ? Colors.pinkAccent : Colors.black54, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(likesCount.toString(), key: ValueKey<int>(likesCount)),
                            ),
                          ],
                        ),
                      ),

                      // Bookmark
                      InkWell(
                        onTap: () => _toggleBookmark(postId),
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          children: [
                            AnimatedScale(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.elasticOut,
                              scale: isBookmarked ? 1.2 : 1.0,
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: _SvgAssetOrIcon(
                                  assetPath: 'assets/bookmark.svg',
                                  fallbackIcon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                  iconColor: isBookmarked ? Colors.pinkAccent : Colors.black54,
                                  width: 22,
                                  height: 22,
                                  colorFilter: ColorFilter.mode(isBookmarked ? Colors.pinkAccent : Colors.black54, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(bookmarksCount.toString(), key: ValueKey<int>(bookmarksCount)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Helper widget: attempts to load an SVG asset; if unavailable or loading fails,
/// falls back to a Material Icon. Uses rootBundle.load to check asset existence.
class _SvgAssetOrIcon extends StatelessWidget {
  final String assetPath;
  final IconData fallbackIcon;
  final Color iconColor;
  final double width;
  final double height;
  final ColorFilter? colorFilter;

  const _SvgAssetOrIcon({
    required this.assetPath,
    required this.fallbackIcon,
    required this.iconColor,
    required this.width,
    required this.height,
    this.colorFilter,
  });

  Future<bool> _assetExists() async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _assetExists(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          // placeholder while we check
          return SizedBox(width: width, height: height);
        }
        final exists = snap.data ?? false;
        if (!exists) {
          // fallback icon immediately
          return Icon(fallbackIcon, size: width, color: iconColor);
        }
        // asset exists — render SVG (it may still contain inline fills that prevent tinting)
        return SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          placeholderBuilder: (c) => SizedBox(width: width, height: height),
          colorFilter: colorFilter,
          semanticsLabel: assetPath.split('/').last,
        );
      },
    );
  }
}
