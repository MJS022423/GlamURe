// lib/data/account_store.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // debugPrint
import 'post_store.dart';

/// In-memory account store for local/dev testing.
/// Use a real backend for production.
class AccountStore {
  static final Map<String, Map<String, dynamic>> _users = {};

  static String? currentUsername;
  static Map<String, dynamic>? currentUser;

  static String? registerUser({
    required String username,
    required String email,
    required String password,
  }) {
    final u = username.trim();
    final e = email.trim();

    if (u.isEmpty || e.isEmpty || password.isEmpty) {
      return "Please provide username, email and password.";
    }

    if (_users.containsKey(u)) {
      return "Username already taken. Choose another.";
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(e)) {
      return "Please provide a valid email address.";
    }

    _users[u] = {
      'username': u,
      'email': e,
      'password': password,
      'displayName': null,
      'gender': null,
      'role': null,
      'profileImage': null,
      'createdAt': DateTime.now().toIso8601String(),
    };

    debugPrint("AccountStore.registerUser: created user $u");
    _debugDump();
    return null;
  }

  static String? login(String username, String password) {
    final u = username.trim();
    if (u.isEmpty || password.isEmpty) {
      return "Please enter username and password.";
    }

    final user = _users[u];
    if (user == null) {
      return "No account found for that username.";
    }

    if (user['password'] != password) {
      return "Incorrect password.";
    }

    currentUsername = u;
    currentUser = Map<String, dynamic>.from(user);
    debugPrint("AccountStore.login: $u logged in");
    _debugDump();
    return null;
  }

  static void logout() {
    debugPrint("AccountStore.logout: logging out $currentUsername");
    currentUsername = null;
    currentUser = null;
  }

  static bool updateCurrentUser(Map<String, dynamic> updates) {
    if (currentUsername == null) return false;
    final username = currentUsername!;
    final user = _users[username];
    if (user == null) return false;

    user.addAll(updates);
    currentUser = Map<String, dynamic>.from(user);
    debugPrint("AccountStore.updateCurrentUser: updated $username with $updates");
    _debugDump();
    return true;
  }

  static bool updateProfile(Map<String, dynamic> updates) => updateCurrentUser(updates);

  static bool setProfileImageBase64(String base64Image) {
    if (currentUsername == null) return false;
    final ok = updateCurrentUser({'profileImage': base64Image});
    if (ok) {
      // also update currentUser snapshot already done by updateCurrentUser
      debugPrint("AccountStore.setProfileImageBase64: applied");
    }
    return ok;
  }

  static bool deleteCurrentAccount() {
    final u = currentUsername;
    if (u == null) return false;
    final removed = _users.remove(u) != null;
    if (removed) {
      debugPrint("AccountStore.deleteCurrentAccount: removed $u");
      currentUsername = null;
      currentUser = null;
      _debugDump();
    }
    return removed;
  }

  static Map<String, dynamic>? getPublicProfile(String username) {
    final user = _users[username];
    if (user == null) return null;
    final copy = Map<String, dynamic>.from(user);
    copy.remove('password');
    return copy;
  }

  static Map<String, dynamic>? getCurrentUserSnapshot() {
    return currentUser == null ? null : Map<String, dynamic>.from(currentUser!);
  }

  static List<Map<String, dynamic>> getAllUsers() {
    return _users.values
        .map((u) => Map<String, dynamic>.from(u)..remove('password'))
        .toList();
  }

  /// --- NEW helper methods used by Settings ---

  /// Change username (rename account). Returns null on success or error string.
  /// This moves the user record and updates currentUsername/currentUser.
  static String? changeUsername(String newUsername) {
    final cur = currentUsername;
    if (cur == null) return "No logged-in user.";
    final candidate = newUsername.trim();
    if (candidate.isEmpty) return "Username cannot be empty.";
    if (candidate == cur) return null;

    if (_users.containsKey(candidate)) return "Username already taken.";

    final user = _users.remove(cur);
    if (user == null) return "Current user not found in storage.";

    // update user's username field
    user['username'] = candidate;
    _users[candidate] = user;

    // update posts authored by old username to new username
    try {
      final all = PostStore.getAllPosts();
      for (final p in all) {
        if ((p['username'] ?? '') == cur) {
          PostStore.updatePost(p['id'] as int, {'username': candidate});
        }
      }
    } catch (e) {
      debugPrint("AccountStore.changeUsername: post update failed: $e");
    }

    // update currentUsername/currentUser
    currentUsername = candidate;
    currentUser = Map<String, dynamic>.from(user);
    debugPrint("AccountStore.changeUsername: $cur -> $candidate");
    _debugDump();
    return null;
  }

  /// Change email; returns null on success or error string.
  static String? changeEmail(String newEmail) {
    final cur = currentUsername;
    if (cur == null) return "No logged-in user.";
    final e = newEmail.trim();
    if (e.isEmpty) return "Email cannot be empty.";
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(e)) return "Invalid email address.";
    final user = _users[cur];
    if (user == null) return "User record not found.";
    user['email'] = e;
    currentUser = Map<String, dynamic>.from(user);
    debugPrint("AccountStore.changeEmail: updated $cur -> $e");
    _debugDump();
    return null;
  }

  /// Verify password for the current user (used before changing password)
  static bool verifyPassword(String password) {
    final cur = currentUsername;
    if (cur == null) return false;
    final user = _users[cur];
    if (user == null) return false;
    return user['password'] == password;
  }

  /// Change password for current user. Returns true on success.
  static bool changePassword(String newPassword) {
    final cur = currentUsername;
    if (cur == null) return false;
    final user = _users[cur];
    if (user == null) return false;
    user['password'] = newPassword;
    currentUser = Map<String, dynamic>.from(user);
    debugPrint("AccountStore.changePassword: password updated for $cur");
    _debugDump();
    return true;
  }

  static void _debugDump() {
    debugPrint("AccountStore users: ${_users.keys.toList()}");
    debugPrint("CurrentUser: $currentUser");
  }

  static void _clearAll() {
    _users.clear();
    currentUser = null;
    currentUsername = null;
    debugPrint("AccountStore cleared.");
  }
}
