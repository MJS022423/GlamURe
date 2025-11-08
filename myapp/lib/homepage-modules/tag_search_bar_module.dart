import 'package:flutter/material.dart';

const sampleTags = [
  'Men', 'Women', 'Unisex',
  'Casual', 'Formal', 'Streetwear', 'Luxury', 'Minimalist', 'Bohemian',
  'Athletic', 'Trendy', 'Classic', 'Edgy', 'Elegant', 'Modern', 'Chic',
  'Urban', 'Designer', 'Fashionista'
];

class TagSearchBarModule extends StatefulWidget {
  final Function(List<String>) onSearch;

  const TagSearchBarModule({super.key, required this.onSearch});

  @override
  State<TagSearchBarModule> createState() => _TagSearchBarModuleState();
}

class _TagSearchBarModuleState extends State<TagSearchBarModule> {
  final TextEditingController controller = TextEditingController();
  List<String> selectedTags = [];

  void handleTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
      widget.onSearch(selectedTags);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search tags...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  setState(() => selectedTags.clear());
                  widget.onSearch([]);
                },
              )
            : null,
      ),
      onChanged: (value) {
        // For simplicity, filtering could be improved
        setState(() {
          // you could filter sampleTags based on input if needed
        });
      },
    );
  }
}
