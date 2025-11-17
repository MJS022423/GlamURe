// myapp/lib/homepage-modules/expanded_post_page.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/post_store.dart';
import '../data/user_actions_store.dart';
import '../data/comment_store.dart';
import '../data/account_store.dart'; // to fetch avatars/public profiles
import '../profile/profile_page.dart'; // <- new import for navigating to profile

class ExpandedPostPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final Map<String, bool> likesState;
  final Map<String, bool> bookmarksState;
  final Map<String, List<Map<String, String>>> commentsState;
  final Map<String, TextEditingController> commentControllers;
  final Function(int, bool) setLike;
  final Function(int, bool) setBookmark;
  final Function(int) addComment;

  const ExpandedPostPage({
    super.key,
    required this.post,
    required this.likesState,
    required this.bookmarksState,
    required this.commentsState,
    required this.commentControllers,
    required this.setLike,
    required this.setBookmark,
    required this.addComment,
  });

  @override
  State<ExpandedPostPage> createState() => _ExpandedPostPageState();
}

class _ExpandedPostPageState extends State<ExpandedPostPage>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic> post;
  bool isLiked = false;
  bool isBookmarked = false;
  final TextEditingController commentController = TextEditingController();
  Timer? _timeRefreshTimer;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // network icons (same URLs)
  static const _heartUnlikedUrl = 'https://www.svgrepo.com/show/532473/heart.svg';
  static const _heartLikedUrl = 'https://www.svgrepo.com/show/369346/heart.svg';

  @override
  void initState() {
    super.initState();
    post = widget.post;

    final postId = post['id'] as int;
    isLiked = UserActionsStore.isLiked(postId);
    isBookmarked = UserActionsStore.isBookmarked(postId);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    // refresh "time ago" every second so times are realtime (secs -> mins -> hours -> days)
    _timeRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _timeRefreshTimer?.cancel();
    commentController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    final postId = post['id'] as int;
    final newState = !isLiked;
    setState(() {
      isLiked = newState;
      UserActionsStore.toggleLike(postId, newState);

      var likes = (post['likes'] ?? 0) as int;
      likes += newState ? 1 : -1;
      if (likes < 0) likes = 0;
      post['likes'] = likes;
      PostStore.updatePost(postId, {'likes': likes});
    });
  }

  void _toggleBookmark() {
    final postId = post['id'] as int;
    final newState = !isBookmarked;
    setState(() {
      isBookmarked = newState;
      UserActionsStore.toggleBookmark(postId, newState);

      var bookmarks = (post['bookmarks'] ?? 0) as int;
      bookmarks += newState ? 1 : -1;
      if (bookmarks < 0) bookmarks = 0;
      post['bookmarks'] = bookmarks;
      PostStore.updatePost(postId, {'bookmarks': bookmarks});
    });
  }

  void _addComment() {
    final postId = post['id'] as int;
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    final current = AccountStore.currentUser;
    final displayName = (current != null && (current['displayName'] ?? '').toString().isNotEmpty)
        ? current['displayName'] as String
        : (AccountStore.currentUsername ?? (current != null ? current['username'] : null) ?? 'Anonymous');
    final authorUsername = AccountStore.currentUsername;

    CommentStore.addComment(postId, displayName, text, authorUsername: authorUsername);

    commentController.clear();
    setState(() {});
  }

  /// Returns a realtime human-friendly delta string:
  /// - "now" (0s)
  /// - "5s ago" (seconds)
  /// - "1m ago", "23m ago" (minutes)
  /// - "3h ago" (hours)
  /// - "2d ago" (days)
  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    final seconds = diff.inSeconds;
    if (seconds < 1) return 'now';
    if (seconds < 60) return '${seconds}s ago';
    final minutes = diff.inMinutes;
    if (minutes < 60) return '${minutes}m ago';
    final hours = diff.inHours;
    if (hours < 24) return '${hours}h ago';
    final days = diff.inDays;
    return '${days}d ago';
  }

  Widget _buildCommentAvatar(Map<String, dynamic> comment) {
    final authorUsername = comment['authorUsername'] as String?;
    Map<String, dynamic>? profile;
    if (authorUsername != null) {
      profile = AccountStore.getPublicProfile(authorUsername);
    }

    final base64Img = profile != null ? (profile['profileImage'] as String?) : null;
    if (base64Img != null && base64Img.isNotEmpty) {
      try {
        final bytes = base64Decode(base64Img);
        return CircleAvatar(
          radius: 18,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        // fall through
      }
    }

    final displayName = (comment['displayName'] as String?) ?? '';
    if (displayName.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey[300],
        child: Text(
          displayName[0].toUpperCase(),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey[300],
      child: const Icon(Icons.person, color: Colors.black),
    );
  }

  /// Build an author header with avatar + name which navigates to ProfilePage when tapped.
  Widget _buildAuthorHeader(BuildContext context) {
    // Try a few conventions to find author info inside the post map:
    Map<String, dynamic>? authorMap;
    String? authorUsername;

    if (post['user'] is Map<String, dynamic>) {
      authorMap = Map<String, dynamic>.from(post['user']);
      authorUsername = (authorMap['username'] ?? authorMap['handle'] ?? authorMap['authorUsername'])?.toString();
    } else if (post['author'] is Map<String, dynamic>) {
      authorMap = Map<String, dynamic>.from(post['author']);
      authorUsername = (authorMap['username'] ?? authorMap['handle'] ?? authorMap['authorUsername'])?.toString();
    } else if (post['authorUsername'] != null) {
      authorUsername = post['authorUsername'].toString();
    } else if (post['username'] != null) {
      authorUsername = post['username'].toString();
    } else if (post['authorId'] != null) {
      authorUsername = post['authorId'].toString();
    }

    // If we don't already have a map, try to load a public profile by username.
    if (authorMap == null && authorUsername != null) {
      try {
        final publicProfile = AccountStore.getPublicProfile(authorUsername);
        if (publicProfile != null) authorMap = Map<String, dynamic>.from(publicProfile);
      } catch (e) {
        // ignore
      }
    }

    // Fallback minimal map so UI still shows something
    final displayName = (authorMap != null
            ? (authorMap['displayName'] ?? authorMap['name'] ?? authorMap['username'])
            : authorUsername) ??
        'Unknown';

    final avatarSource = authorMap != null
        ? (authorMap['profileImage'] ?? authorMap['avatar'] ?? authorMap['photo'])
        : null;

    ImageProvider? avatarImageProvider;
    if (avatarSource is Uint8List) {
      avatarImageProvider = MemoryImage(avatarSource);
    } else if (avatarSource is String && avatarSource.isNotEmpty) {
      // If the profile image looks like base64, decode it; otherwise treat it as a URL
      final maybeBase64 = avatarSource;
      if (maybeBase64.contains(RegExp(r'^[A-Za-z0-9+/=]+\$'))) {
        try {
          final bytes = base64Decode(maybeBase64);
          avatarImageProvider = MemoryImage(bytes);
        } catch (_) {
          avatarImageProvider = NetworkImage(maybeBase64);
        }
      } else if (maybeBase64.startsWith('http') || maybeBase64.startsWith('data:')) {
        // data: URIs with base64 are handled by MemoryImage above when decoded; treat http as network
        if (maybeBase64.startsWith('data:')) {
          // strip prefix if it's a data uri like "data:image/png;base64,...."
          final parts = maybeBase64.split(',');
          if (parts.length == 2) {
            try {
              final bytes = base64Decode(parts[1]);
              avatarImageProvider = MemoryImage(bytes);
            } catch (_) {
              avatarImageProvider = null;
            }
          }
        } else {
          avatarImageProvider = NetworkImage(maybeBase64);
        }
      } else {
        // last resort, attempt network image
        avatarImageProvider = NetworkImage(maybeBase64);
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              // When tapped open ProfilePage for this author.
              // If we have a full authorMap, pass it. Otherwise, pass a minimal map with username.
              final toPass = authorMap ?? <String, dynamic>{'username': authorUsername};
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage(user: toPass)),
              );
            },
            borderRadius: BorderRadius.circular(28),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: avatarImageProvider,
                  child: avatarImageProvider == null
                      ? Text(
                          displayName.toString().isNotEmpty ? displayName.toString()[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    if ((authorMap != null && (authorMap['username'] ?? authorMap['handle'] ?? '').toString().isNotEmpty) ||
                        (authorUsername != null && authorUsername.isNotEmpty))
                      Text(
                        '@${(authorMap != null ? (authorMap['username'] ?? authorMap['handle']) : authorUsername) ?? ''}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // you can keep other header actions here (e.g., more menu)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = List<dynamic>.from(post['images'] ?? []);
    final desc = post['description'] ?? '';
    final tags = List<String>.from(post['tags'] ?? []);
    final likes = (post['likes'] ?? 0) as int;
    final bookmarks = (post['bookmarks'] ?? 0) as int;
    final postId = post['id'] as int;
    final comments = CommentStore.getComments(postId);

    final heartUrl = isLiked ? _heartLikedUrl : _heartUnlikedUrl;

    return Scaffold(
      backgroundColor: const Color(0xfffde2e4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Post Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author header added here:
              _buildAuthorHeader(context),

              if (images.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    height: 320,
                    decoration: BoxDecoration(
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    desc,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              if (tags.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: tags
                        .map((t) => Chip(
                              label: Text(t,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black)),
                              backgroundColor: Colors.pink.shade50,
                            ))
                        .toList(),
                  ),
                ),

              const SizedBox(height: 10),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: _toggleLike,
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          AnimatedScale(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            scale: isLiked ? 1.2 : 1.0,
                            child: SvgPicture.asset(
                              isLiked
                                  ? 'assets/likediconheart.svg'
                                  : 'assets/unlikeiconheart.svg',
                              width: 26,
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              likes.toString(),
                              key: ValueKey<int>(likes),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: _toggleBookmark,
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          AnimatedScale(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            scale: isBookmarked ? 1.2 : 1.0,
                            child: SvgPicture.asset(
                              'assets/bookmark.svg',
                              width: 26,
                              colorFilter: ColorFilter.mode(
                                isBookmarked
                                    ? Colors.pinkAccent
                                    : Colors.black54,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              bookmarks.toString(),
                              key: ValueKey<int>(bookmarks),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 20, color: Colors.black26),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            maxLength: 100,
                            decoration: InputDecoration(
                              hintText: "Add a comment...",
                              counterText: "",
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.send,
                              color: Colors.pinkAccent, size: 24),
                          onPressed: _addComment,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    comments.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "No comments yet. Be the first!",
                              style:
                                  TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, i) {
                              final c = comments[i];
                              final createdAt = c['createdAt'] as DateTime;
                              final commenterName = c['displayName'] as String? ?? 'Anonymous';
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: _buildCommentAvatar(c),
                                title: Text(
                                  commenterName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                subtitle: Text(
                                  c['text'] as String? ?? '',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                trailing: Text(
                                  _timeAgo(createdAt),
                                  style: const TextStyle(
                                      color: Colors.black45, fontSize: 12),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
