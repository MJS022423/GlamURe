// myapp/lib/data/post_store.dart
/// Temporary in-memory data store for posts.
/// This allows posts, likes, and bookmarks to persist
/// while navigating between pages, without needing a backend.

class PostStore {
  /// The global list of posts available throughout the app.
  static List<Map<String, dynamic>> posts = [];

  /// Add a new post to the top of the feed.
  static void addPost(Map<String, dynamic> newPost) {
    // Ensure newPost has a createdAt
    newPost['createdAt'] ??= DateTime.now().toIso8601String();
    posts.insert(0, newPost);
  }

  /// Get all posts (sorted by creation date descending).
  static List<Map<String, dynamic>> getAllPosts() {
    final sorted = [...posts];
    sorted.sort((a, b) {
      final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
      final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  /// Get posts created by a specific username.
  static List<Map<String, dynamic>> getPostsByUser(String username) {
    final filtered = posts.where((p) {
      final pUser = p['username'];
      if (pUser == null) return false;
      return pUser.toString() == username;
    }).toList();
    filtered.sort((a, b) {
      final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
      final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
      return bDate.compareTo(aDate);
    });
    return filtered;
  }

  /// Get top designs sorted by likes.
  static List<Map<String, dynamic>> getTopDesigns({int limit = 3}) {
    final sorted = [...posts];
    sorted.sort((a, b) =>
        ((b['likes'] ?? 0) as int).compareTo((a['likes'] ?? 0) as int));
    return sorted.take(limit).toList();
  }

  /// Update an existing post by ID.
  static void updatePost(int id, Map<String, dynamic> updatedData) {
    final index = posts.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      posts[index] = {...posts[index], ...updatedData};
    }
  }

  /// Clear all posts (for debugging or refresh resets).
  static void clear() {
    posts.clear();
  }
}
