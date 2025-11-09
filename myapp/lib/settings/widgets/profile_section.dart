// lib/settings/widgets/profile_section.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/account_store.dart';
import 'avatar_picker.dart';
import 'header_tile.dart';

class ProfileSection extends StatefulWidget {
  final bool expanded;
  final VoidCallback? onSaved;

  const ProfileSection({super.key, required this.expanded, this.onSaved});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _previewImageBytes;

  @override
  void initState() {
    super.initState();
    final current = AccountStore.getCurrentUserSnapshot();
    _nameController = TextEditingController(text: current != null ? (current['displayName'] ?? '') : '');
    _usernameController = TextEditingController(text: current != null ? (current['username'] ?? '') : '');
    _emailController = TextEditingController(text: current != null ? (current['email'] ?? '') : '');

    final base64 = current != null ? (current['profileImage'] as String?) : null;
    if (base64 != null && base64.isNotEmpty) {
      try {
        _previewImageBytes = base64Decode(base64);
      } catch (_) {}
    }
  }

  Future<void> _pickImageAndApply() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final b64 = base64Encode(bytes);

    final ok = AccountStore.setProfileImageBase64(b64);
    if (ok) {
      setState(() {
        _previewImageBytes = bytes;
      });
      widget.onSaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated'), backgroundColor: Colors.black));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save profile picture'), backgroundColor: Colors.red));
    }
  }

  Future<void> _saveProfile() async {
    final newDisplay = _nameController.text.trim();
    final newUsername = _usernameController.text.trim();
    final newEmail = _emailController.text.trim();

    // 1) change username (rename)
    if (newUsername.isNotEmpty && newUsername != AccountStore.currentUsername) {
      final err = AccountStore.changeUsername(newUsername);
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
        return;
      }
    }

    // 2) change email (validate)
    if (newEmail.isNotEmpty && newEmail != (AccountStore.currentUser?['email'] ?? '')) {
      final err = AccountStore.changeEmail(newEmail);
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
        return;
      }
    }

    // 3) update display name
    AccountStore.updateCurrentUser({'displayName': newDisplay});

    widget.onSaved?.call();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated'), backgroundColor: Colors.black));
    setState(() {}); // reflect new currentUser
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderTile(title: 'Profile Settings', icon: Icons.person_outline, expanded: widget.expanded),
        if (widget.expanded) const SizedBox(height: 12),
        if (widget.expanded)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar row with immediate apply
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _pickImageAndApply,
                              child: CircleAvatar(
                                radius: 38,
                                backgroundColor: const Color(0xFFFACED9),
                                child: _previewImageBytes != null
                                    ? ClipOval(child: Image.memory(_previewImageBytes!, width: 76, height: 76, fit: BoxFit.cover))
                                    : const Icon(Icons.person, size: 40, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _pickImageAndApply,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Change Photo'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text('Profile Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(controller: _nameController, decoration: InputDecoration(hintText: 'Display name', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
                        const SizedBox(height: 16),
                        const Text('Username', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(controller: _usernameController, decoration: InputDecoration(hintText: 'username', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
                        const SizedBox(height: 16),
                        const Text('Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(controller: _emailController, decoration: InputDecoration(hintText: 'email', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
                    child: ElevatedButton(onPressed: _saveProfile, style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: const Text('Save Profile Changes', style: TextStyle(fontWeight: FontWeight.w600))),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
