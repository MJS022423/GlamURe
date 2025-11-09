// myapp/lib/data/post_store.dart
import '../data/account_store.dart';

/// Temporary in-memory data store for posts.
/// This allows posts, likes, and bookmarks to persist
/// while navigating between pages, without needing a backend.

class PostStore {
  /// The global list of posts available throughout the app.
  /// Each post is expected to have at least:
  /// { 'id': int, 'username': String, 'description': String, 'images': List, 'tags': List, 'likes': int, 'bookmarks': int, 'createdAt': String }
  static List<Map<String, dynamic>> posts = [];

  /// Ensure a numeric unique id if none provided
  static int _generateId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    // If collision (very unlikely) make small adjustments
    if (posts.any((p) => p['id'] == now)) {
      return now + posts.length + 1;
    }
    return now;
  }

  /// Add a new post to the top of the feed.
  /// Fills missing defaults (id, createdAt, username, likes, bookmarks).
  static void addPost(Map<String, dynamic> newPost) {
    // ensure id
    newPost['id'] ??= _generateId();

    // ensure createdAt (store as ISO string)
    if (newPost['createdAt'] == null) {
      newPost['createdAt'] = DateTime.now().toIso8601String();
    } else if (newPost['createdAt'] is DateTime) {
      newPost['createdAt'] = (newPost['createdAt'] as DateTime).toIso8601String();
    }

    // ensure username: prefer provided, fall back to current signed-in user
    newPost['username'] ??= AccountStore.currentUsername ?? 'Anonymous';

    // ensure numeric counters
    newPost['likes'] = (newPost['likes'] is int) ? newPost['likes'] as int : 0;
    newPost['bookmarks'] = (newPost['bookmarks'] is int) ? newPost['bookmarks'] as int : 0;

    // ensure images list exists
    newPost['images'] ??= <dynamic>[];

    // insert at beginning to keep newest first
    posts.insert(0, Map<String, dynamic>.from(newPost));
  }

  /// Get all posts (sorted by creation date descending).
  static List<Map<String, dynamic>> getAllPosts() {
    final sorted = [...posts];
    sorted.sort((a, b) {
      final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    // Return clones so external mutation doesn't accidentally change store
    return sorted.map((p) => Map<String, dynamic>.from(p)).toList();
  }

  /// Get a post by ID (null if not found)
  static Map<String, dynamic>? getPostById(int id) {
    final found = posts.firstWhere((p) => p['id'] == id, orElse: () => {});
    if (found.isEmpty) return null;
    return Map<String, dynamic>.from(found);
  }

  /// Get posts created by a specific username.
  static List<Map<String, dynamic>> getPostsByUser(String username) {
    final filtered = posts.where((p) {
      final pUser = p['username'];
      if (pUser == null) return false;
      return pUser.toString() == username;
    }).toList();
    filtered.sort((a, b) {
      final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return filtered.map((p) => Map<String, dynamic>.from(p)).toList();
  }

  /// Get top designs sorted by likes.
  static List<Map<String, dynamic>> getTopDesigns({int limit = 3}) {
    final sorted = [...posts];
    sorted.sort((a, b) => ((b['likes'] ?? 0) as int).compareTo((a['likes'] ?? 0) as int));
    return sorted.take(limit).map((p) => Map<String, dynamic>.from(p)).toList();
  }

  /// Update an existing post by ID. Merges existing post map with updatedData.
  /// If a numeric counter is provided it will replace the value.
  static void updatePost(int id, Map<String, dynamic> updatedData) {
    final index = posts.indexWhere((p) => p['id'] == id);
    if (index == -1) return;

    final merged = {...posts[index], ...updatedData};

    // keep createdAt as ISO string
    if (merged['createdAt'] is DateTime) {
      merged['createdAt'] = (merged['createdAt'] as DateTime).toIso8601String();
    }

    // ensure likes/bookmarks integers
    merged['likes'] = (merged['likes'] is int) ? merged['likes'] as int : int.tryParse('${merged['likes']}') ?? 0;
    merged['bookmarks'] = (merged['bookmarks'] is int) ? merged['bookmarks'] as int : int.tryParse('${merged['bookmarks']}') ?? 0;

    posts[index] = merged;
  }

  /// Clear all posts (for debugging or refresh resets).
  static void clear() {
    posts.clear();
  }
}
