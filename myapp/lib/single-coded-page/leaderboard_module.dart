// myapp/lib/leaderboard-modules/leaderboard_module.dart
import 'package:flutter/material.dart';
import '../data/post_store.dart';
import '../homepage-modules/post_feed_module.dart';
import '../utils/app_bar_builder.dart';


class LeaderboardModule extends StatefulWidget {
  final VoidCallback? goBack; // kept for compatibility, not shown in UI
  const LeaderboardModule({super.key, this.goBack});

  @override
  State<LeaderboardModule> createState() => _LeaderboardModuleState();
}

class _LeaderboardModuleState extends State<LeaderboardModule> {
  List<Map<String, dynamic>> allDesigns = [];
  List<Map<String, dynamic>> displayedDesigns = [];
  bool isLoading = true;

  String? selectedField;
  String? selectedValue;
  String sortBy = 'Likes (desc)';

  final Map<String, List<String>> sampleTags = const {
    'Gender': ['Men', 'Women', 'Unisex'],
    'Style': [
      'Casual',
      'Formal',
      'Streetwear',
      'Luxury',
      'Minimalist',
      'Bohemian',
      'Athletic',
      'Trendy',
      'Classic',
      'Edgy',
      'Elegant',
      'Modern',
      'Chic',
      'Urban',
      'Designer',
      'Fashionista'
    ],
    'Occasion': ['Everyday', 'Workwear', 'Partywear', 'Outdoor', 'Seasonal', 'Special Event'],
    'Material': ['Cotton', 'Denim', 'Leather', 'Silk', 'Wool', 'Linen', 'Synthetic', 'Eco-Friendly'],
    'Color': ['Monochrome', 'Colorful', 'Neutral', 'Pastel', 'Bold', 'Patterned'],
    'Accessories': ['Footwear', 'Bags', 'Jewelry', 'Hats', 'Belts', 'Scarves', 'Sunglasses'],
    'Features': ['Comfortable', 'Layered', 'Textured', 'Statement', 'Soft', 'Versatile', 'Functional']
  };

  @override
  void initState() {
    super.initState();
    _loadTopDesigns();
  }

  void _loadTopDesigns() {
    setState(() => isLoading = true);
    try {
      final designs = PostStore.getAllPosts();
      allDesigns = designs.map((p) => Map<String, dynamic>.from(p)).toList();
    } catch (_) {
      allDesigns = [];
    } finally {
      _applyFiltersAndSort();
      setState(() => isLoading = false);
    }
  }

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> filtered = List.from(allDesigns);

    if (selectedField != null && selectedValue != null) {
      final key = selectedField!.toLowerCase();
      filtered = filtered.where((post) {
        final v = post[key];
        if (v == null) return false;
        if (v is Iterable) return v.any((x) => x?.toString().trim() == selectedValue);
        return v.toString().trim() == selectedValue;
      }).toList();
    }

    if (sortBy == 'Likes (desc)') {
      filtered.sort((a, b) => _parseInt(b['likes']).compareTo(_parseInt(a['likes'])));
    } else if (sortBy == 'Likes (asc)') {
      filtered.sort((a, b) => _parseInt(a['likes']).compareTo(_parseInt(b['likes'])));
    } else if (sortBy == 'Newest') {
      filtered.sort((a, b) {
        final da = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(0);
        final db = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(0);
        return db.compareTo(da);
      });
    }

    setState(() => displayedDesigns = filtered);
  }

  int _parseInt(Object? v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  void _showFieldSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(padding: EdgeInsets.all(16.0), child: Text("Select Tag Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
            ListTile(
              title: const Text("All"),
              trailing: selectedField == null ? const Icon(Icons.check_circle, color: Color(0xFFFFC0CB)) : null,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedField = null;
                  selectedValue = null;
                });
                _applyFiltersAndSort();
              },
            ),
            ...sampleTags.keys.map((field) {
              return ListTile(
                title: Text(field),
                trailing: selectedField == field ? const Icon(Icons.check_circle, color: Color(0xFFFFC0CB)) : null,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedField = field;
                    selectedValue = null;
                  });
                  _showValueSelector(field);
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _showValueSelector(String field) {
    final values = sampleTags[field] ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            Padding(padding: const EdgeInsets.all(16.0), child: Text("$field Tags", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
            ListTile(
              title: const Text("All"),
              trailing: selectedValue == null ? const Icon(Icons.check_circle, color: Color(0xFFFFC0CB)) : null,
              onTap: () {
                Navigator.pop(context);
                setState(() => selectedValue = null);
                _applyFiltersAndSort();
              },
            ),
            ...values.map((val) {
              return ListTile(
                title: Text(val),
                trailing: selectedValue == val ? const Icon(Icons.check_circle, color: Color(0xFFFFC0CB)) : null,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => selectedValue = val);
                  _applyFiltersAndSort();
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _showSortSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        final options = ['Likes (desc)', 'Likes (asc)', 'Newest'];
        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(padding: EdgeInsets.all(16.0), child: Text("Sort By", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
            ...options.map((opt) {
              return ListTile(
                title: Text(opt),
                trailing: sortBy == opt ? const Icon(Icons.check_circle, color: Color(0xFFFFC0CB)) : null,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => sortBy = opt);
                  _applyFiltersAndSort();
                },
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar('Leaderboard'),
      body: Container(
        width: double.infinity,
       color: const Color(0xFFFFC0CB),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // icons-only control row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _iconOnlyButton(Icons.filter_list, _showFieldSelector, selectedField != null),
                    const SizedBox(width: 12),
                    _iconOnlyButton(Icons.label, () {
                      if (selectedField != null) {
                        _showValueSelector(selectedField!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select a tag category first")));
                      }
                    }, selectedValue != null),
                    const SizedBox(width: 12),
                    _iconOnlyButton(Icons.sort, _showSortSelector, true),
                  ],
                ),
              ),

              // feed
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : displayedDesigns.isEmpty
                        ? const Center(child: Text('No posts found.\nCreate or like posts to see them here!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)))
                        : PostFeedModule(posts: displayedDesigns),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconOnlyButton(IconData icon, VoidCallback onTap, bool active) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: active ? const Color(0xFFFFB6C1) : Colors.white,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 22, color: Colors.black),
            ),
          ),
        ),
        // small dot badge when active (and there's a selectedValue for the Value button)
        if (active)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: const Color(0xFFFFC0CB), shape: BoxShape.circle, boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ]),
            ),
          ),
      ],
    );
  }
}
