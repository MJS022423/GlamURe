// myapp/lib/data/user_actions_store.dart
/// Keeps track of the user's like/bookmark states globally (temporary local store).
class UserActionsStore {
  static final Map<int, bool> likedPosts = {};
  static final Map<int, bool> bookmarkedPosts = {};

  static bool isLiked(int id) => likedPosts[id] ?? false;
  static bool isBookmarked(int id) => bookmarkedPosts[id] ?? false;

  static void toggleLike(int id, bool state) => likedPosts[id] = state;
  static void toggleBookmark(int id, bool state) => bookmarkedPosts[id] = state;

  static void clear() {
    likedPosts.clear();
    bookmarkedPosts.clear();
  }
}
