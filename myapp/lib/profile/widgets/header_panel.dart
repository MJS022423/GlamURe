// lib/profile/widgets/header_panel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/account_store.dart';
import 'avatar_widget.dart';

class HeaderPanel extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final VoidCallback onLogout;
  final VoidCallback? onCreatePost;

  const HeaderPanel({
    super.key,
    required this.fadeAnimation,
    required this.onLogout,
    this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    final current = AccountStore.currentUser;
    final username = (current != null ? (current['username'] ?? '') : '') as String;
    final displayName = (current != null && (current['displayName'] ?? '').toString().isNotEmpty)
        ? current['displayName'] as String
        : (username.isNotEmpty ? username : 'Designer');
    final email = current != null ? (current['email'] ?? '') as String : '';
    final role = current != null ? (current['role'] ?? 'N/A') as String : 'N/A';

    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        // overall header area
        color: const Color(0xfffde2e4),
        padding: const EdgeInsets.only(top: 12, bottom: 18),
        child: Column(
          children: [
            // top bar row (title area) - keeps the "PROFILE" bar spacing clean
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  const Spacer(),
                  // optional camera / create post icon (small)
                  if (onCreatePost != null)
                    IconButton(
                      onPressed: onCreatePost,
                      icon: const Icon(Icons.add_a_photo),
                      tooltip: 'Create post',
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') onLogout();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // center avatar
            AvatarWidget(size: 110),

            const SizedBox(height: 12),

            // display name
            Text(
              displayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // email below the displayname
            Text(
              email.isNotEmpty ? email : 'No email provided',
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 10),

            // role chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Role: ${role.toString()}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
