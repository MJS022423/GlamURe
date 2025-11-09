// myapp/lib/homepage-modules/tag_search_bar_module.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

// Import your tags source (create_post_module.dart should define `const sampleTags = { ... };`)
import 'create_post_components/create_post_module.dart';

class TagSearchBarModule extends StatefulWidget {
  final void Function(List<String>) onSearch;
  final List<String>? availableTags;
  final int maxSuggestions;

  const TagSearchBarModule({
    Key? key,
    required this.onSearch,
    this.availableTags,
    this.maxSuggestions = 6,
  }) : super(key: key);

  @override
  State<TagSearchBarModule> createState() => _TagSearchBarModuleState();
}

class _TagSearchBarModuleState extends State<TagSearchBarModule> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // For overlay positioning
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _targetKey = GlobalKey();

  OverlayEntry? _overlayEntry;

  List<String> _selectedTags = [];
  List<String> _allTags = []; // flattened from sampleTags or from availableTags
  List<String> _filteredSuggestions = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    // Flatten tags from sampleTags (imported)
    try {
      final flattened = <String>{};
      sampleTags.forEach((_, list) {
        for (final t in list) flattened.add(t);
      });

      if (widget.availableTags != null && widget.availableTags!.isNotEmpty) {
        final availableSet = widget.availableTags!.map((e) => e.trim()).toSet();
        _allTags = flattened.where((t) => availableSet.contains(t)).toList();
      } else {
        _allTags = flattened.toList();
      }
    } catch (e) {
      _allTags = [];
    }

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      } else {
        if (_controller.text.trim().isNotEmpty) {
          _filterSuggestions(_controller.text.trim());
          _showOverlay();
        }
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text.trim();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (text.isEmpty) {
        if (mounted) {
          setState(() {
            _filteredSuggestions = [];
          });
          _removeOverlay();
        }
      } else {
        _filterSuggestions(text);
        if (mounted) _showOverlay();
      }
    });

    // update clear icon visibility
    if (mounted) setState(() {});
  }

  void _filterSuggestions(String query) {
    final q = query.toLowerCase();
    final suggestions = _allTags
        .where((t) => t.toLowerCase().contains(q))
        .where((t) => !_selectedTags.contains(t))
        .take(widget.maxSuggestions)
        .toList();

    setState(() {
      _filteredSuggestions = suggestions;
    });

    if (_filteredSuggestions.isEmpty) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  // Adds tag from suggestion tap
  void _addTagFromSuggestion(String tag) {
    if (_selectedTags.contains(tag)) return;

    setState(() {
      _selectedTags.add(tag);
      _controller.clear();
      _filteredSuggestions = [];
    });

    widget.onSearch(List.unmodifiable(_selectedTags));

    // close overlay but KEEP focus (so the keyboard stays if desired)
    _removeOverlay();
    // NOTE: we intentionally DO NOT call _focusNode.unfocus() here so tapping feels instant
    // but the keyboard remains (remove this comment if you want keyboard to close).
  }

  // toggle via other controls (e.g., removing chip)
  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
      _controller.clear();
      _filteredSuggestions = [];
    });

    widget.onSearch(List.unmodifiable(_selectedTags));
    _removeOverlay();
    // keep focus intentionally
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
    widget.onSearch(List.unmodifiable(_selectedTags));
  }

  void _clearAll() {
    setState(() {
      _selectedTags.clear();
      _controller.clear();
      _filteredSuggestions = [];
    });
    widget.onSearch([]);
    _removeOverlay();
  }

  // Overlay management -----------------------------------------------------
  void _showOverlay() {
    // If there are no suggestions, ensure overlay is removed
    if (_filteredSuggestions.isEmpty) {
      _removeOverlay();
      return;
    }

    if (_overlayEntry != null) {
      // rebuild existing overlay
      _overlayEntry!.markNeedsBuild();
      return;
    }

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(builder: (context) {
      // Determine size & position of the target widget to align dropdown width
      RenderBox? box;
      try {
        box = _targetKey.currentContext?.findRenderObject() as RenderBox?;
      } catch (_) {
        box = null;
      }
      final size = box?.size ?? const Size(300, 40);

      return Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 8), // dropdown below the field with small gap
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: size.width,
              constraints: const BoxConstraints(maxHeight: 240),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredSuggestions.length,
                separatorBuilder: (_, __) => Divider(height: 0.5, color: Colors.grey.shade300),
                itemBuilder: (context, index) {
                  final suggestion = _filteredSuggestions[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque, // ensures tap registers
                    onTap: () => _addTagFromSuggestion(suggestion),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      child: Text(suggestion),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    });

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16.0);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        key: _targetKey,
        borderRadius: borderRadius,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: borderRadius,
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Selected chips scroll horizontally inside the input
                    if (_selectedTags.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _selectedTags.map((tag) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6.0, left: 4.0),
                                child: GFButton(
                                  onPressed: () => _removeTag(tag),
                                  shape: GFButtonShape.pills,
                                  size: GFSize.MEDIUM,
                                  type: GFButtonType.outline,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(tag, style: const TextStyle(fontSize: 13)),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.close, size: 14),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                    if (_selectedTags.isNotEmpty) const SizedBox(width: 8),

                    // The editable text field takes remaining space
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          final match = _allTags.firstWhere(
                            (t) => t.toLowerCase() == value.trim().toLowerCase(),
                            orElse: () => '',
                          );
                          if (match.isNotEmpty) _addTagFromSuggestion(match);
                        },
                        decoration: InputDecoration(
                          hintText: _selectedTags.isEmpty ? 'Search tags...' : '',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(onPressed: _clearAll, icon: const Icon(Icons.clear))
                              : IconButton(onPressed: () => _focusNode.requestFocus(), icon: const Icon(Icons.search)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
