import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';

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
  Uint8List? selectedImageBytes;
  String? selectedImageName;
  bool showTags = false;
  List<String> selectedTags = [];
  bool zoomImage = false;

  void pickImage() {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      final file = files[0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
        setState(() {
          selectedImageBytes = reader.result as Uint8List;
          selectedImageName = file.name;
        });
      });
    });
  }

  void removeImage() {
    setState(() {
      selectedImageBytes = null;
      selectedImageName = null;
    });
  }

  void toggleTag(String category, String tag) {
    setState(() {
      final categoryTags = sampleTags[category]!;
      final isExclusive = ['Gender'].contains(category);
      selectedTags.removeWhere((t) => categoryTags.contains(t));
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
  }

  void handleUpload() {
    if (selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must add an image to post.')),
      );
      return;
    }

    final newPost = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'username': 'Jzar Alaba',
      'description': descriptionController.text,
      'images': [selectedImageName],
      'tags': selectedTags,
      'gender': selectedTags.firstWhere((t) => sampleTags['Gender']!.contains(t), orElse: () => 'Unisex'),
      'style': selectedTags.firstWhere((t) => sampleTags['Style']!.contains(t), orElse: () => 'Casual'),
      'likes': 0,
      'comments': [],
      'createdAt': DateTime.now().toIso8601String(),
    };

    widget.addPost(newPost);

    descriptionController.clear();
    setState(() {
      selectedImageBytes = null;
      selectedImageName = null;
      selectedTags = [];
      showTags = false;
      zoomImage = false;
    });

    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;

    return Center(
      child: Stack(
        children: [
          // Background overlay
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Main card
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create Post',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // User info
                    Row(
                      children: const [
                        CircleAvatar(child: Text('👤')),
                        SizedBox(width: 8),
                        Text('Jzar Alaba', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

                    // Buttons grid
                    Column(
                      children: [
                        // Add Image row
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: pickImage,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                backgroundColor: Colors.blue,
                              ),
                              child: Text(selectedImageBytes == null ? '+ Add Image' : 'Change Image'),
                            ),
                            const SizedBox(width: 8),
                            if (selectedImageBytes != null)
                              GestureDetector(
                                onTap: () => setState(() => zoomImage = true),
                                child: Container(
                                  width: 60,
                                  height: 60,
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

                        const SizedBox(height: 12),

                        // Add Tags row
                        Row(
                          children: [
                            if (!showTags)
                              ElevatedButton(
                                onPressed: () => setState(() => showTags = true),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text('+ Add Tags'),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Tags expanded section
                        if (showTags)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Minimize button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => setState(() => showTags = false),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    label: const Text('Tags'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Tags list
                              ...sampleTags.entries.map((entry) {
                                final category = entry.key;
                                final tags = entry.value;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: tags.map((tag) {
                                        final isSelected = selectedTags.contains(tag);
                                        return ElevatedButton(
                                          onPressed: () => toggleTag(category, tag),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                                            foregroundColor: isSelected ? Colors.white : Colors.black,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          child: Text(tag),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Upload button
                    ElevatedButton(
                      onPressed: selectedImageBytes == null ? null : handleUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedImageBytes == null ? Colors.grey : Colors.black,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Upload Post', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Zoomed image
          if (zoomImage && selectedImageBytes != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.9),
                child: Stack(
                  children: [
                    Center(child: Image.memory(selectedImageBytes!)),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: ElevatedButton(
                        onPressed: () => setState(() => zoomImage = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
