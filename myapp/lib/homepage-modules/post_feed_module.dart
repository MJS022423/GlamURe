// myapp/lib/homepage-modules/post_feed_module.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  List<Map<String, dynamic>> get _posts =>
      widget.posts ?? PostStore.getAllPosts();

  // Network SVG URLs (user-provided)
  static const _heartUnlikedUrl = 'https://www.svgrepo.com/show/532473/heart.svg';
  static const _heartLikedUrl = 'https://www.svgrepo.com/show/369346/heart.svg';

  void _toggleLike(int postId) {
    final isLiked = UserActionsStore.isLiked(postId);
    final newState = !isLiked;

    // flip store state first
    UserActionsStore.toggleLike(postId, newState);

    setState(() {
      final idx = _posts.indexWhere((p) => p['id'] == postId);
      if (idx >= 0) {
        var likes = (_posts[idx]['likes'] ?? 0) as int;
        if (newState) {
          likes += 1;
        } else {
          likes = (likes - 1).clamp(0, likes);
        }
        _posts[idx]['likes'] = likes;
        PostStore.updatePost(postId, {'likes': likes});
      }
    });
  }

  void _toggleBookmark(int postId) {
    final isBookmarked = UserActionsStore.isBookmarked(postId);
    final newState = !isBookmarked;

    UserActionsStore.toggleBookmark(postId, newState);

    setState(() {
      final idx = _posts.indexWhere((p) => p['id'] == postId);
      if (idx >= 0) {
        var bookmarks = (_posts[idx]['bookmarks'] ?? 0) as int;
        if (newState) {
          bookmarks += 1;
        } else {
          bookmarks = (bookmarks - 1).clamp(0, bookmarks);
        }
        _posts[idx]['bookmarks'] = bookmarks;
        PostStore.updatePost(postId, {'bookmarks': bookmarks});
      }
    });
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
      for (final t in post['tags']) addIfUnique(t?.toString());
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
          child: Text("No posts yet",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
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
        final displayTagText =
            (displayTags.isNotEmpty) ? displayTags.take(3).join(' | ') : '';
        final likesCount = (post['likes'] ?? 0) as int;
        final bookmarksCount = (post['bookmarks'] ?? 0) as int;
        final isLiked = UserActionsStore.isLiked(postId);
        final isBookmarked = UserActionsStore.isBookmarked(postId);

        final heartUrl = isLiked ? _heartLikedUrl : _heartUnlikedUrl;

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
                  setLike: (id, val) => _toggleLike(postId),
                  setBookmark: (id, val) => _toggleBookmark(postId),
                  addComment: (_) {},
                ),
              ),
            );
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
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
                  child: Text(post['description'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 4),
                if (displayTagText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      displayTagText,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 8),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                                child: SvgPicture.asset(
                                  isLiked
                                      ? 'assets/likediconheart.svg'
                                      : 'assets/unlikeiconheart.svg',
                                  width: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                likesCount.toString(),
                                key: ValueKey<int>(likesCount),
                              ),
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
                              child: SvgPicture.asset(
                                'assets/bookmark.svg',
                                width: 22,
                                colorFilter: ColorFilter.mode(
                                  isBookmarked ? Colors.pinkAccent : Colors.black54,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                bookmarksCount.toString(),
                                key: ValueKey<int>(bookmarksCount),
                              ),
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
