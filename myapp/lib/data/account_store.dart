// myapp/lib/data/account_store.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // debugPrint

// In-memory account store for local/dev testing.
// Replace/extend with real backend (API / secure storage) later.

class AccountStore {
  // Private in-memory storage: username -> user map
  // user map keys:
  // 'username', 'email', 'password' (plaintext for dev), 'displayName', 'gender',
  // 'role', 'profileImage' (base64 string) etc.
  static final Map<String, Map<String, dynamic>> _users = {};

  // Currently signed-in username (or null)
  static String? currentUsername;

  // Currently loaded user map (or null)
  // Keep this populated for quick read by UI; SetupAccount/ Login update it.
  static Map<String, dynamic>? currentUser;

  /// Register a new user. Returns null on success, or a string error message.
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

    // very light email check
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(e)) {
      return "Please provide a valid email address.";
    }

    // create user record
    _users[u] = {
      'username': u,
      'email': e,
      'password': password, // dev-only: store hashed in production
      'displayName': null,
      'gender': null,
      'role': null,
      'profileImage': null, // base64 string
      'createdAt': DateTime.now().toIso8601String(),
    };

    // leave currentUser empty — setup step will fill profile and then login
    debugPrint("AccountStore.registerUser: created user $u");
    _debugDump();

    return null;
  }

  /// Attempt login. If success returns null, otherwise returns an error message.
  /// On success sets currentUsername and currentUser.
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

    // success
    currentUsername = u;
    // clone map to avoid accidental external mutation
    currentUser = Map<String, dynamic>.from(user);
    debugPrint("AccountStore.login: $u logged in");
    _debugDump();
    return null;
  }

  /// Logout current user
  static void logout() {
    debugPrint("AccountStore.logout: logging out $currentUsername");
    currentUsername = null;
    currentUser = null;
  }

  /// Update current user's fields (and underlying storage) — returns true on success
  /// Use this from SetupAccount and profile editing.
  static bool updateCurrentUser(Map<String, dynamic> updates) {
    if (currentUsername == null) return false;
    final username = currentUsername!;
    final user = _users[username];
    if (user == null) return false;

    // Merge updates into stored user
    user.addAll(updates);
    // Also update currentUser view
    currentUser = Map<String, dynamic>.from(user);
    debugPrint("AccountStore.updateCurrentUser: updated $username with $updates");
    _debugDump();
    return true;
  }

  /// Convenience: set profile image as base64 string
  static bool setProfileImageBase64(String base64Image) {
    if (currentUsername == null) return false;
    return updateCurrentUser({'profileImage': base64Image});
  }

  /// Convenience getter for a user's public profile (safe to expose)
  /// Returns a sanitized copy (doesn't expose password)
  static Map<String, dynamic>? getPublicProfile(String username) {
    final user = _users[username];
    if (user == null) return null;
    final copy = Map<String, dynamic>.from(user);
    copy.remove('password');
    return copy;
  }

  /// Debug helper
  static void _debugDump() {
    debugPrint("AccountStore users: ${_users.keys.toList()}");
    debugPrint("CurrentUser: $currentUser");
  }

  /// For testing / dev: clear all accounts
  static void _clearAll() {
    _users.clear();
    currentUser = null;
    currentUsername = null;
    debugPrint("AccountStore cleared.");
  }
}
