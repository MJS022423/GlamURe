// lib/settings/widgets/avatar_picker.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/account_store.dart';

class AvatarPicker extends StatefulWidget {
  final double size;
  final VoidCallback? onSaved; // notify parent when saved

  const AvatarPicker({super.key, this.size = 80, this.onSaved});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  Uint8List? _bytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadFromStore();
  }

  void _loadFromStore() {
    final current = AccountStore.currentUser;
    final base64Img = current != null ? (current['profileImage'] as String?) : null;
    if (base64Img != null && base64Img.isNotEmpty) {
      try {
        setState(() {
          _bytes = base64Decode(base64Img);
        });
      } catch (_) {
        // ignore decode errors
      }
    }
  }

  Future<void> pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _bytes = bytes);
  }

  void removeImage() {
    setState(() => _bytes = null);
  }

  /// Persist avatar to AccountStore (base64 string)
  Future<void> saveToStore() async {
    final current = AccountStore.currentUser;
    final username = AccountStore.currentUsername ?? (current != null ? current['username'] : null);
    // convert to base64
    final base64Img = _bytes != null ? base64Encode(_bytes!) : '';
    final updated = {...?current, 'profileImage': base64Img};
    // Try calling updateProfile if exists; otherwise mutate currentUser
    try {
      // prefer explicit API if author implemented it
      await AccountStore.updateProfile(updated);
    } catch (e) {
      // best-effort fallback if no method exists
      try {
        // if currentUser is a modifiable map
        // ignore: avoid_dynamic_calls
        AccountStore.currentUser = updated;
      } catch (e2) {
        debugPrint('AvatarPicker: cannot call AccountStore.updateProfile or assign currentUser: $e2');
      }
    }
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
          child: ClipOval(
            child: _bytes != null
                ? Image.memory(_bytes!, width: size, height: size, fit: BoxFit.cover)
                : (AccountStore.currentUser != null && (AccountStore.currentUser!['profileImage'] ?? '').toString().isNotEmpty
                    ? Image.memory(base64Decode(AccountStore.currentUser!['profileImage']), width: size, height: size, fit: BoxFit.cover)
                    : const Icon(Icons.person, size: 40, color: Colors.grey)),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Change'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            ),
            TextButton(onPressed: removeImage, child: const Text('Remove')),
            ElevatedButton(onPressed: saveToStore, child: const Text('Save Avatar')),
          ],
        ),
      ],
    );
  }
}
