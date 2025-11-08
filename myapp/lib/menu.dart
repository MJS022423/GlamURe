import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:getwidget/getwidget.dart';
import 'homepage.dart';
import 'bookmark.dart';
import 'profile.dart';
import 'settings.dart';
import 'about.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menu items with page navigation
    final List<Map<String, dynamic>> menuItems = [
      {'name': 'Home', 'icon': 'assets/home.svg', 'route': const HomePage()},
      {'name': 'Bookmark', 'icon': 'assets/bookmark.svg', 'route': const BookmarkPage()},
      {'name': 'Profile', 'icon': 'assets/profile.svg', 'route': const ProfilePage()},
      {'name': 'Settings', 'icon': 'assets/settings.svg', 'route': const SettingsPage()},
      {'name': 'About Us', 'icon': 'assets/info.svg', 'route': const AboutPage()},
    ];

    return Scaffold(
      backgroundColor: const Color(0xfffde2e4),
      appBar: GFAppBar(
        backgroundColor: const Color.fromARGB(255, 224, 224, 224),
        title: const Text(
          "Menu",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GFButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => item['route']),
                      );
                    },
                    color: Colors.white,
                    textColor: Colors.black,
                    shape: GFButtonShape.pills,
                    fullWidthButton: true,
                    icon: SvgPicture.asset(
                      item['icon'],
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    ),
                    text: '   ${item['name']}',
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GFButton(
              onPressed: () {
                print('Logout clicked');
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              color: Colors.redAccent,
              textColor: Colors.white,
              shape: GFButtonShape.pills,
              fullWidthButton: true,
              icon: const Icon(Icons.logout, color: Colors.white),
              text: '   Logout',
            ),
          ),
        ],
      ),
    );
  }
}
