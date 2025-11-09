// myapp/lib/homepage-modules/create_post_module.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import '../data/post_store.dart';
import '../data/account_store.dart'; // <- use current username

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
  'Occasion': [
    'Everyday',
    'Workwear',
    'Partywear',
    'Outdoor',
    'Seasonal',
    'Special Event'
  ],
  'Material': [
    'Cotton',
    'Denim',
    'Leather',
    'Silk',
    'Wool',
    'Linen',
    'Synthetic',
    'Eco-Friendly',
    'Sustainable'
  ],
  'Color': [
    'Monochrome',
    'Colorful',
    'Neutral',
    'Pastel',
    'Bold',
    'Patterned'
  ],
  'Accessories': [
    'Footwear',
    'Bags',
    'Jewelry',
    'Hats',
    'Belts',
    'Scarves',
    'Sunglasses'
  ],
  'Features': [
    'Comfortable',
    'Layered',
    'Textured',
    'Statement',
    'Soft',
    'Versatile',
    'Functional'
  ]
};

class CreatePostModule extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) addPost;

  const CreatePostModule({
    super.key,
    required this.onClose,
    required this.addPost,
  });

  @override
  State<CreatePostModule> createState() => _CreatePostModuleState();
}

class _CreatePostModuleState extends State<CreatePostModule> {
  final TextEditingController descriptionController = TextEditingController();
  XFile? selectedImageFile;
  Uint8List? selectedImageBytes;
  bool showTags = false;

  List<String> selectedTags = ['Men', 'Casual'];
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        selectedImageFile = image;
        selectedImageBytes = bytes;
      });
    }
  }

  void removeImage() {
    setState(() {
      selectedImageFile = null;
      selectedImageBytes = null;
    });
  }

  int _selectedStyleCount() {
    final styleSet = sampleTags['Style']!.map((s) => s.toLowerCase()).toSet();
    return selectedTags.where((t) => styleSet.contains(t.toLowerCase())).length;
  }

  void toggleTag(String category, String tag) {
    setState(() {
      final categoryTags = sampleTags[category] ?? [];
      final isGenderExclusive = category == 'Gender';
      final isStyleCategory = category == 'Style';

      if (isGenderExclusive) {
        selectedTags.removeWhere((t) => categoryTags.contains(t));
      }

      final alreadySelected = selectedTags.contains(tag);
      if (alreadySelected) {
        if (category == 'Gender' && tag == 'Men') {
          final otherGenderSelected = selectedTags.any((t) =>
              t != 'Men' && (sampleTags['Gender'] ?? []).contains(t));
          if (!otherGenderSelected) return;
        }

        if (isStyleCategory && tag == 'Casual') {
          final styleCount = _selectedStyleCount();
          if (styleCount <= 2) return;
        }
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
  }

  void handleUpload() {
    if (selectedImageBytes == null) {
      GFToast.showToast('You must add an image to post.', context);
      return;
    }

    // Normalize tags
    final seen = <String>{};
    final normalizedTags = <String>[];
    for (final t in selectedTags) {
      final trimmed = t.trim();
      final key = trimmed.toLowerCase();
      if (trimmed.isNotEmpty && !seen.contains(key)) {
        seen.add(key);
        normalizedTags.add(trimmed);
      }
    }

    final genderValue = normalizedTags.firstWhere(
      (t) => sampleTags['Gender']!
          .map((e) => e.toLowerCase())
          .contains(t.toLowerCase()),
      orElse: () => 'Unisex',
    );

    final styleValue = normalizedTags.firstWhere(
      (t) => sampleTags['Style']!
          .map((e) => e.toLowerCase())
          .contains(t.toLowerCase()),
      orElse: () => 'Casual',
    );

    // Use actual logged-in username if available
    final creatorUsername = AccountStore.currentUsername ??
        (AccountStore.currentUser != null ? AccountStore.currentUser!['username'] : 'Designer');

    final newPost = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'username': creatorUsername,
      'description': descriptionController.text.trim(),
      'images': [selectedImageBytes!],
      'tags': normalizedTags,
      'gender': genderValue,
      'style': styleValue,
      'likes': 0,
      'bookmarks': 0,
      'comments': [],
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Add only once globally
    PostStore.addPost(newPost);

    // Notify parent (UI refresh)
    widget.addPost(newPost);

    // Reset fields
    descriptionController.clear();
    setState(() {
      selectedImageBytes = null;
      selectedImageFile = null;
      selectedTags = ['Men', 'Casual'];
      showTags = false;
    });

    GFToast.showToast('Post uploaded successfully!', context,
        backgroundColor: Colors.green,
        textStyle: const TextStyle(color: Colors.white));

    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: GFCard(
                elevation: 8,
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Create Post',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: widget.onClose,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Show current username if available
                      Row(
                        children: [
                          const CircleAvatar(child: Text('👤')),
                          const SizedBox(width: 8),
                          Text(
                            AccountStore.currentUsername ??
                                (AccountStore.currentUser != null ? AccountStore.currentUser!['username'] : 'Designer'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Description
                      TextField(
                        controller: descriptionController,
                        maxLength: 100,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "What's on your mind?",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                GFButton(
                                  onPressed: pickImage,
                                  text: selectedImageBytes == null
                                      ? '+ Add Image'
                                      : 'Change Image',
                                  type: GFButtonType.outline,
                                  color: Colors.blue,
                                  shape: GFButtonShape.pills,
                                ),
                                const SizedBox(height: 8),
                                GFButton(
                                  onPressed: () =>
                                      setState(() => showTags = !showTags),
                                  text: showTags ? '- Tags' : '+ Tags',
                                  type: GFButtonType.outline,
                                  color: Colors.blue,
                                  shape: GFButtonShape.pills,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (selectedImageBytes != null)
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    child: Stack(
                                      children: [
                                        Image.memory(selectedImageBytes!),
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.arrow_back,
                                              color: Colors.white,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: MemoryImage(selectedImageBytes!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      if (showTags)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: sampleTags.entries.map((entry) {
                              final category = entry.key;
                              final tags = entry.value;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(category,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: tags.map((tag) {
                                      final isSelected =
                                          selectedTags.contains(tag);
                                      return GFButton(
                                        onPressed: () =>
                                            toggleTag(category, tag),
                                        text: tag,
                                        type: isSelected
                                            ? GFButtonType.solid
                                            : GFButtonType.outline,
                                        color: Colors.blue,
                                        textColor: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        shape: GFButtonShape.pills,
                                        size: GFSize.SMALL,
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 12),

                      GFButton(
                        onPressed:
                            selectedImageBytes == null ? null : handleUpload,
                        text: 'Upload Post',
                        fullWidthButton: true,
                        color: selectedImageBytes == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
