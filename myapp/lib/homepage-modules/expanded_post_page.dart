// myapp/lib/homepage-modules/expanded_post_page.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';

class ExpandedPostPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final Map<String, bool>? likesState;
  final Map<String, bool>? bookmarksState;
  final Map<String, List<Map<String, String>>>? commentsState;
  final Map<String, TextEditingController>? commentControllers;
  final Function(String, bool)? setLike; // new-style: set desired like state
  final Function(String, bool)? setBookmark;
  final Function(String)? addComment;

  const ExpandedPostPage({
    super.key,
    required this.post,
    this.likesState,
    this.bookmarksState,
    this.commentsState,
    this.commentControllers,
    this.setLike,
    this.setBookmark,
    this.addComment,
  });

  @override
  State<ExpandedPostPage> createState() => _ExpandedPostPageState();
}

class _ExpandedPostPageState extends State<ExpandedPostPage> {
  int currentImageIndex = 0;

  // Local references to the maps passed from the parent so we operate on the same data.
  late Map<String, bool> likes;
  late Map<String, bool> bookmarks;
  late Map<String, List<Map<String, String>>> comments;
  late Map<String, TextEditingController> commentControllers;

  @override
  void initState() {
    super.initState();
    final postId = widget.post['id'].toString();

    // Use the maps passed from parent when available — keep references so updates are shared.
    likes = widget.likesState ?? <String, bool>{};
    bookmarks = widget.bookmarksState ?? <String, bool>{};
    comments = widget.commentsState ?? <String, List<Map<String, String>>>{};
    commentControllers = widget.commentControllers ?? <String, TextEditingController>{};

    // Ensure keys exist
    likes[postId] = likes[postId] ?? false;
    bookmarks[postId] = bookmarks[postId] ?? false;
    comments[postId] = comments[postId] ?? [];
    commentControllers[postId] ??= TextEditingController();
  }

  // Toggle like with optimistic animation: compute desired state, update local map for instant UI,
  // then call parent's setter to persist base counts.
  void _onLikeTap(String postId) {
    final desired = !(likes[postId] ?? false);
    // provide immediate visual feedback
    setState(() {
      likes[postId] = desired;
    });
    // ask parent to persist (parent will adjust base counts)
    widget.setLike?.call(postId, desired);
  }

  void _onBookmarkTap(String postId) {
    final desired = !(bookmarks[postId] ?? false);
    setState(() {
      bookmarks[postId] = desired;
    });
    widget.setBookmark?.call(postId, desired);
  }

  void _handleAddComment(String postId) {
    final controller = commentControllers[postId];
    final text = controller?.text.trim();
    if (text == null || text.isEmpty) return;

    setState(() {
      comments[postId] = [
        {'username': 'Jzar Alaba', 'text': text},
        ...?comments[postId],
      ];
      controller?.clear();
    });

    widget.addComment?.call(postId);
  }

  @override
  Widget build(BuildContext context) {
    final images = List<dynamic>.from(widget.post['images'] ?? []);
    final postId = widget.post['id'].toString();

    final likesCount = (widget.post['likes'] ?? 0) as int;
    final bookmarksCount = (widget.post['bookmarks'] ?? 0) as int;

    final displayLikes = likesCount;
    final displayBookmarks = bookmarksCount;
    final postComments = comments[postId] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / carousel area
            if (images.isNotEmpty)
              Stack(
                alignment: Alignment.center,
                children: [
                  Image(
                    image: images[currentImageIndex] is Uint8List
                        ? MemoryImage(images[currentImageIndex])
                        : NetworkImage(images[currentImageIndex]) as ImageProvider,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  if (images.length > 1)
                    Positioned.fill(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                currentImageIndex =
                                    (currentImageIndex - 1 + images.length) % images.length;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                currentImageIndex =
                                    (currentImageIndex + 1) % images.length;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),

            // Post content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.post['description'] ?? ''),
                  const SizedBox(height: 8),
                  Text(
                    "${widget.post['gender'] ?? 'Unisex'} | ${widget.post['style'] ?? 'Casual'} | ${(widget.post['tags'] ?? []).take(3).join(' | ')}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Like + Bookmark (interactive with counters)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Like control (animated)
                      InkWell(
                        onTap: () => _onLikeTap(postId),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          child: Row(
                            children: [
                              AnimatedScale(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.elasticOut,
                                scale: (likes[postId] ?? false) ? 1.15 : 1.0,
                                child: Icon(
                                  (likes[postId] ?? false) ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 6),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  // We display post's base likes which parent adjusts when setLike is called.
                                  (widget.post['likes'] ?? 0).toString(),
                                  key: ValueKey<int>(widget.post['likes'] ?? 0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bookmark control (animated)
                      InkWell(
                        onTap: () => _onBookmarkTap(postId),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          child: Row(
                            children: [
                              AnimatedScale(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.elasticOut,
                                scale: (bookmarks[postId] ?? false) ? 1.15 : 1.0,
                                child: Icon(
                                  (bookmarks[postId] ?? false) ? Icons.bookmark : Icons.bookmark_border,
                                ),
                              ),
                              const SizedBox(width: 6),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  (widget.post['bookmarks'] ?? 0).toString(),
                                  key: ValueKey<int>(widget.post['bookmarks'] ?? 0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Comments: input stays on top, list below, newest first
                  const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentControllers[postId],
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _handleAddComment(postId),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => _handleAddComment(postId),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (postComments.isEmpty)
                    const Text('No comments yet', style: TextStyle(color: Colors.grey))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: postComments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final comment = postComments[i];
                        return RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: comment['username'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' ${comment['text']}'),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
