// myapp/lib/data/user_actions_store.dart
import 'package:flutter/foundation.dart';
import 'post_store.dart';
import 'account_store.dart';

/// Per-user like/bookmark tracking.
/// _likesByUser[username] = Set of postIds liked by that user
/// _bookmarksByUser[username] = Set of postIds bookmarked by that user
class UserActionsStore {
  static final Map<String, Set<int>> _likesByUser = {};
  static final Map<String, Set<int>> _bookmarksByUser = {};

  static void _ensureUserBucket(String username) {
    _likesByUser.putIfAbsent(username, () => <int>{});
    _bookmarksByUser.putIfAbsent(username, () => <int>{});
  }

  /// Returns whether the current user (AccountStore.currentUsername) has liked the post.
  /// If you want to check for a specific username pass that in.
  static bool isLiked(int postId, {String? username}) {
    final user = username ?? AccountStore.currentUsername;
    if (user == null) return false;
    _ensureUserBucket(user);
    return _likesByUser[user]!.contains(postId);
  }

  static bool isBookmarked(int postId, {String? username}) {
    final user = username ?? AccountStore.currentUsername;
    if (user == null) return false;
    _ensureUserBucket(user);
    return _bookmarksByUser[user]!.contains(postId);
  }

  /// Toggle or set like for current user. Updates PostStore counts atomically.
  static void toggleLike(int postId, bool newState) {
    final user = AccountStore.currentUsername;
    if (user == null) {
      debugPrint("UserActionsStore.toggleLike: no logged in user");
      return;
    }
    _ensureUserBucket(user);

    final liked = _likesByUser[user]!;
    final already = liked.contains(postId);

    if (newState) {
      if (!already) {
        liked.add(postId);
        // increment central post counter
        final post = _findPost(postId);
        if (post != null) {
          final likes = (post['likes'] ?? 0) as int;
          PostStore.updatePost(postId, {'likes': likes + 1});
        }
      }
    } else {
      if (already) {
        liked.remove(postId);
        final post = _findPost(postId);
        if (post != null) {
          var likes = (post['likes'] ?? 0) as int;
          likes = (likes - 1).clamp(0, 1 << 30);
          PostStore.updatePost(postId, {'likes': likes});
        }
      }
    }

    debugPrint("UserActionsStore.toggleLike: $user -> $postId isLiked=${liked.contains(postId)}");
  }

  static void toggleBookmark(int postId, bool newState) {
    final user = AccountStore.currentUsername;
    if (user == null) {
      debugPrint("UserActionsStore.toggleBookmark: no logged in user");
      return;
    }
    _ensureUserBucket(user);

    final setBm = _bookmarksByUser[user]!;
    final already = setBm.contains(postId);

    if (newState) {
      if (!already) {
        setBm.add(postId);
        final post = _findPost(postId);
        if (post != null) {
          final bm = (post['bookmarks'] ?? 0) as int;
          PostStore.updatePost(postId, {'bookmarks': bm + 1});
        }
      }
    } else {
      if (already) {
        setBm.remove(postId);
        final post = _findPost(postId);
        if (post != null) {
          var bm = (post['bookmarks'] ?? 0) as int;
          bm = (bm - 1).clamp(0, 1 << 30);
          PostStore.updatePost(postId, {'bookmarks': bm});
        }
      }
    }

    debugPrint("UserActionsStore.toggleBookmark: $user -> $postId isBookmarked=${setBm.contains(postId)}");
  }

  /// Helper: find post map via PostStore.getAllPosts()
    static Map<String, dynamic>? _findPost(int postId) {
      try {
        return PostStore.getAllPosts().firstWhere(
          (p) => p['id'] == postId,
          orElse: () => {},
        );
      } catch (e) {
        return null;
      }
    }

  /// Clear a specific user's transient state (use on logout / cleanup if desired)
  static void clearUser(String username) {
    _likesByUser.remove(username);
    _bookmarksByUser.remove(username);
    debugPrint("UserActionsStore.clearUser: cleared $username");
  }

  static void clearCurrentUser() {
    final u = AccountStore.currentUsername;
    if (u != null) clearUser(u);
  }
}
