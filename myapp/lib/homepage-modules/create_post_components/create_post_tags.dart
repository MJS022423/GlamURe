// lib/homepage-modules/create_post_components/create_post_tags.dart
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class CreatePostTags extends StatelessWidget {
  final Map<String, List<String>> sampleTags;
  final List<String> selectedTags;
  final void Function(String category, String tag) onToggle;

  const CreatePostTags({super.key, required this.sampleTags, required this.selectedTags, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sampleTags.entries.map((entry) {
        final category = entry.key;
        final tags = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                final isSelected = selectedTags.contains(tag);
                return GFButton(
                  onPressed: () => onToggle(category, tag),
                  text: tag,
                  type: isSelected ? GFButtonType.solid : GFButtonType.outline,
                  color: Colors.blue,
                  textColor: isSelected ? Colors.white : Colors.black,
                  shape: GFButtonShape.pills,
                  size: GFSize.SMALL,
                );
              }).toList(),
            ),
          ]),
        );
      }).toList(),
    );
  }
}
