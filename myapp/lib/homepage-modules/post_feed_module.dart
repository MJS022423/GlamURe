// myapp/lib/homepage-modules/post_feed_module.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

import 'expanded_post_page.dart';

class PostFeedModule extends StatefulWidget {
  final List<Map<String, dynamic>> posts;
  const PostFeedModule({super.key, required this.posts});

  @override
  State<PostFeedModule> createState() => _PostFeedModuleState();
}

class _PostFeedModuleState extends State<PostFeedModule> {
  // Per-post user toggle state (whether the current user has liked/bookmarked).
  Map<String, bool> likesState = {};
  Map<String, bool> bookmarksState = {};
  Map<String, List<Map<String, String>>> commentsState = {};
  Map<String, TextEditingController> commentControllers = {};
  Map<String, int> currentImageIndex = {};

  // Set like to a particular boolean state (optimistic update + persist to post base count).
  void setLike(String postId, bool newState) {
    setState(() {
      final idx = widget.posts.indexWhere((p) => p['id'].toString() == postId);
      // Ensure maps exist
      likesState[postId] = newState;
      if (idx >= 0) {
        widget.posts[idx]['likes'] = (widget.posts[idx]['likes'] ?? 0) as int;
        // update base count to reflect newState (increase/decrease)
        final currentBase = widget.posts[idx]['likes'] as int;
        // Determine previous effective state by comparing likesState before update.
        // To avoid double applying, compute delta from previous likesState (if any)
        // We'll compute previousState by flipping newState if we stored previous value before assignment.
        // Simpler: when toggling we assume caller knows previous; here caller sets newState explicitly so adjust by +1/-1
        // But caller uses setLike with newState indicating desired; we need to compute if we should change base.
        // We'll check previousSaved = likesState[postId] before assignment, but we already assigned.
        // To get previous saved, compute prev = !(newState) if this post previously existed in map - but edge cases exist.
        // Better approach: use a temporary variable for prev:
      }
    });

    // To correctly adjust base count relative to previous value, we do the base update outside the setState above using previous value.
    // (We rebuild with setState again with correct counts)
    _applyLikeBaseAdjustment(postId, newState);
  }

  void _applyLikeBaseAdjustment(String postId, bool newState) {
    // compute previous state: if we had an entry, previousState = old value before change
    // We'll fetch old value by looking at a stored history map or by inferring from current post['likes'] and likesState.
    // Simpler and safe: when setLike is called from UI, we will be calling it with newState that is the desired value.
    // We'll adjust post['likes'] by +1 when newState is true AND the previous effective state (in likesState) was false or null.
    // If previous was true and newState false, decrement by 1.
    final prev = _previousLikeValueCache[postId] ?? false;
    if (prev == newState) {
      // nothing to change
      return;
    }
    // apply
    setState(() {
      final idx = widget.posts.indexWhere((p) => p['id'].toString() == postId);
      if (idx >= 0) {
        widget.posts[idx]['likes'] = (widget.posts[idx]['likes'] ?? 0) as int;
        if (newState) {
          widget.posts[idx]['likes'] = (widget.posts[idx]['likes'] as int) + 1;
        } else {
          widget.posts[idx]['likes'] = (widget.posts[idx]['likes'] as int) - 1;
          if (widget.posts[idx]['likes'] < 0) widget.posts[idx]['likes'] = 0;
        }
      }
      likesState[postId] = newState;
      // update cache
      _previousLikeValueCache[postId] = newState;
    });
  }

  // Similarly for bookmarks
  void setBookmark(String postId, bool newState) {
    _applyBookmarkSet(postId, newState);
  }

  // Internal caches to remember previous toggle states so we can update base counts correctly.
  final Map<String, bool> _previousLikeValueCache = {};
  final Map<String, bool> _previousBookmarkValueCache = {};

  void _applyBookmarkSet(String postId, bool newState) {
    final prev = _previousBookmarkValueCache[postId] ?? false;
    if (prev == newState) {
      // ensure state stored
      setState(() => bookmarksState[postId] = newState);
      return;
    }

    setState(() {
      final idx = widget.posts.indexWhere((p) => p['id'].toString() == postId);
      if (idx >= 0) {
        widget.posts[idx]['bookmarks'] = (widget.posts[idx]['bookmarks'] ?? 0) as int;
        if (newState) {
          widget.posts[idx]['bookmarks'] = (widget.posts[idx]['bookmarks'] as int) + 1;
        } else {
          widget.posts[idx]['bookmarks'] = (widget.posts[idx]['bookmarks'] as int) - 1;
          if (widget.posts[idx]['bookmarks'] < 0) widget.posts[idx]['bookmarks'] = 0;
        }
      }
      bookmarksState[postId] = newState;
      _previousBookmarkValueCache[postId] = newState;
    });
  }

