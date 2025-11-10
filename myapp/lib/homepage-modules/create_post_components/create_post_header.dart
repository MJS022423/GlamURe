// lib/homepage-modules/create_post_components/create_post_header.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/account_store.dart';

class CreatePostHeader extends StatelessWidget {
  final VoidCallback onClose;
  final String username;

  const CreatePostHeader({super.key, required this.onClose, required this.username});

  Widget _buildAvatar(double size) {
    final current = AccountStore.currentUser;
    final base64Img = current != null ? (current['profileImage'] as String?) : null;
    if (base64Img != null && base64Img.isNotEmpty) {
      try {
        final bytes = base64Decode(base64Img);
        return ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover),
        );
      } catch (_) {}
    }

    final displayName = current != null ? (current['displayName'] ?? '') : '';
    final letter = (displayName.isNotEmpty ? displayName[0] : (username.isNotEmpty ? username[0] : '?')).toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFACED9)),
      alignment: Alignment.center,
      child: Text(letter, style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          _buildAvatar(44),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (AccountStore.currentUser != null)
              Text(
                (AccountStore.currentUser!['email'] ?? '').toString(),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
          ]),
        ]),
        IconButton(icon: const Icon(Icons.close), onPressed: onClose),
      ],
    );
  }
}
