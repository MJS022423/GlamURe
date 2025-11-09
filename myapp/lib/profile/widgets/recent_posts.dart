// lib/profile/widgets/recent_posts.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/post_store.dart';
import '../../data/user_actions_store.dart';
import '../../data/account_store.dart';

class RecentPosts extends StatefulWidget {
  final void Function(Map<String, dynamic> post)? onOpenPost;
  final VoidCallback? onChanged;

  const RecentPosts({super.key, this.onOpenPost, this.onChanged});

  @override
  State<RecentPosts> createState() => _RecentPostsState();
}

class _RecentPostsState extends State<RecentPosts> {
  List<Map<String, dynamic>> get _posts {
    final currentUsername =
        AccountStore.currentUsername ?? AccountStore.currentUser?['username'];
    return currentUsername != null
        ? PostStore.getPostsByUser(currentUsername)
        : <Map<String, dynamic>>[];
  }

  void _toggleLike(int postId) {
    final isLiked = UserActionsStore.isLiked(postId);
    UserActionsStore.toggleLike(postId, !isLiked); // ✅ now passes bool
    setState(() {});
    widget.onChanged?.call();
  }

  void _toggleBookmark(int postId) {
    final isBookmarked = UserActionsStore.isBookmarked(postId);
    UserActionsStore.toggleBookmark(postId, !isBookmarked); // ✅ now passes bool
    setState(() {});
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final posts = _posts;
    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
            child: Text("No recent posts yet",
                style: TextStyle(color: Colors.grey))),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Recent Posts",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink)),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final post = posts[i];
            final postId = post['id'] as int;
            final img = post['images'][0];
            final desc = post['description'] ?? '';
            final likes = (post['likes'] ?? 0) as int;
            final bookmarks = (post['bookmarks'] ?? 0) as int;
            final isLiked = UserActionsStore.isLiked(postId);
            final isBookmarked = UserActionsStore.isBookmarked(postId);
            final tags = List<String>.from(post['tags'] ?? []);

            return GestureDetector(
              onTap: () => widget.onOpenPost?.call(post),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ]),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (img != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14)),
                          child: img is Uint8List
                              ? Image.memory(img,
                                  width: double.infinity, fit: BoxFit.cover)
                              : Image.network(img,
                                  width: double.infinity, fit: BoxFit.cover),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (desc.isNotEmpty)
                                Text(desc,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: tags
                                      .map((t) => Chip(
                                            label: Text(t,
                                                style: const TextStyle(
                                                    fontSize: 11)),
                                            backgroundColor:
                                                Colors.pink.shade50,
                                          ))
                                      .toList()),
                              const SizedBox(height: 8),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () => _toggleLike(postId),
                                      child: Row(children: [
                                        AnimatedScale(
                                            duration: const Duration(
                                                milliseconds: 220),
                                            curve: Curves.elasticOut,
                                            scale: isLiked ? 1.2 : 1.0,
                                            child: SvgPicture.asset(
                                                isLiked
                                                    ? 'assets/likediconheart.svg'
                                                    : 'assets/unlikeiconheart.svg',
                                                width: 22)),
                                        const SizedBox(width: 6),
                                        Text('$likes'),
                                      ]),
                                    ),
                                    InkWell(
                                      onTap: () => _toggleBookmark(postId),
                                      child: Row(children: [
                                        AnimatedScale(
                                            duration: const Duration(
                                                milliseconds: 220),
                                            curve: Curves.elasticOut,
                                            scale:
                                                isBookmarked ? 1.2 : 1.0,
                                            child: SvgPicture.asset(
                                              'assets/bookmark.svg',
                                              width: 22,
                                              colorFilter: ColorFilter.mode(
                                                isBookmarked
                                                    ? Colors.pinkAccent
                                                    : Colors.black54,
                                                BlendMode.srcIn,
                                              ),
                                            )),
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
