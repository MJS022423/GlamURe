// setupAccount.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SetupAccountPage extends StatefulWidget {
  final String? username;
  const SetupAccountPage({super.key, this.username});

  @override
  State<SetupAccountPage> createState() => _SetupAccountPageState();
}

class _SetupAccountPageState extends State<SetupAccountPage> {
  // === Toggle this to true while developing to bypass backend ===
  // Set to false for production, true for development

  static const bool devBypass = true;

  // Simple profanity list (expand as needed)
  bool _isVulgar(String name) {
    final vulgarWords = [
      "fuck",
      "shit",
      "bitch",
      "asshole",
      "dick",
      "pussy",
      "boobs",
      "cock",
      "penis",
      "vagina",
      "nipple",
      "tits",
      "fucker",
      "bastard"
    ];

    final lower = name.toLowerCase();
    return vulgarWords.any((word) => lower.contains(word));
  }

  final TextEditingController _displayNameController = TextEditingController();
  String? _gender;
  String? _userType;
  File? _profileImage;

  // Replace with your actual Express API URL when not bypassing.
  // For Android emulator use 10.0.2.2:3000, for iOS simulator 127.0.0.1:3000, etc.
  final String expressApi = const String.fromEnvironment(
    'VITE_EXPRESS_API',
    defaultValue: "http://localhost:3000",
  );

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        // On web this path is still usable by NetworkImage for preview.
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _handleSetup() async {
    String displayName = _displayNameController.text.trim();

    // VALIDATIONS
    if (displayName.isEmpty || _gender == null || _userType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // CHARACTER LIMIT
    if (displayName.length < 7 || displayName.length > 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name must be 7–15 characters long')),
      );
      return;
    }

    // VULGAR CHECK
    if (_isVulgar(displayName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name contains inappropriate language')),
      );
      return;
    }

    final username = widget.username ?? "unknown";

    try {
      // === DEV BYPASS: skip HTTP call and navigate straight to home ===
      if (devBypass) {
        debugPrint("🚧 Dev bypass enabled — skipping API call");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bypassing server (dev) — going to homepage...')),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
        return;
      }
      // === end bypass ===

      // Prepare image if present
      String? base64Image;
      if (_profileImage != null) {
        final bytes = await _profileImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      debugPrint("📤 Sending setup data to: $expressApi/auth/SetupAccount");

      final response = await http.post(
        Uri.parse('$expressApi/auth/SetupAccount'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'displayName': displayName,
          'gender': _gender,
          'role': _userType,
          'profileImage': base64Image
        }),
      );

      debugPrint("📥 Response ${response.statusCode}: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account setup complete!')),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Setup failed')),
        );
      }
    } catch (e) {
      debugPrint("❌ Setup error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server error. Please try again later.')),
      );
    }
  }

  Widget _buildSelectButton(String label, String? groupValue, void Function() onTap) {
    final bool isSelected = groupValue == label;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(50),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffb6c1), // pink background
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 4,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Setup Account",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 20),

                // Profile image with AnimatedSwitcher + tap handler
                GestureDetector(
                  onTap: _pickImage,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: CircleAvatar(
                      key: ValueKey(_profileImage?.path ?? 'no-image'),
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? (kIsWeb
                              ? NetworkImage(_profileImage!.path)
                              : FileImage(_profileImage!) as ImageProvider)
                          : null,
                      backgroundColor: Colors.grey[200],
                      child: _profileImage == null
                          ? const Icon(Icons.person, size: 50, color: Colors.black)
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    shadowColor: Colors.pinkAccent,
                  ),
                  child: const Text("Add Image", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 24),

                // Display name input
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: "Display Name",
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.purple, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Gender selection
                Row(
                  children: [
                    const Text("Gender:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildSelectButton("Male", _gender, () => setState(() => _gender = "Male")),
                    const SizedBox(width: 8),
                    _buildSelectButton("Female", _gender, () => setState(() => _gender = "Female")),
                  ],
                ),

                const SizedBox(height: 20),

                // User type selection
                Row(
                  children: [
                    const Text("User Type:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildSelectButton("Viewer", _userType, () => setState(() => _userType = "Viewer")),
                    const SizedBox(width: 8),
                    _buildSelectButton("Designer", _userType, () => setState(() => _userType = "Designer")),
                  ],
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _handleSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    shadowColor: Colors.pinkAccent,
                  ),
                  child: const Text("Setup", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
