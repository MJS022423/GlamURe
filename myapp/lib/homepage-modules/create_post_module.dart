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
  'Features': ['Comfortable', 'Layered', 'Textured', 'Statement', 'Soft', 'Versatile', 'Functional'],
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
  List<Map<String, dynamic>> selectedImages = [];
  List<String> selectedTags = [];
  bool showTags = false;

  void toggleTag(String category, String tag) {
    setState(() {
      final categoryTags = sampleTags[category]!;
      final isExclusive = category == 'Gender';
      // Remove existing tags in this category
      selectedTags = selectedTags.where((t) => !categoryTags.contains(t)).toList();

      if (!selectedTags.contains(tag)) {
        selectedTags.add(tag);
      }
    });
  }

  void handleUpload() {
    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one image to post")),
      );
      return;
    }

    final newPost = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'username': 'Jzar Alaba',
      'description': descriptionController.text,
      'images': selectedImages.map((img) => img['preview']).toList(),
      'tags': selectedTags,
      'gender': selectedTags.firstWhere((t) => sampleTags['Gender']!.contains(t), orElse: () => 'Unisex'),
      'style': selectedTags.firstWhere((t) => sampleTags['Style']!.contains(t), orElse: () => 'Casual'),
      'likes': 0,
      'comments': [],
      'createdAt': DateTime.now().toIso8601String(),
    };

    widget.addPost(newPost);

    // Reset everything
    descriptionController.clear();
    selectedImages.clear();
    selectedTags.clear();
    widget.onClose();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.9;
    final height = MediaQuery.of(context).size.height * 0.7;

    return Stack(
      children: [
        // Dark overlay background
        GestureDetector(
          onTap: widget.onClose,
          child: Container(color: Colors.black54),
        ),

        // Centered Card
        Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Material(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  // Header with Close button
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Create Post",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 28),
                          onPressed: widget.onClose,
                        )
                      ],
                    ),
                  ),

                  // Description input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Add Images button
                  TextButton(
                    onPressed: () {}, // Implement file picker here later
                    child: const Text("+ Add Images"),
                  ),

                  // Show Tags selection
                  TextButton(
                    onPressed: () => setState(() => showTags = !showTags),
                    child: const Text("+ Tags"),
                  ),

                  if (showTags)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: sampleTags.entries.map((entry) {
                            final category = entry.key;
                            final tags = entry.value;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(category,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Wrap(
                                    spacing: 6,
                                    children: tags.map((tag) {
                                      final selected = selectedTags.contains(tag);
                                      return ChoiceChip(
                                        label: Text(tag),
                                        selected: selected,
                                        onSelected: (_) =>
                                            toggleTag(category, tag),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Upload Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ElevatedButton(
                      onPressed: handleUpload,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Upload Post"),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