  /// Adds comment to the top (newest first) and clears controller.
  void addComment(String postId) {
    final controller = commentControllers[postId];
    if (controller == null || controller.text.trim().isEmpty) return;

    setState(() {
      commentsState[postId] = [
        {'username': 'Jzar Alaba', 'text': controller.text.trim()},
        ...?commentsState[postId],
      ];
      controller.clear();
    });
  }

  Widget buildFeedDescription(String desc) {
    const int FEED_DESC_LIMIT = 30;
    if (desc.length <= FEED_DESC_LIMIT) return Text(desc);
    return Text(desc.substring(0, FEED_DESC_LIMIT) + '...');
  }

  /// Build a deduplicated, ordered list of display tags for a post.
  /// Order: gender, style, then post['tags'] (preserves order and removes duplicates).
  List<String> _buildDisplayTags(Map<String, dynamic> post) {
    final seen = <String>{};
    final List<String> result = [];

    void addIfUnique(String? value) {
      if (value == null) return;
      final v = value.toString().trim();
      if (v.isEmpty) return;
      final key = v.toLowerCase();
      if (!seen.contains(key)) {
        seen.add(key);
        result.add(v);
      }
    }

    addIfUnique(post['gender']?.toString());
    addIfUnique(post['style']?.toString());

    final rawTags = post['tags'];
    if (rawTags is Iterable) {
      for (final t in rawTags) {
        addIfUnique(t?.toString());
      }
    } else if (rawTags is String && rawTags.isNotEmpty) {
      for (final t in rawTags.split(',').map((s) => s.trim())) {
        addIfUnique(t);
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
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
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        final post = widget.posts[index];
        final postId = post['id'].toString();
        final images = List<dynamic>.from(post['images'] ?? []);

        // Initialize states if missing
        likesState[postId] = likesState[postId] ?? false;
        bookmarksState[postId] = bookmarksState[postId] ?? false;
        commentsState[postId] = commentsState[postId] ?? [];
        commentControllers[postId] ??= TextEditingController();
        currentImageIndex[postId] = currentImageIndex[postId] ?? 0;

        // ensure caches initialised
        _previousLikeValueCache[postId] = _previousLikeValueCache[postId] ?? likesState[postId]!;
        _previousBookmarkValueCache[postId] = _previousBookmarkValueCache[postId] ?? bookmarksState[postId]!;

        final displayTags = _buildDisplayTags(post);
        final displayTagText = (displayTags.isNotEmpty)
            ? displayTags.take(3).join(' | ')
            : '';

        // Compute counters directly from post base (we maintain base counts when toggling)
        final likesCount = (post['likes'] ?? 0) as int;
        final bookmarksCount = (post['bookmarks'] ?? 0) as int;

        return GFCard(
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          margin: const EdgeInsets.only(bottom: 16),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (images.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExpandedPostPage(
                          post: post,
                          likesState: likesState,
                          bookmarksState: bookmarksState,
                          commentsState: commentsState,
                          commentControllers: commentControllers,
                          setLike: (id, value) => setLike(id, value),
                          setBookmark: (id, value) => setBookmark(id, value),
                          addComment: (id) => addComment(id),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
                child: buildFeedDescription(post['description'] ?? ''),
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Like area (animated)
                    InkWell(
                      onTap: () {
                        final newState = !(likesState[postId] ?? false);
                        // optimistic local update: store prev for correct base adjust
                        _previousLikeValueCache[postId] = likesState[postId] ?? false;
                        // update local map immediately for UI responsiveness
                        setState(() => likesState[postId] = newState);
                        // ask parent to persist and update base counts
                        setLike(postId, newState);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          AnimatedScale(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.elasticOut,
                            scale: (likesState[postId] ?? false) ? 1.15 : 1.0,
                            child: Icon(
                              (likesState[postId] ?? false) ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
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

                    // Bookmark area (animated + counter)
                    InkWell(
                      onTap: () {
                        final newState = !(bookmarksState[postId] ?? false);
                        _previousBookmarkValueCache[postId] = bookmarksState[postId] ?? false;
                        setState(() => bookmarksState[postId] = newState);
                        setBookmark(postId, newState);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          AnimatedScale(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.elasticOut,
                            scale: (bookmarksState[postId] ?? false) ? 1.15 : 1.0,
                            child: Icon(
                              (bookmarksState[postId] ?? false) ? Icons.bookmark : Icons.bookmark_border,
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
        );
      },
    );
  }
}
