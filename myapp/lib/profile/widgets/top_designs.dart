// lib/profile/widgets/top_designs.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/post_store.dart';
import '../../data/account_store.dart';

class TopDesigns extends StatelessWidget {
  final Map<String, dynamic>? owner; // optional owner to filter by
  final void Function(Map<String, dynamic> post)? onOpenPost;

  const TopDesigns({super.key, this.onOpenPost, this.owner});

  String? _usernameFromOwner(Map<String, dynamic>? owner) {
    if (owner == null) return null;
    return (owner['username'] ?? owner['handle'] ?? owner['authorUsername'] ?? owner['name'])?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final ownerUsername = _usernameFromOwner(owner);

    final currentUsername = ownerUsername ?? (AccountStore.currentUsername ?? AccountStore.currentUser?['username']);
    final userPosts = currentUsername != null
        ? PostStore.getPostsByUser(currentUsername)
        : <Map<String, dynamic>>[];

    if (userPosts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: Text("No designs yet", style: TextStyle(color: Colors.grey))),
      );
    }

    final sorted = [...userPosts];
    sorted.sort((a, b) => ((b['likes'] ?? 0) as int).compareTo(((a['likes'] ?? 0) as int)));
    final take = sorted.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Text("Top 3 Designs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink)),
          SizedBox(width: 6),
          Text("🔥", style: TextStyle(fontSize: 18))
        ]),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: take.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final p = take[i];
              final img = (p['images'] is List && p['images'].isNotEmpty) ? p['images'][0] : null;
              return GestureDetector(
                onTap: () => onOpenPost?.call(p),
                child: Container(
                  width: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0,4))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: img != null
                        ? (img is Uint8List ? Image.memory(img, fit: BoxFit.cover) : Image.network(img, fit: BoxFit.cover))
                        : const SizedBox.shrink(),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
