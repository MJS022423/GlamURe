import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:getwidget/getwidget.dart'; // Add this for GFCard

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  // This will be populated from your main feed when users bookmark posts
  List<BookmarkPost> bookmarks = [];

  Map<String, bool> likesState = {}; // This now syncs with saved like state
  BookmarkPost? selectedPost;
  int currentImageIndex = 0;
  bool descExpanded = false;

  final TextEditingController _commentController = TextEditingController();
  Map<String, List<Comment>> commentsState = {};

  void toggleLike(String postId) {
    setState(() {
      final wasLiked = likesState[postId] ?? false;
      likesState[postId] = !wasLiked;

      // Update bookmark if this post is bookmarked
      if (BookmarkManager().isBookmarked(postId)) {
        final bookmark = BookmarkManager().getBookmark(postId);
        if (bookmark != null) {
          // baseLikes is already the base (without user's like), so use it directly
          final baseLikes =
              bookmark.baseLikes; // Don't subtract - it's already the base!
          final isCurrentlyLiked = !wasLiked; // New state after toggle

          BookmarkManager().updateBookmarkLike(
            postId,
            isCurrentlyLiked,
            baseLikes,
          );

          // Reload bookmarks to reflect the change in UI
          _loadBookmarks();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    setState(() {
      bookmarks = List.from(BookmarkManager().bookmarks);
      // Initialize like states from saved bookmarks
      for (var bookmark in bookmarks) {
        likesState[bookmark.id] = bookmark.isLiked;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload bookmarks when page is visited to get latest updates
    _loadBookmarks();
  }

  void removeBookmark(String postId) {
    setState(() {
      bookmarks.removeWhere((post) => post.id == postId);
      if (selectedPost?.id == postId) {
        selectedPost = null;
      }
    });
    BookmarkManager().removeBookmark(postId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bookmark removed')),
    );
  }

  void openPost(BookmarkPost post) {
    setState(() {
      selectedPost = post;
      currentImageIndex = 0;
      descExpanded = false;
    });
  }

  void closePost() {
    setState(() {
      selectedPost = null;
    });
  }

  void addComment(String postId) {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      if (commentsState[postId] == null) {
        commentsState[postId] = [];
      }
      commentsState[postId]!.add(
        Comment(username: 'User', text: _commentController.text.trim()),
      );
      _commentController.clear();
    });
  }

  String truncateText(String text, int limit) {
    if (text.length <= limit) return text;
    return '${text.substring(0, limit)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Custom Header (like homepage)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'BOOKMARKS',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Stack(
              children: [
                bookmarks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No bookmarks yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Save posts using the bookmark icon',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookmarks.length,
                        itemBuilder: (context, index) {
                          final post = bookmarks[index];
                          return _buildBookmarkCard(post);
                        },
                      ),

                // Modal Overlay
                if (selectedPost != null) _buildModal(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkCard(BookmarkPost post) {
    // Get the current like state from the bookmark (it might have been updated)
    final isLiked = likesState[post.id] ?? post.isLiked;

    return GFCard(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      margin: const EdgeInsets.only(bottom: 16),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (post.imageUrls.isNotEmpty ||
              (post.imageBytes != null && post.imageBytes!.isNotEmpty))
            GestureDetector(
              onTap: () => openPost(post),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildBookmarkImage(post, 0, fit: BoxFit.cover),
                ),
              ),
            ),
          const SizedBox(height: 8),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: buildFeedDescription(post.description),
          ),
          const SizedBox(height: 4),
          // Tags
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "${post.gender} | ${post.style} | ${post.tags.take(3).join(' | ')}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          // Like and Bookmark buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => toggleLike(post.id),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: Colors.red, // Match homepage color
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.displayLikes}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => removeBookmark(post.id),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bookmark, // Always filled since it's bookmarked
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
  }

  // Add this helper method to match homepage format
  Widget buildFeedDescription(String desc) {
    const int FEED_DESC_LIMIT = 30;
    if (desc.length <= FEED_DESC_LIMIT) return Text(desc);
    return Text(desc.substring(0, FEED_DESC_LIMIT) + '...');
  }

  Widget _buildBookmarkImage(BookmarkPost post, int index,
      {BoxFit fit = BoxFit.cover}) {
    // Try to get bytes first (for Uint8List images)
    final bytes = post.getImageBytes(index);
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: fit,
        width: double.infinity,
        height: 200,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(Icons.image, size: 48, color: Colors.grey[400]),
          );
        },
      );
    }

    // Fall back to URL
    if (index < post.imageUrls.length && post.imageUrls[index].isNotEmpty) {
      // Check if it's a base64 data URL
      if (post.imageUrls[index].startsWith('data:image')) {
        // Extract base64 data
        try {
          final base64String = post.imageUrls[index].split(',')[1];
          final imageBytes = base64Decode(base64String);
          return Image.memory(
            imageBytes,
            fit: fit,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(Icons.image, size: 48, color: Colors.grey[400]),
              );
            },
          );
        } catch (e) {
          // If base64 decode fails, try as network image
          return Image.network(
            post.imageUrls[index],
            fit: fit,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(Icons.image, size: 48, color: Colors.grey[400]),
              );
            },
          );
        }
      } else {
        // Regular network image
        return Image.network(
          post.imageUrls[index],
          fit: fit,
          width: double.infinity,
          height: 200,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(Icons.image, size: 48, color: Colors.grey[400]),
            );
          },
        );
      }
    }

    // Fallback placeholder
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image, size: 48, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildModal() {
    if (selectedPost == null) return const SizedBox();

    // Get the current like state from the bookmark (it might have been updated)
    final isLiked = likesState[selectedPost!.id] ?? selectedPost!.isLiked;
    final comments = commentsState[selectedPost!.id] ?? [];

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              // Image Section
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(24)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildBookmarkImage(
                        selectedPost!,
                        currentImageIndex,
                        fit: BoxFit.cover,
                      ),
                      if (selectedPost!.imageUrls.length > 1 ||
                          (selectedPost!.imageBytes != null &&
                              selectedPost!.imageBytes!.length > 1)) ...[
                        Positioned(
                          left: 8,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white),
                            onPressed: () {
                              setState(() {
                                final totalImages =
                                    selectedPost!.imageUrls.length;
                                currentImageIndex = currentImageIndex > 0
                                    ? currentImageIndex - 1
                                    : totalImages - 1;
                              });
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios,
                                color: Colors.white),
                            onPressed: () {
                              setState(() {
                                final totalImages =
                                    selectedPost!.imageUrls.length;
                                currentImageIndex =
                                    currentImageIndex < totalImages - 1
                                        ? currentImageIndex + 1
                                        : 0;
                              });
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Details Section
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            selectedPost!.username,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: closePost,
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: Colors.grey[300]),

                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Description
                            Text(
                              descExpanded
                                  ? selectedPost!.description
                                  : truncateText(
                                      selectedPost!.description, 100),
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (selectedPost!.description.length > 100)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    descExpanded = !descExpanded;
                                  });
                                },
                                child: Text(
                                  descExpanded ? ' Show less' : ' Show more',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Meta Info
                            Text(
                              '${selectedPost!.gender} | ${selectedPost!.style}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedPost!.tags.take(3).join(' | '),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Divider(height: 1, color: Colors.grey[300]),

                    // Actions
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => toggleLike(selectedPost!.id),
                            child: Row(
                              children: [
                                Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 24,
                                  color:
                                      isLiked ? Colors.black : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${selectedPost!.displayLikes}', // This will show baseLikes + 1 if isLiked, or baseLikes if not
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => removeBookmark(selectedPost!.id),
                            child: const Icon(
                              Icons.bookmark,
                              size: 24,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: Colors.grey[300]),

                    // Comment Input
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: 'Write a comment...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              onSubmitted: (_) => addComment(selectedPost!.id),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => addComment(selectedPost!.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Send'),
                          ),
                        ],
                      ),
                    ),

                    // Comments List
                    if (comments.isNotEmpty)
                      Container(
                        height: 150,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.grey[300],
                                    child: const Icon(Icons.person, size: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          comment.text,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

// Data Models
class BookmarkPost {
  final String id;
  final List<String> imageUrls; // URL strings
  final List<Uint8List>?
      imageBytes; // Uint8List bytes (optional, for local images)
  final String description;
  final String gender;
  final String style;
  final List<String> tags;
  final int baseLikes; // Store base likes (without user's like)
  final bool isLiked;
  final String username;

  BookmarkPost({
    required this.id,
    required this.imageUrls,
    this.imageBytes, // Optional bytes for Uint8List images
    required this.description,
    required this.gender,
    required this.style,
    required this.tags,
    required this.baseLikes, // Changed from likes to baseLikes
    this.isLiked = false, // Default to false
    required this.username,
  });

  // Helper to get all images (URLs first, then bytes as base64)
  List<String> get allImageUrls => imageUrls;

  // Helper to check if we have bytes for an image at index
  Uint8List? getImageBytes(int index) {
    if (imageBytes != null && index < imageBytes!.length) {
      return imageBytes![index];
    }
    return null;
  }

  // Getter to compute display likes
  int get displayLikes => baseLikes + (isLiked ? 1 : 0);
}

class Comment {
  final String username;
  final String text;

  Comment({required this.username, required this.text});
}

// Helper class to manage bookmarks globally
class BookmarkManager {
  static final BookmarkManager _instance = BookmarkManager._internal();
  factory BookmarkManager() => _instance;
  BookmarkManager._internal();

  final List<BookmarkPost> _bookmarks = [];

  List<BookmarkPost> get bookmarks => _bookmarks;

  void addBookmark(BookmarkPost post) {
    final index = _bookmarks.indexWhere((p) => p.id == post.id);
    if (index == -1) {
      _bookmarks.add(post);
    } else {
      // Update existing bookmark
      _bookmarks[index] = post;
    }
  }

  void removeBookmark(String postId) {
    _bookmarks.removeWhere((post) => post.id == postId);
  }

  bool isBookmarked(String postId) {
    return _bookmarks.any((post) => post.id == postId);
  }

  // Add method to update like state of an existing bookmark
  void updateBookmarkLike(String postId, bool isLiked, int baseLikes) {
    final index = _bookmarks.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final existingBookmark = _bookmarks[index];
      // Create updated bookmark with new like state
      final updatedBookmark = BookmarkPost(
        id: existingBookmark.id,
        imageUrls: existingBookmark.imageUrls,
        imageBytes: existingBookmark.imageBytes,
        description: existingBookmark.description,
        gender: existingBookmark.gender,
        style: existingBookmark.style,
        tags: existingBookmark.tags,
        baseLikes: baseLikes, // Use baseLikes directly
        isLiked: isLiked,
        username: existingBookmark.username,
      );
      _bookmarks[index] = updatedBookmark;
    }
  }

  // Helper to get a bookmark by ID
  BookmarkPost? getBookmark(String postId) {
    try {
      return _bookmarks.firstWhere((post) => post.id == postId);
    } catch (e) {
      return null;
    }
  }
}
