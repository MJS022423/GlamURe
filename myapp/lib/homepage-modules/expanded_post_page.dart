import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../bookmark.dart'; // Add this import
import 'dart:convert'; // Add for base64

class ExpandedPostPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final Map<String, bool>? likesState;
  final Map<String, bool>? bookmarksState;
  final Map<String, List<Map<String, String>>>? commentsState;
  final Map<String, TextEditingController>? commentControllers;
  final Function(String)? toggleLike;
  final Function(String)? toggleBookmark;
  final Function(String)? addComment;

  const ExpandedPostPage({
    super.key,
    required this.post,
    this.likesState,
    this.bookmarksState,
    this.commentsState,
    this.commentControllers,
    this.toggleLike,
    this.toggleBookmark,
    this.addComment,
  });

  @override
  State<ExpandedPostPage> createState() => _ExpandedPostPageState();
}

class _ExpandedPostPageState extends State<ExpandedPostPage> {
  int currentImageIndex = 0;

  late Map<String, bool> likes;
  late Map<String, bool> bookmarks;
  late Map<String, List<Map<String, String>>> comments;
  late Map<String, TextEditingController> commentControllers;

  @override
  void initState() {
    super.initState();
    final postId = widget.post['id'].toString();

    // Initialize maps with safe defaults
    likes = widget.likesState ?? {};
    bookmarks = widget.bookmarksState ?? {};
    comments = widget.commentsState ?? {};
    commentControllers = widget.commentControllers ?? {};

    likes[postId] = likes[postId] ?? false;
    bookmarks[postId] = bookmarks[postId] ?? false;
    comments[postId] = comments[postId] ?? [];
    commentControllers[postId] ??= TextEditingController();
  }

  @override
  void dispose() {
    // Only dispose controllers if they were created here
    commentControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = List<dynamic>.from(widget.post['images'] ?? []);
    final postId = widget.post['id'].toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            if (images.isNotEmpty)
              Stack(
                alignment: Alignment.center,
                children: [
                  Image(
                    image: images[currentImageIndex] is Uint8List
                        ? MemoryImage(images[currentImageIndex])
                        : NetworkImage(images[currentImageIndex])
                            as ImageProvider,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  if (images.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                          onPressed: () {
                            setState(() {
                              currentImageIndex =
                                  (currentImageIndex - 1 + images.length) %
                                      images.length;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios,
                              color: Colors.white),
                          onPressed: () {
                            setState(() {
                              currentImageIndex =
                                  (currentImageIndex + 1) % images.length;
                            });
                          },
                        ),
                      ],
                    ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(widget.post['description'] ?? ''),
                  const SizedBox(height: 8),
                  // Tags / Info
                  Text(
                    "${widget.post['gender'] ?? 'Unisex'} | ${widget.post['style'] ?? 'Casual'} | ${(widget.post['tags'] ?? []).take(3).join(' | ')}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Likes & Bookmarks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            likes[postId] = !(likes[postId] ?? false);
                          });

                          // Update bookmark if this post is bookmarked
                          final isCurrentlyLiked = likes[postId] ?? false;
                          final baseLikes = widget.post['likes'] ?? 0;

                          if (BookmarkManager().isBookmarked(postId)) {
                            BookmarkManager().updateBookmarkLike(
                              postId,
                              isCurrentlyLiked,
                              baseLikes,
                            );
                          }

                          widget.toggleLike?.call(postId);
                        },
                        child: Row(
                          children: [
                            Icon(
                              likes[postId]!
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                                "${(widget.post['likes'] ?? 0) + ((widget.likesState?[postId] ?? likes[postId] ?? false) ? 1 : 0)}"),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Get the current state BEFORE flipping
                          final isCurrentlyBookmarked =
                              bookmarks[postId] ?? false;

                          setState(() {
                            // Flip the state after checking
                            bookmarks[postId] = !isCurrentlyBookmarked;
                          });

                          // Now use the original state (before flip) to determine action
                          if (!isCurrentlyBookmarked) {
                            // Add to bookmarks
                            final images =
                                List<dynamic>.from(widget.post['images'] ?? []);
                            final List<String> imageUrls = [];
                            final List<Uint8List> imageBytesList = [];

                            for (var img in images) {
                              if (img is String) {
                                imageUrls.add(img);
                              } else if (img is Uint8List) {
                                final base64String = base64Encode(img);
                                final dataUrl =
                                    'data:image/jpeg;base64,$base64String';
                                imageUrls.add(dataUrl);
                                imageBytesList.add(img);
                              }
                            }

                            // Get current like state - use the actual current state
                            final currentLikeState = likes[postId] ??
                                (widget.likesState?[postId] ?? false);
                            final baseLikes = widget.post['likes'] ?? 0;
                            final currentLikesCount =
                                baseLikes + (currentLikeState ? 1 : 0);

                            final bookmarkPost = BookmarkPost(
                              id: postId,
                              imageUrls: imageUrls,
                              imageBytes: imageBytesList.isNotEmpty
                                  ? imageBytesList
                                  : null,
                              description: widget.post['description'] ?? '',
                              gender: widget.post['gender'] ?? 'Unisex',
                              style: widget.post['style'] ?? 'Casual',
                              tags:
                                  List<String>.from(widget.post['tags'] ?? []),
                              baseLikes: widget.post['likes'] ??
                               0, // Store base likes only
                              isLiked: currentLikeState,
                              username: widget.post['username'] ?? 'Unknown',
                            );

                            BookmarkManager().addBookmark(bookmarkPost);
                          } else {
                            BookmarkManager().removeBookmark(postId);
                          }

                          widget.toggleBookmark?.call(postId);
                        },
                        child: Row(
                          children: [
                            Icon(
                              bookmarks[postId]!
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Comments
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Comments',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments[postId]?.length ?? 0,
                        itemBuilder: (context, index) {
                          final comment = comments[postId]![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                      text: comment['username'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: ' ${comment['text']}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              final text =
                                  commentControllers[postId]?.text.trim();
                              if (text != null && text.isNotEmpty) {
                                setState(() {
                                  comments[postId] = [
                                    ...(comments[postId] ?? []),
                                    {'username': 'Jzar Alaba', 'text': text}
                                  ];
                                  commentControllers[postId]?.clear();
                                });
                                widget.addComment?.call(postId);
                              }
                            },
                          ),
                        ],
                      ),
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
}
