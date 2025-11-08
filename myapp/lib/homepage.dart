import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'homepage-modules/create_post_module.dart';
import 'homepage-modules/post_feed_module.dart';
import 'homepage-modules/tag_search_bar_module.dart';
import 'homepage-modules/leaderboard_module.dart';
import 'about.dart';
import 'profile.dart';
import 'settings.dart';
import 'bookmark.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showPostModal = false;

  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> filteredPosts = [];

  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      _buildHomeContent(),
      LeaderboardModule(goBack: () => setState(() => _selectedIndex = 0)),
      AboutPage(),
      ProfilePage(),
      SettingsPage(),
      BookmarkPage(),
    ]);
  }

  // Handle adding a post
  void handleAddPost(Map<String, dynamic> newPost) {
    setState(() {
      posts.insert(0, newPost);
      filteredPosts.insert(0, newPost);
      showPostModal = false;
    });
  }

  // Handle tag search
  void handleTagSearch(List<String> selectedTags) {
    setState(() {
      if (selectedTags.isEmpty) {
        filteredPosts = List.from(posts);
        return;
      }
      filteredPosts = posts
          .where((post) =>
              post['tags'].any((tag) => selectedTags.contains(tag)))
          .toList();
    });
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/Web-logo.svg',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 8),
              const Text(
                "Glamure",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
        ),

        // Search bar with Create Post icon
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Create Post icon on the left
              IconButton(
                iconSize: 36,
                onPressed: () => setState(() => showPostModal = true),
                icon: SvgPicture.asset(
                  'assets/create-svgrepo-com.svg',
                  width: 36,
                  height: 36,
                ),
              ),
              const SizedBox(width: 8),

              // Search bar (flexible)
              Expanded(
                child: TagSearchBarModule(onSearch: handleTagSearch),
              ),
            ],
          ),
        ),

        // Post feed (fills remaining screen)
        Expanded(
          child: PostFeedModule(
            posts: filteredPosts.isNotEmpty ? filteredPosts : posts,
          ),
        ),

        // Create Post Modal
        if (showPostModal)
          CreatePostModule(
            onClose: () => setState(() => showPostModal = false),
            addPost: handleAddPost,
          ),
      ],
    );
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 224, 224),
      body: SafeArea(
        child: Stack(
          children: [
            _pages[_selectedIndex],

            // Bottom navigation bar (absolute)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => _onNavTapped(0),
                      icon: SvgPicture.asset(
                        'assets/home.svg',
                        width: 28,
                        height: 28,
                        color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _onNavTapped(1),
                      icon: SvgPicture.asset(
                        'assets/leaderboard.svg',
                        width: 28,
                        height: 28,
                        color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _onNavTapped(2),
                      icon: SvgPicture.asset(
                        'assets/info.svg',
                        width: 28,
                        height: 28,
                        color: _selectedIndex == 2 ? Colors.blue : Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _onNavTapped(3),
                      icon: SvgPicture.asset(
                        'assets/profile.svg',
                        width: 28,
                        height: 28,
                        color: _selectedIndex == 3 ? Colors.blue : Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _onNavTapped(4),
                      icon: SvgPicture.asset(
                        'assets/settings.svg',
                        width: 28,
                        height: 28,
                        color: _selectedIndex == 4 ? Colors.blue : Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _onNavTapped(5),
                      icon: SvgPicture.asset(
                        'assets/bookmark.svg',
                        width: 28,
                        height: 28,
                        color: _selectedIndex == 5 ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
