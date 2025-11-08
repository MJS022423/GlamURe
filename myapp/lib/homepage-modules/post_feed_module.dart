import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:getwidget/getwidget.dart';

class PostFeedModule extends StatefulWidget {
  final List<Map<String, dynamic>> posts;
  const PostFeedModule({super.key, required this.posts});

  @override
  State<PostFeedModule> createState() => _PostFeedModuleState();
}

class _PostFeedModuleState extends State<PostFeedModule> {
  Map<String, bool> likesState = {};
  Map<String, bool> bookmarksState = {};
  Map<String, List<Map<String, String>>> commentsState = {};
  Map<String, TextEditingController> commentControllers = {};
  Map<String, int> currentImageIndex = {};
  Map<String, dynamic>? expandedPost;
  bool modalDescExpanded = false;

  void toggleLike(String postId) {
    setState(() {
      likesState[postId] = !(likesState[postId] ?? false);
    });
  }

  void toggleBookmark(String postId) {
    setState(() {
      bookmarksState[postId] = !(bookmarksState[postId] ?? false);
    });
  }

  void addComment(String postId) {
    final controller = commentControllers[postId];
    if (controller == null || controller.text.trim().isEmpty) return;

    setState(() {
      commentsState[postId] = [
        ...(commentsState[postId] ?? []),
        {'username': 'Jzar Alaba', 'text': controller.text.trim()}
      ];
      controller.clear();
    });
  }

  void openPost(Map<String, dynamic> post) {
    final postId = post['id'].toString();
    setState(() {
      expandedPost = post;
      currentImageIndex[postId] = 0;
      modalDescExpanded = false;
      commentControllers[postId] ??= TextEditingController();
    });
  }

  void closePost() => setState(() => expandedPost = null);

  void nextImage(String postId, int length) {
    setState(() {
      currentImageIndex[postId] = (currentImageIndex[postId]! + 1) % length;
    });
  }

  void prevImage(String postId, int length) {
    setState(() {
      currentImageIndex[postId] =
          (currentImageIndex[postId]! - 1 + length) % length;
    });
  }

  Widget buildFeedDescription(String desc, Map<String, dynamic> post) {
    const int FEED_DESC_LIMIT = 30;
    if (desc.length <= FEED_DESC_LIMIT) return Text(desc);

    return RichText(
      text: TextSpan(
        text: desc.substring(0, FEED_DESC_LIMIT) + "... ",
        style: const TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: "More",
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = () => openPost(post),
          )
        ],
      ),
    );
  }

  Widget buildModalDescription(String desc) {
    const int MODAL_DESC_LIMIT = 100;
    if (desc.length <= MODAL_DESC_LIMIT) return Text(desc);

    return RichText(
      text: TextSpan(
        text: modalDescExpanded
            ? desc
            : desc.substring(0, MODAL_DESC_LIMIT) + "... ",
        style: const TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: modalDescExpanded ? "Less" : "More",
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                setState(() {
                  modalDescExpanded = !modalDescExpanded;
                });
              },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.only(top: 50),
        child: Text("No posts yet",
            style: TextStyle(fontSize: 18, color: Colors.grey)),
      ));
    }

    // Expanded post modal
    if (expandedPost != null) {
      final postId = expandedPost!['id'].toString();
      final images = List<String>.from(expandedPost!['images']);

      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: closePost,
          ),
          title: const Text('Post Details'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (images.isNotEmpty)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      images[currentImageIndex[postId] ?? 0],
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    if (images.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white),
                            onPressed: () => prevImage(postId, images.length),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios,
                                color: Colors.white),
                            onPressed: () => nextImage(postId, images.length),
                          ),
                        ],
                      ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildModalDescription(expandedPost!['description']),
                    const SizedBox(height: 8),
                    Text(
                      "${expandedPost!['gender']} | ${expandedPost!['style']} | ${expandedPost!['tags'].take(3).join(' | ')}",
                      style:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => toggleLike(postId),
                          child: Row(
                            children: [
                              Icon(
                                likesState[postId] ?? false
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                  "${expandedPost!['likes'] + ((likesState[postId] ?? false) ? 1 : 0)}"),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => toggleBookmark(postId),
                          child: Row(
                            children: [
                              Icon(
                                bookmarksState[postId] ?? false
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                  "${(bookmarksState[postId] ?? false) ? 1 : 0}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Comments',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (commentsState[postId] ?? []).length,
                      itemBuilder: (context, index) {
                        final comment = commentsState[postId]![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: comment['username'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ' ${comment['text']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentControllers[postId],
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () => addComment(postId),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Normal post feed
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        final post = widget.posts[index];
        final postId = post['id'].toString();
        final images = List<String>.from(post['images']);

        return GestureDetector(
          onTap: () => openPost(post),
          child: GFCard(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Images grid
                if (images.isNotEmpty)
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: images.length > 4 ? 4 : images.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: images.length == 1 ? 1 : 2,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, idx) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            images[idx],
                            fit: BoxFit.cover,
                          ),
                          if (idx == 3 && images.length > 4)
                            Container(
                              color: Colors.black54,
                              alignment: Alignment.center,
                              child: Text(
                                "+${images.length - 4} more",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                        ],
                      );
                    },
                  ),
                const SizedBox(height: 8),

                // Post description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: buildFeedDescription(post['description'], post),
                ),
                const SizedBox(height: 4),

                // Post tags / info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "${post['gender']} | ${post['style']} | ${post['tags'].take(3).join(' | ')}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),

                // Likes & bookmarks
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => toggleLike(postId),
                        child: Row(
                          children: [
                            Icon(
                              likesState[postId] ?? false
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                                "${post['likes'] + ((likesState[postId] ?? false) ? 1 : 0)}"),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => toggleBookmark(postId),
                        child: Row(
                          children: [
                            Icon(
                              bookmarksState[postId] ?? false
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                                "${(bookmarksState[postId] ?? false) ? 1 : 0}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
