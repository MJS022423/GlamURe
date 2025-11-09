// lib/settings/widgets/security_section.dart
import 'package:flutter/material.dart';
import '../../data/account_store.dart';
import 'header_tile.dart';

class SecuritySection extends StatefulWidget {
  final bool expanded;
  final VoidCallback? onSaved;

  const SecuritySection({super.key, required this.expanded, this.onSaved});

  @override
  State<SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends State<SecuritySection> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _new = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  Future<void> _changePassword() async {
    final curPass = _current.text;
    final newPass = _new.text;
    final confirm = _confirm.text;

    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New passwords do not match'), backgroundColor: Colors.red));
      return;
    }
    if (newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New password cannot be empty'), backgroundColor: Colors.red));
      return;
    }

    // verify old password
    final ok = AccountStore.verifyPassword(curPass);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current password is incorrect'), backgroundColor: Colors.red));
      return;
    }

    final changed = AccountStore.changePassword(newPass);
    if (changed) {
      _current.clear();
      _new.clear();
      _confirm.clear();
      widget.onSaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed'), backgroundColor: Colors.black));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to change password'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderTile(title: 'Security & Privacy', icon: Icons.shield_outlined, expanded: widget.expanded),
        if (widget.expanded) const SizedBox(height: 12),
        if (widget.expanded)
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Change Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(controller: _current, obscureText: true, decoration: InputDecoration(hintText: 'Current password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(height: 12),
                  TextField(controller: _new, obscureText: true, decoration: InputDecoration(hintText: 'New password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(height: 12),
                  TextField(controller: _confirm, obscureText: true, decoration: InputDecoration(hintText: 'Confirm new password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _changePassword, style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600))),
                ]),
              ),
            ),
          ),
      ],
    );
  }
}
