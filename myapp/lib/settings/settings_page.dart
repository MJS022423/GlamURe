// lib/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'widgets/profile_section.dart';
import 'widgets/security_section.dart';
import 'widgets/account_section.dart';
import '../data/account_store.dart';
import '../utils/app_bar_builder.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // expanded toggles lifted here so child widgets can be simple
  bool profileExpanded = false;
  bool securityExpanded = false;
  bool accountExpanded = false;

  // Called by child to request refresh after changes saved
  void _refresh() => setState(() {});

  Future<void> _onLogout() async {
    // Use the AccountStore logout already used across project
    AccountStore.logout();
    // After logout you probably navigate to login - existing app logic handles that
    // Caller of SettingsPage (home) should re-route, but we leave navigation to caller.
    // We still pop this page if possible:
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffde2e4),
      appBar: buildCustomAppBar('Settings'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Section
            GestureDetector(
              onTap: () => setState(() => profileExpanded = !profileExpanded),
              child: ProfileSection(
                expanded: profileExpanded,
                onSaved: _refresh,
              ),
            ),
            const SizedBox(height: 16),

            // Security Section
            GestureDetector(
              onTap: () => setState(() => securityExpanded = !securityExpanded),
              child: SecuritySection(
                expanded: securityExpanded,
                onSaved: _refresh,
              ),
            ),
            const SizedBox(height: 16),

            // Account Section
            GestureDetector(
              onTap: () => setState(() => accountExpanded = !accountExpanded),
              child: AccountSection(
                expanded: accountExpanded,
                onLogout: _onLogout,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
