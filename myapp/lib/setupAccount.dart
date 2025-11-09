// myapp/lib/setupAccount.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'data/account_store.dart';

class SetupAccountPage extends StatefulWidget {
  final String? username;
  const SetupAccountPage({super.key, this.username});

  @override
  State<SetupAccountPage> createState() => _SetupAccountPageState();
}

class _SetupAccountPageState extends State<SetupAccountPage> {
  // toggle during development to skip a real backend call
  static const bool devBypass = true;

  final TextEditingController _displayNameController = TextEditingController();
  String? _gender;
  String? _userType;
  File? _profileImageFile;
  String? _profileImageBase64;
  final ImagePicker _picker = ImagePicker();

  // profanity list (English + common Filipino variants)
  bool _isVulgar(String text) {
    final badWords = [
      "fuck","shit","bitch","asshole","dick","pussy","cock","penis","vagina","boobs",
      "tits","fucker","bastard","whore","slut","nipple",
      "putangina","pakshet","pakshit","gago","tarantado","bwisit","bobo","tanga",
      "ulol","leche","pucha","punyeta","yawa","buwisit","siraulo","tangina","pota"
    ];
    final normalized = text.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z\u00C0-\u024F\u1E00-\u1EFF]'), '');
    return badWords.any((w) => normalized.contains(w.replaceAll(RegExp(r'[^a-zA-Z]'), '')));
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    if (!mounted) return;

    if (kIsWeb) {
      // For web we keep the path for NetworkImage preview but won't be able to read File bytes easily.
      setState(() {
        _profileImageFile = File(picked.path); // path works for preview with NetworkImage in some setups
      });
      // try to read bytes if available
      try {
        final bytes = await picked.readAsBytes();
        _profileImageBase64 = base64Encode(bytes);
      } catch (_) {
        _profileImageBase64 = null;
      }
    } else {
      final file = File(picked.path);
      final bytes = await file.readAsBytes();
      setState(() {
        _profileImageFile = file;
        _profileImageBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _handleSetup() async {
    final displayName = _displayNameController.text.trim();
    final username = widget.username ?? AccountStore.currentUsername;

    if (username == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No account context. Please register or login first.')));
      return;
    }

    // validations
    if (displayName.isEmpty || _gender == null || _userType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
      return;
    }
    if (displayName.length < 3 || displayName.length > 15) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Display name must be 3–15 characters long')));
      return;
    }
    if (_isVulgar(displayName)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Display name contains inappropriate language')));
      return;
    }

    // ensure account store references the username
    AccountStore.currentUsername = username;

    // Persist locally (dev bypass) or call API if you integrate later
    try {
      if (devBypass) {
        debugPrint('Dev bypass: saving profile locally for $username');
        final updates = {
          'displayName': displayName,
          'gender': _gender,
          'role': _userType,
        };
        // include base64 if selected
        if (_profileImageBase64 != null) updates['profileImage'] = _profileImageBase64;
        final ok = AccountStore.updateCurrentUser(updates);
        if (!ok) {
          // if update failed because store lacks the user (edge case)
          // try to set the map directly into the _users map via updateCurrentUser expectation
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update local account.')));
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Setup complete — returning to login...')));
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/'); // back to login
        return;
      }

      // If you ever replace devBypass = false, integrate actual API call here.
      // For now we do the same local update path.
      final updates = {
        'displayName': displayName,
        'gender': _gender,
        'role': _userType,
      };
      if (_profileImageBase64 != null) updates['profileImage'] = _profileImageBase64;
      final ok = AccountStore.updateCurrentUser(updates);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update account')));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Setup complete — returning to login...')));
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/'); // back to login
    } catch (e) {
      debugPrint('Setup error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unexpected error. Try again.')));
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  // small helper to build segmented choice buttons
  Widget _choiceButton(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: selected ? [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)] : null,
          ),
          child: Text(
            label,
            style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _profileImageFile != null
        ? (kIsWeb
            ? CircleAvatar(radius: 46, backgroundImage: NetworkImage(_profileImageFile!.path))
            : CircleAvatar(radius: 46, backgroundImage: FileImage(_profileImageFile!)))
        : const CircleAvatar(radius: 46, backgroundColor: Color(0xfffde2e4), child: Icon(Icons.person, size: 46, color: Colors.black));

    return Scaffold(
      backgroundColor: const Color(0xffffe6ee),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      const Text('Setup Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      avatar,
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Add Image', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 18),

                      // Display name
                      TextField(
                        controller: _displayNameController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(width: 2)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Gender row
                      Align(alignment: Alignment.centerLeft, child: Text('Gender:', style: TextStyle(fontWeight: FontWeight.w600))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _choiceButton('Male', _gender == 'Male', () => setState(() => _gender = 'Male')),
                          _choiceButton('Female', _gender == 'Female', () => setState(() => _gender = 'Female')),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // User type row
                      Align(alignment: Alignment.centerLeft, child: Text('User Type:', style: TextStyle(fontWeight: FontWeight.w600))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _choiceButton('Viewer', _userType == 'Viewer', () => setState(() => _userType = 'Viewer')),
                          _choiceButton('Designer', _userType == 'Designer', () => setState(() => _userType = 'Designer')),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Setup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSetup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),

                      const SizedBox(height: 10),
                      // small hint showing where user will return
                      const Text('After setup you will be returned to the login screen.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
