// lib/profile/widgets/recent_posts.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/post_store.dart';
import '../../data/user_actions_store.dart';
import '../../data/account_store.dart';
import 'dart:convert';

class RecentPosts extends StatefulWidget {
  final Map<String, dynamic>? owner; // optional owner to filter by
  final void Function(Map<String, dynamic> post)? onOpenPost;
  final VoidCallback? onChanged;

  const RecentPosts({super.key, this.owner, this.onOpenPost, this.onChanged});

  @override
  State<RecentPosts> createState() => _RecentPostsState();
}

class _RecentPostsState extends State<RecentPosts> {
  String? _usernameFromOwner(Map<String, dynamic>? owner) {
    if (owner == null) return null;
    return (owner['username'] ?? owner['handle'] ?? owner['authorUsername'] ?? owner['name'])?.toString();
  }

  List<Map<String, dynamic>> get _posts {
    final ownerUsername = _usernameFromOwner(widget.owner);
    final currentUsername = ownerUsername ?? (AccountStore.currentUsername ?? AccountStore.currentUser?['username']);
    if (currentUsername == null) return <Map<String, dynamic>>[];
    // Use PostStore helper to fetch posts for a username.
    // Make sure PostStore.getPostsByUser returns List<Map<String, dynamic>>
    final list = PostStore.getPostsByUser(currentUsername);
    return list ?? <Map<String, dynamic>>[];
  }

  void _toggleLike(int postId) {
    final isLiked = UserActionsStore.isLiked(postId);
    try {
      UserActionsStore.toggleLike(postId, !isLiked);
    } catch (_) {}
    setState(() {});
    widget.onChanged?.call();
  }

  void _toggleBookmark(int postId) {
    final isBookmarked = UserActionsStore.isBookmarked(postId);
    try {
      UserActionsStore.toggleBookmark(postId, !isBookmarked);
    } catch (_) {}
    setState(() {});
    widget.onChanged?.call();
  }

  Widget _buildImage(dynamic img) {
    if (img == null) return const SizedBox.shrink();

    // If it's already bytes
    if (img is Uint8List) {
      return Image.memory(img, width: double.infinity, fit: BoxFit.cover);
    }

    // If it's a String that might be a url or data URI
    if (img is String) {
      final s = img.trim();
      // data URI: data:image/png;base64,....
      if (s.startsWith('data:')) {
        final parts = s.split(',');
        if (parts.length == 2) {
          try {
            final bytes = base64Decode(parts[1]);
            return Image.memory(bytes, width: double.infinity, fit: BoxFit.cover);
          } catch (_) {
            // fallback to network below
          }
        }
      }

      // For normal URLs, ensure it's valid-ish
      if (s.startsWith('http') || s.startsWith('https')) {
        return Image.network(s, width: double.infinity, fit: BoxFit.cover);
      }

      // As a fallback, try network with the string representation
      return Image.network(s, width: double.infinity, fit: BoxFit.cover);
    }

    // Unknown type: show placeholder
    return Container(
      width: double.infinity,
      height: 160,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.black26),
    );
  }

  Widget _safeSvgAsset(String assetName, {double width = 22}) {
    try {
      // If asset is missing this can throw at runtime; wrap it
      return SvgPicture.asset(assetName, width: width);
    } catch (_) {
      // fallback to a simple icon if SVG fails to load
      return Icon(Icons.favorite_border, size: width);
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = _posts;
    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text("No recent posts yet", style: TextStyle(color: Colors.grey))),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Recent Posts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink)),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final post = posts[i] ?? <String, dynamic>{};
            final postId = (post['id'] is int) ? post['id'] as int : int.tryParse('${post['id']}') ?? 0;
            final images = post['images'] is List ? List<dynamic>.from(post['images']) : <dynamic>[];
            final img = images.isNotEmpty ? images[0] : null;
            final desc = (post['description'] ?? '') as String;
            final likes = (post['likes'] ?? 0) is int ? (post['likes'] ?? 0) as int : int.tryParse('${post['likes'] ?? 0}') ?? 0;
            final bookmarks = (post['bookmarks'] ?? 0) is int ? (post['bookmarks'] ?? 0) as int : int.tryParse('${post['bookmarks'] ?? 0}') ?? 0;
            final isLiked = UserActionsStore.isLiked(postId);
            final isBookmarked = UserActionsStore.isBookmarked(postId);
            final tagsRaw = post['tags'];
            final tags = (tagsRaw is Iterable) ? List<String>.from(tagsRaw.map((e) => e?.toString() ?? '')) : <String>[];

            return GestureDetector(
              onTap: () => widget.onOpenPost?.call(post),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // image (guarded)
                  if (img != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: _buildImage(img),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (desc.isNotEmpty) Text(desc, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      if (tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: tags.map((t) {
                            final label = (t ?? '').toString();
                            if (label.isEmpty) return const SizedBox.shrink();
                            return Chip(label: Text(label, style: const TextStyle(fontSize: 11)), backgroundColor: Colors.pink.shade50);
                          }).toList(),
                        ),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        InkWell(
                          onTap: () {
                            if (postId > 0) _toggleLike(postId);
                          },
                          child: Row(children: [
                            AnimatedScale(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.elasticOut,
                                scale: isLiked ? 1.2 : 1.0,
                                child: _safeSvgAsset(isLiked ? 'assets/likediconheart.svg' : 'assets/unlikeiconheart.svg', width: 22)),
                            const SizedBox(width: 6),
                            Text('$likes'),
                          ]),
                        ),
                        InkWell(
                          onTap: () {
                            if (postId > 0) _toggleBookmark(postId);
                          },
                          child: Row(children: [
                            AnimatedScale(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.elasticOut,
                                scale: isBookmarked ? 1.2 : 1.0,
                                child: _safeSvgAsset('assets/bookmark.svg', width: 22)),
                            const SizedBox(width: 6),
                            Text('$bookmarks'),
                          ]),
                        ),
                      ]),
                    ]),
                  ),
                ]),
              ),
            );
          },
        ),
      ]),
    );
  }
}
