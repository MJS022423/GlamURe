// myapp/lib/homepage-modules/homepage.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'create_post_components/create_post_module.dart';
import 'post_feed_module.dart';
import 'tag_search_bar_module.dart';
import '../single-coded-page/leaderboard_module.dart';
import '../single-coded-page/about.dart';
import '../profile/profile_page.dart';
import '../settings/settings_page.dart';
import '../single-coded-page/bookmark.dart';
import '../data/post_store.dart'; // ✅ Global post storage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool showPostModal = false;

  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> filteredPosts = [];

  int _selectedIndex = 0;

  late AnimationController _modalController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _modalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _modalController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _modalController, curve: Curves.easeOut),
    );
  }

  /// ✅ Load posts from PostStore
  void _loadPosts() {
    final allPosts = PostStore.getAllPosts();
    setState(() {
      posts = allPosts;
      filteredPosts = allPosts;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPosts(); // ✅ Auto-refresh when returning from ProfilePage
  }

  @override
  void dispose() {
    _modalController.dispose();
    super.dispose();
  }

  /// ✅ When adding post, only refresh UI (CreatePostModule already stores globally)
  void handleAddPost(Map<String, dynamic> newPost) {
    // Remove PostStore.addPost(newPost); ✅ no more duplication
    _loadPosts(); // refresh from global store
    closeModal();
  }

  void openModal() {
    setState(() => showPostModal = true);
    _modalController.forward();
  }

  void closeModal() async {
    await _modalController.reverse();
    setState(() => showPostModal = false);
  }

  void handleTagSearch(List<String> selectedTags) {
    setState(() {
      if (selectedTags.isEmpty) {
        filteredPosts = List.from(posts);
        return;
      }
      filteredPosts = posts
          .where((post) => post['tags'].any((tag) => selectedTags.contains(tag)))
          .toList();
    });
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) _loadPosts(); // ✅ Refresh when returning to Home
    });
  }

  // Helper to create a tintable SVG icon consistently
  Widget _svgIcon(String assetPath, {double size = 36, required bool selected, String? semanticLabel}) {
    final color = selected ? Colors.black : Colors.grey;
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        // Use colorFilter to tint the svg reliably
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        // A small widget shown while SVG is loading
        placeholderBuilder: (context) => Center(
          child: SizedBox(
            width: size * 0.5,
            height: size * 0.5,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        semanticsLabel: semanticLabel ?? assetPath.split('/').last,
      ),
    );
  }

  Widget _buildHomeContent() {
    return Stack(
      children: [
        Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/Web-logo.svg',
                    width: 48,
                    height: 48,
                    // logo might be multi-colored; don't force a color here
                    placeholderBuilder: (context) => const SizedBox(
                      width: 48,
                      height: 48,
                    ),
                    semanticsLabel: 'Glamure logo',
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Glamure",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),

            // Search bar (create-post icon moved to floating action button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: TagSearchBarModule(onSearch: handleTagSearch),
                  ),
                ],
              ),
            ),

            // ✅ Live Post Feed
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _loadPosts();
                },
                child: PostFeedModule(
                  posts: filteredPosts.isNotEmpty ? filteredPosts : posts,
                ),
              ),
            ),
          ],
        ),

        // Modal overlay with animation
        if (showPostModal)
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Positioned.fill(
                child: CreatePostModule(
                  onClose: closeModal,
                  addPost: handleAddPost,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (_selectedIndex) {
      case 0:
        currentPage = _buildHomeContent();
        break;
      case 1:
        currentPage =
            LeaderboardModule(goBack: () => setState(() => _selectedIndex = 0));
        break;
      case 2:
        currentPage = BookmarkPage();
        break;
      case 3:
        currentPage = const ProfilePage();
        break;
      case 4:
        currentPage = SettingsPage();
        break;
      case 5:
        currentPage = AboutPage();
        break;
      default:
        currentPage = _buildHomeContent();
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 224, 224),
      body: SafeArea(child: currentPage),
      // Floating + button placed above bottom navigation (bottom-right)
      // Show FAB only on Home (index 0)
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: openModal,
              backgroundColor: Colors.white,
              elevation: 6,
              child: SvgPicture.asset(
                'assets/create-svgrepo-com.svg',
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                placeholderBuilder: (context) => const SizedBox(
                  width: 28,
                  height: 28,
                ),
                semanticsLabel: 'Create post',
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        iconSize: 36,
        items: [
          BottomNavigationBarItem(
            icon: _svgIcon('assets/home.svg', size: 36, selected: _selectedIndex == 0, semanticLabel: 'Home'),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _svgIcon('assets/leaderboard.svg', size: 36, selected: _selectedIndex == 1, semanticLabel: 'Leaderboard'),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: _svgIcon('assets/bookmark.svg', size: 36, selected: _selectedIndex == 2, semanticLabel: 'Bookmark'),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: _svgIcon('assets/profile.svg', size: 36, selected: _selectedIndex == 3, semanticLabel: 'Profile'),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: _svgIcon('assets/settings.svg', size: 36, selected: _selectedIndex == 4, semanticLabel: 'Settings'),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: _svgIcon('assets/info.svg', size: 36, selected: _selectedIndex == 5, semanticLabel: 'About'),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
