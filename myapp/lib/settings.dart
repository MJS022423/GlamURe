import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffde2e4),
      appBar: GFAppBar(
        backgroundColor: const Color.fromARGB(255, 224, 224, 224),
        title: const Text("Settings", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text("Settings Page"),
      ),
    );
  }
}
