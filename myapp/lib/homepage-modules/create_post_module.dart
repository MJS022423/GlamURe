import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';

const sampleTags = {
  'Gender': ['Men', 'Women', 'Unisex'],
  'Style': [
    'Casual', 'Formal', 'Streetwear', 'Luxury', 'Minimalist', 'Bohemian',
    'Athletic', 'Trendy', 'Classic', 'Edgy', 'Elegant', 'Modern', 'Chic',
    'Urban', 'Designer', 'Fashionista'
  ],
  'Occasion': ['Everyday', 'Workwear', 'Partywear', 'Outdoor', 'Seasonal', 'Special Event'],
  'Material': ['Cotton', 'Denim', 'Leather', 'Silk', 'Wool', 'Linen', 'Synthetic', 'Eco-Friendly', 'Sustainable'],
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
  XFile? selectedImageFile;
  Uint8List? selectedImageBytes;
  bool showTags = false;
  List<String> selectedTags = [];

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

  void toggleTag(String category, String tag) {
    setState(() {
      final categoryTags = sampleTags[category]!;
      final isExclusive = ['Gender'].contains(category);
      if (isExclusive) selectedTags.removeWhere((t) => categoryTags.contains(t));
      if (selectedTags.contains(tag)) {
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

    final newPost = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'username': 'Jzar Alaba',
      'description': descriptionController.text,
      'images': [selectedImageBytes!], // store Uint8List directly
      'tags': selectedTags,
      'gender': selectedTags.firstWhere(
          (t) => sampleTags['Gender']!.contains(t),
          orElse: () => 'Unisex'),
      'style': selectedTags.firstWhere(
          (t) => sampleTags['Style']!.contains(t),
          orElse: () => 'Casual'),
      'likes': 0,
      'comments': [],
      'createdAt': DateTime.now().toIso8601String(),
    };

    widget.addPost(newPost);

    descriptionController.clear();
    setState(() {
      selectedImageBytes = null;
      selectedImageFile = null;
      selectedTags = [];
      showTags = false;
    });

    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: widget.onClose,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // User info
                      Row(
                        children: const [
                          CircleAvatar(child: Text('👤')),
                          SizedBox(width: 8),
                          Text('Jzar Alaba',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Description input
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

                      // Buttons + small image preview
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
                                            icon: const Icon(Icons.arrow_back,
                                                color: Colors.white),
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

                      // Tags section
                      if (showTags)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...sampleTags.entries.map((entry) {
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
                                          textColor:
                                              isSelected ? Colors.white : Colors.black,
                                          shape: GFButtonShape.pills,
                                          size: GFSize.SMALL,
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Upload button
                      GFButton(
                        onPressed:
                            selectedImageBytes == null ? null : handleUpload,
                        text: 'Upload Post',
                        fullWidthButton: true,
                        color: selectedImageBytes == null ? Colors.grey : Colors.black,
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
