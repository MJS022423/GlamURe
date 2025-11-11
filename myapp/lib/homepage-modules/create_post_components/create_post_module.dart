// lib/homepage-modules/create_post_module.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

import '../../data/post_store.dart';
import '../../data/account_store.dart';

import 'create_post_header.dart';
import 'create_post_image_picker.dart';
import 'create_post_tags.dart';

const sampleTags = {
  'Gender': ['Men', 'Women', 'Unisex'],
  'Style': [
    'Casual',
    'Formal',
    'Streetwear',
    'Luxury',
    'Minimalist',
    'Bohemian',
    'Athletic',
    'Trendy',
    'Classic',
    'Edgy',
    'Elegant',
    'Modern',
    'Chic',
    'Urban',
    'Designer',
    'Fashionista'
  ],
  'Occasion': ['Everyday', 'Workwear', 'Partywear', 'Outdoor', 'Seasonal', 'Special Event'],
  'Material': ['Cotton', 'Denim', 'Leather', 'Silk', 'Wool', 'Linen', 'Synthetic', 'Eco-Friendly'],
  'Color': ['Monochrome', 'Colorful', 'Neutral', 'Pastel', 'Bold', 'Patterned'],
  'Accessories': ['Footwear', 'Bags', 'Jewelry', 'Hats', 'Belts', 'Scarves', 'Sunglasses'],
  'Features': ['Comfortable', 'Layered', 'Textured', 'Statement', 'Soft', 'Versatile', 'Functional']
};

class CreatePostModule extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) addPost;

  const CreatePostModule({super.key, required this.onClose, required this.addPost});

  @override
  State<CreatePostModule> createState() => _CreatePostModuleState();
}

class _CreatePostModuleState extends State<CreatePostModule> {
  final TextEditingController descriptionController = TextEditingController();

  Uint8List? selectedImageBytes;
  List<String> selectedTags = ['Men', 'Casual'];
  bool showTags = false;

  // Called by image picker child
  void _onImagePicked(Uint8List bytes) {
    setState(() {
      selectedImageBytes = bytes;
    });
  }

  void _onImageRemoved() {
    setState(() {
      selectedImageBytes = null;
    });
  }

  void _toggleTag(String category, String tag) {
    setState(() {
      final categoryTags = (sampleTags[category] ?? []);
      final isGenderExclusive = category == 'Gender';
      final isStyleCategory = category == 'Style';

      if (isGenderExclusive) {
        // keep only one gender
        selectedTags.removeWhere((t) => categoryTags.contains(t));
      }

      final already = selectedTags.contains(tag);
      if (already) {
        // some simple guards from your original logic
        if (category == 'Gender' && tag == 'Men') {
          final otherGenderSelected = selectedTags.any((t) =>
              t != 'Men' && (sampleTags['Gender'] ?? []).contains(t));
          if (!otherGenderSelected) return;
        }
        if (isStyleCategory && tag == 'Casual') {
          final styleSet = sampleTags['Style']!.map((s) => s.toLowerCase()).toSet();
          final styleCount = selectedTags.where((t) => styleSet.contains(t.toLowerCase())).length;
          if (styleCount <= 2) return;
        }
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
  }

  void _handleUpload() {
    if (selectedImageBytes == null) {
      GFToast.showToast('You must add an image to post.', context);
      return;
    }

    // normalize tags
    final seen = <String>{};
    final normalized = <String>[];
    for (final t in selectedTags) {
      final key = t.trim().toLowerCase();
      if (key.isEmpty) continue;
      if (!seen.contains(key)) {
        seen.add(key);
        normalized.add(t.trim());
      }
    }

    final genderValue = normalized.firstWhere(
      (t) => sampleTags['Gender']!.map((e) => e.toLowerCase()).contains(t.toLowerCase()),
      orElse: () => 'Unisex',
    );

    final styleValue = normalized.firstWhere(
      (t) => sampleTags['Style']!.map((e) => e.toLowerCase()).contains(t.toLowerCase()),
      orElse: () => 'Casual',
    );

    final creatorUsername = AccountStore.currentUsername ??
        (AccountStore.currentUser != null ? AccountStore.currentUser!['username'] : 'Designer');

    final newPost = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'username': creatorUsername,
      'description': descriptionController.text.trim(),
      'images': [selectedImageBytes!],
      'tags': normalized,
      'gender': genderValue,
      'style': styleValue,
      'likes': 0,
      'bookmarks': 0,
      'comments': [],
      'createdAt': DateTime.now().toIso8601String(),
    };

    PostStore.addPost(newPost);
    widget.addPost(newPost);

    // reset
    descriptionController.clear();
    setState(() {
      selectedImageBytes = null;
      selectedTags = ['Men', 'Casual'];
      showTags = false;
    });

    GFToast.showToast('Post uploaded successfully!', context,
        backgroundColor: Colors.green, textStyle: const TextStyle(color: Colors.white));

    widget.onClose();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = AccountStore.currentUsername ??
        (AccountStore.currentUser != null ? AccountStore.currentUser!['username'] : 'Designer');

    return Center(
      child: Stack(
        children: [
          // dim background
          GestureDetector(onTap: widget.onClose, child: Container(color: Colors.black.withOpacity(0.5), width: double.infinity, height: double.infinity)),
          Center(
            child: SingleChildScrollView(
              child: GFCard(
                elevation: 8,
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // header (avatar + username + close)
                    CreatePostHeader(
                      onClose: widget.onClose,
                      username: username,
                    ),
                    const SizedBox(height: 8),

                    // Description
                    TextField(
                      controller: descriptionController,
                      maxLength: 100,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // image picker and preview
                    CreatePostImagePicker(
                      initialImage: selectedImageBytes,
                      onPick: _onImagePicked,
                      onRemove: _onImageRemoved,
                    ),
                    const SizedBox(height: 12),

                    // tags toggle
                    Row(children: [
                      Expanded(
                        child: GFButton(
                          onPressed: () => setState(() => showTags = !showTags),
                          text: showTags ? '- Tags' : '+ Tags',
                          type: GFButtonType.outline,
                          color: Colors.blue,
                          shape: GFButtonShape.pills,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GFButton(
                        onPressed: selectedImageBytes == null ? null : _handleUpload,
                        text: 'Upload Post',
                        fullWidthButton: false,
                        color: selectedImageBytes == null ? Colors.grey : Colors.black,
                      ),
                    ]),

                    if (showTags) const SizedBox(height: 12),
                    if (showTags)
                      CreatePostTags(
                        sampleTags: sampleTags,
                        selectedTags: selectedTags,
                        onToggle: _toggleTag,
                      ),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
