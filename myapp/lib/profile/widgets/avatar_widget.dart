// lib/profile/widgets/avatar_widget.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/account_store.dart';

class AvatarWidget extends StatelessWidget {
  final double size;
  const AvatarWidget({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final current = AccountStore.currentUser;
    final profileBase64 = current?['profileImage'] as String?;
    if (profileBase64 != null && profileBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(profileBase64);
        return ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover),
        );
      } catch (_) {
        // fall through to fallback
      }
    }

    final username = current?['username'] ?? '';
    final displayName = current?['displayName'] ?? '';
    final letter = (displayName.toString().isNotEmpty ? displayName.toString()[0] : (username.toString().isNotEmpty ? username.toString()[0] : '?')).toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFACED9)),
      alignment: Alignment.center,
      child: Text(letter, style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }
}
