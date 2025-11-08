import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class PostFeedModule extends StatefulWidget {
  final List<Map<String, dynamic>> posts;
  const PostFeedModule({super.key, required this.posts});

  @override
  State<PostFeedModule> createState() => _PostFeedModuleState();
}

class _PostFeedModuleState extends State<PostFeedModule> {
  Map<String, bool> likesState = {};
  Map<String, bool> bookmarksState = {};
  Map<String, List<Map<String, String>>> commentsState = {};
  Map<String, TextEditingController> commentControllers = {};
  Map<String, int> currentImageIndex = {};

  void toggleLike(String postId) {
    setState(() {
      likesState[postId] = !(likesState[postId] ?? false);
    });
  }

  void toggleBookmark(String postId) {
    setState(() {
      bookmarksState[postId] = !(bookmarksState[postId] ?? false);
    });
  }

  void addComment(String postId) {
    final controller = commentControllers[postId];
    if (controller == null || controller.text.trim().isEmpty) return;

    setState(() {
      commentsState[postId] = [
        ...(commentsState[postId] ?? []),
        {'username': 'Jzar Alaba', 'text': controller.text.trim()}
      ];
      controller.clear();
    });
  }

  Widget buildFeedDescription(String desc) {
    const int FEED_DESC_LIMIT = 30;
    if (desc.length <= FEED_DESC_LIMIT) return Text(desc);
    return Text(desc.substring(0, FEED_DESC_LIMIT) + '...');
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

        // Initialize states immediately
        likesState[postId] = likesState[postId] ?? false;
        bookmarksState[postId] = bookmarksState[postId] ?? false;
        commentsState[postId] = commentsState[postId] ?? [];
        commentControllers[postId] ??= TextEditingController();
        currentImageIndex[postId] = currentImageIndex[postId] ?? 0;

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
                          toggleLike: toggleLike,
                          toggleBookmark: toggleBookmark,
                          addComment: addComment,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "${post['gender']} | ${post['style']} | ${(post['tags'] ?? []).take(3).join(' | ')}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => toggleLike(postId),
                      child: Row(
                        children: [
                          Icon(
                            likesState[postId]! ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text("${post['likes'] + (likesState[postId]! ? 1 : 0)}"),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => toggleBookmark(postId),
                      child: Row(
                        children: [
                          Icon(
                            bookmarksState[postId]! ? Icons.bookmark : Icons.bookmark_border,
                            size: 20,
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

class ExpandedPostPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final Map<String, bool> likesState;
  final Map<String, bool> bookmarksState;
  final Map<String, List<Map<String, String>>> commentsState;
  final Map<String, TextEditingController> commentControllers;
  final Function(String) toggleLike;
  final Function(String) toggleBookmark;
  final Function(String) addComment;

  const ExpandedPostPage({
    super.key,
    required this.post,
    required this.likesState,
    required this.bookmarksState,
    required this.commentsState,
    required this.commentControllers,
    required this.toggleLike,
    required this.toggleBookmark,
    required this.addComment,
  });

  @override
  State<ExpandedPostPage> createState() => _ExpandedPostPageState();
}

class _ExpandedPostPageState extends State<ExpandedPostPage> {
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    final postId = widget.post['id'].toString();
    currentImageIndex = 0;

    // Ensure maps are initialized
    widget.likesState[postId] = widget.likesState[postId] ?? false;
    widget.bookmarksState[postId] = widget.bookmarksState[postId] ?? false;
    widget.commentsState[postId] = widget.commentsState[postId] ?? [];
    widget.commentControllers[postId] ??= TextEditingController();
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
                    Row(
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
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.post['description'] ?? ''),
                  const SizedBox(height: 8),
                  Text(
                    "${widget.post['gender']} | ${widget.post['style']} | ${(widget.post['tags'] ?? []).take(3).join(' | ')}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.likesState[postId] = !(widget.likesState[postId]!);
                          });
                          widget.toggleLike(postId);
                        },
                        child: Row(
                          children: [
                            Icon(
                              widget.likesState[postId]! ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text("${widget.post['likes'] + (widget.likesState[postId]! ? 1 : 0)}"),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.bookmarksState[postId] = !(widget.bookmarksState[postId]!);
                          });
                          widget.toggleBookmark(postId);
                        },
                        child: Row(
                          children: [
                            Icon(
                              widget.bookmarksState[postId]! ? Icons.bookmark : Icons.bookmark_border,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (widget.commentsState[postId] ?? []).length,
                    itemBuilder: (context, index) {
                      final comment = widget.commentsState[postId]![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                  text: comment['username'],
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: ' ${comment['text']}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.commentControllers[postId],
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => widget.addComment(postId),
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
