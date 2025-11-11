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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
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
          .where((post) =>
              post['tags'].any((tag) => selectedTags.contains(tag)))
          .toList();
    });
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

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) _loadPosts(); // ✅ Refresh when returning to Home
    });
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
            icon: SvgPicture.asset(
              'assets/home.svg',
              width: 36,
              height: 36,
              color: _selectedIndex == 0 ? Colors.black : Colors.grey,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/leaderboard.svg',
              width: 36,
              height: 36,
              color: _selectedIndex == 1 ? Colors.black : Colors.grey,
            ),
            label: 'Leaderboard',
          ),
           BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/bookmark.svg',
              width: 36,
              height: 36,
              color: _selectedIndex == 2 ? Colors.black : Colors.grey,
            ),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/profile.svg',
              width: 36,
              height: 36,
              color: _selectedIndex == 3 ? Colors.black : Colors.grey,
            ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/settings.svg',
              width: 36,
              height: 36,
              color: _selectedIndex == 4 ? Colors.black : Colors.grey,
            ),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/info.svg',
              width: 36,
              height: 36,
              color: _selectedIndex == 5 ? Colors.black : Colors.grey,
            ),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
