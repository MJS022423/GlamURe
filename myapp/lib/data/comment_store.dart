// myapp/lib/data/comment_store.dart
/// Temporary global in-memory comment storage.
/// Each post has a list of comment maps:
/// {
///   "displayName": String,   // what to show as commenter name
///   "text": String,
///   "createdAt": DateTime,
///   "authorUsername": String? // optional account username (used to lookup avatar)
/// }
library;


class CommentStore {
  static final Map<int, List<Map<String, dynamic>>> _commentsByPost = {};

  /// Get all comments for a post (sorted by most recent first)
  static List<Map<String, dynamic>> getComments(int postId) {
    final list = _commentsByPost[postId] ?? [];
    final sorted = [...list];
    sorted.sort((a, b) =>
        (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));
    return sorted;
  }

  /// Add a comment to a post
  /// - displayName: the name to display on the comment (can be displayName or username)
  /// - authorUsername: optional account username to help resolve avatar/profile
  static void addComment(int postId, String displayName, String text, {String? authorUsername}) {
    final list = _commentsByPost[postId] ?? [];
    list.insert(0, {
      'displayName': displayName,
      'text': text.trim(),
      'createdAt': DateTime.now(),
      'authorUsername': authorUsername, // nullable
    });
    _commentsByPost[postId] = list;
  }

  /// Get total number of comments for a post
  static int count(int postId) {
    return _commentsByPost[postId]?.length ?? 0;
  }

  /// Clear all comments (for debug or logout)
  static void clear() {
    _commentsByPost.clear();
  }
}
