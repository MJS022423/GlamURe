// lib/homepage-modules/create_post_components/create_post_image_picker.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostImagePicker extends StatefulWidget {
  final Uint8List? initialImage;
  final void Function(Uint8List bytes) onPick;
  final VoidCallback onRemove;

  const CreatePostImagePicker({super.key, required this.onPick, required this.onRemove, this.initialImage});

  @override
  State<CreatePostImagePicker> createState() => _CreatePostImagePickerState();
}

class _CreatePostImagePickerState extends State<CreatePostImagePicker> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _preview;

  @override
  void initState() {
    super.initState();
    _preview = widget.initialImage;
  }

  Future<void> _pick() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => _preview = bytes);
      widget.onPick(bytes);
    }
  }

  void _remove() {
    setState(() => _preview = null);
    widget.onRemove();
  }

  @override
  void didUpdateWidget(covariant CreatePostImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImage != oldWidget.initialImage) {
      setState(() => _preview = widget.initialImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ElevatedButton.icon(
        onPressed: _pick,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(_preview == null ? 'Add Image' : 'Change Image'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
      ),
      const SizedBox(width: 12),
      if (_preview != null)
        GestureDetector(
          onTap: () {
            // fullscreen preview dialog
            showDialog(
              context: context,
              builder: (_) => Dialog(
                child: Stack(children: [
                  Image.memory(_preview!),
                  Positioned(top: 8, left: 8, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
                ]),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(width: 80, height: 80, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: MemoryImage(_preview!), fit: BoxFit.cover))),
              GestureDetector(
                onTap: _remove,
                child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle), child: const Icon(Icons.close, size: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
    ]);
  }
}
