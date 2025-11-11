import React, { useEffect, useState } from "react";
import CreatePost from "./homepage-modules/CreatePost";
import PostFeed from "./homepage-modules/PostFeed";
import { Heart, Plus, User, Bookmark } from "lucide-react";

const EXPRESS_API = import.meta.env.VITE_EXPRESS_API;
const token = localStorage.getItem("token");
const userid = localStorage.getItem("userid");

export default function ProfilePage() {
  const [showPostModal, setShowPostModal] = useState(false);

  // Designer minimal info (role added)
  const [designer, setDesigner] = useState({
    name: "Designer",
    role: "Designer", // new role field (shown under username)
    email: "user@gmail.com",
    likes: 0,
    posts: 0,
    avatar: null, // optional base64 or url
  });

  // posts state loaded from backend and filtered to current user
  const [posts, setPosts] = useState([]);
  const [loadingPosts, setLoadingPosts] = useState(true);
  const [postsError, setPostsError] = useState(null);

  // Top-3 / modal UI state
  const [expandedPost, setExpandedPost] = useState(null);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [likesState, setLikesState] = useState({}); // local toggles
  const [bookmarksState, setBookmarksState] = useState({}); // persisted to server
  const [commentInputs, setCommentInputs] = useState({});
  const [commentsState, setCommentsState] = useState({});
  const [modalDescExpanded, setModalDescExpanded] = useState(false);

  // Fetch posts + bookmarks
  useEffect(() => {
    let mounted = true;

    async function loadUserPosts() {
      setLoadingPosts(true);
      setPostsError(null);
      try {
        const res = await fetch(`${EXPRESS_API}/post/Displaypost?page=1&limit=100`);
        if (!res.ok) {
          const text = await res.text();
          throw new Error(`Failed to load posts: ${res.status} ${text}`);
        }
        const data = await res.json();
        const allPosts = Array.isArray(data.results) ? data.results : [];

        // filter user posts
        const userPosts = allPosts.filter(p => String(p.userId) === String(userid));

        if (!mounted) return;

        const normalized = userPosts.map(p => ({
          id: p.id || p.Post_id || p._id,
          username: p.username || p.Username || designer.name,
          description: p.caption ?? p.description ?? "",
          images: p.images ?? p.Images ?? [],
          tags: p.tags ?? p.Tags ?? [],
          gender: p.gender ?? p.Gender ?? "Unisex",
          style: p.style ?? p.Style ?? "Casual",
          likes: Number(p.likes ?? 0),
          comments: p.comments ?? [],
          createdAt: p.createdDate ?? p.createdAt ?? new Date().toISOString(),
        }));

        setPosts(normalized);
        setDesigner(prev => ({ ...prev, posts: normalized.length || 0 }));
      } catch (err) {
        console.error(err);
        if (mounted) setPostsError(err.message || "Failed to load posts");
      } finally {
        if (mounted) setLoadingPosts(false);
      }
    }

    async function loadBookmarks() {
      try {
        if (!token || !userid) return;
        const res = await fetch(`${EXPRESS_API}/bookmark/DisplayBookmark?userId=${userid}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = await res.json();
        if (data && data.success && Array.isArray(data.bookmarks)) {
          const map = data.bookmarks.reduce((acc, item) => { acc[item.id] = true; return acc; }, {});
          if (mounted) setBookmarksState(map);
        }
      } catch (err) {
        console.error("Failed to load bookmarks:", err);
      }
    }

    if (userid) {
      loadUserPosts();
      loadBookmarks();
    } else {
      setLoadingPosts(false);
      setPostsError("No user ID found in localStorage");
    }

    return () => { mounted = false; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // CreatePost callback (normalizes)
  const handleAddPost = (newPost) => {
    const normalized = newPost.id ? {
      id: newPost.id,
      username: newPost.username || designer.name,
      description: newPost.caption ?? newPost.description ?? "",
      images: newPost.images ?? (newPost.image ? [newPost.image] : []),
      tags: newPost.tags ?? [],
      gender: newPost.gender ?? "Unisex",
      style: newPost.style ?? "Casual",
      likes: newPost.likes ?? 0,
      comments: newPost.comments ?? [],
      createdAt: newPost.createdDate ?? newPost.createdAt ?? new Date().toISOString(),
    } : {
      id: Date.now().toString(),
      username: designer.name,
      description: newPost.description ?? "",
      images: newPost.images ?? (newPost.image ? [newPost.image] : []),
      tags: newPost.tags ?? [],
      gender: "Unisex",
      style: "Casual",
      likes: 0,
      comments: [],
      createdAt: new Date().toISOString(),
    };

    setPosts(prev => [normalized, ...prev]);
    setDesigner(prev => ({ ...prev, posts: (prev.posts || 0) + 1 }));
    setShowPostModal(false);
  };

  // top3 computed
  const top3Designs = [...posts].sort((a, b) => (Number(b.likes || 0) - Number(a.likes || 0))).slice(0, 3);

  // open modal for top3 (profile-level)
  const openTopModal = (post) => {
    setExpandedPost(post);
    setCurrentImageIndex(0);
    setModalDescExpanded(false);
  };
  const closeTopModal = () => setExpandedPost(null);

  const prevImage = () => {
    if (!expandedPost) return;
    setCurrentImageIndex(i => (i - 1 >= 0 ? i - 1 : expandedPost.images.length - 1));
  };
  const nextImage = () => {
    if (!expandedPost) return;
    setCurrentImageIndex(i => (i + 1 < expandedPost.images.length ? i + 1 : 0));
  };

  // toggle like locally and animate
  const toggleLikeLocal = (postId) => {
    setLikesState(prev => {
      const next = { ...prev, [postId]: !prev[postId] };
      return next;
    });
  };

  // toggle bookmark and persist
  const toggleBookmarkLocal = async (post) => {
    if (!userid || !token) return;
    const postId = post.id;
    const next = !bookmarksState[postId];
    setBookmarksState(prev => ({ ...prev, [postId]: next }));

    try {
      if (next) {
        const newItem = {
          id: post.id,
          image: post.images?.[0] || "",
          title: post.style || "Design",
          description: post.description || "",
        };
        await fetch(`${EXPRESS_API}/bookmark/SaveBookmark?userId=${userid}`, {
          method: "POST",
          headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
          body: JSON.stringify({ newItem }),
        });
      } else {
        await fetch(`${EXPRESS_API}/bookmark/RemoveBookmark?userId=${userid}`, {
          method: "POST",
          headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
          body: JSON.stringify({ postId }),
        });
      }
    } catch (err) {
      console.error("Bookmark update failed:", err);
      setBookmarksState(prev => ({ ...prev, [postId]: !next }));
    }
  };

  const handleAddCommentLocal = (postId) => {
    const input = (commentInputs[postId] || "").trim();
    if (!input) return;
    setCommentsState(prev => ({ ...prev, [postId]: [...(prev[postId] || []), { username: designer.name, text: input }] }));
    setCommentInputs(prev => ({ ...prev, [postId]: "" }));
  };

  const renderModalDescription = (desc) => {
    if (!desc) return "";
    if (desc.length <= 100) return desc;
    return modalDescExpanded ? desc : desc.slice(0, 100) + "...";
  };

  // normalizedPosts for PostFeed usage
  const normalizedPosts = posts.map(p => ({
    id: p.id,
    username: p.username,
    description: p.description,
    images: p.images,
    tags: p.tags,
    gender: p.gender,
    style: p.style,
    likes: p.likes,
    comments: p.comments,
    createdAt: p.createdAt,
  }));

  // helper class for icon animation/active styles
  const iconClass = (active, base = "text-black") =>
    `transition-transform duration-200 ${active ? "scale-110" : "scale-100"} ${active ? "text-red-500" : base}`;

  const bookmarkClass = (active) =>
    `transition-transform duration-200 ${active ? "scale-110 text-yellow-600" : "scale-100 text-black"}`;

  return (
    <div className="flex flex-col min-h-screen bg-gradient-to-b from-[#1b1b1b] via-[#2b2b2b] to-[#f9c5d1] text-white overflow-hidden">
      {/* Header */}
      <div className="bg-[#1b1b1b] backdrop-blur-sm border-b border-pink-300 p-6 flex items-center justify-between sticky top-0 z-10">
        <div className="flex items-center">
          <h1 className="text-4xl font-extrabold text-pink-200 tracking-wide">PROFILE</h1>
        </div>

        <div className="flex items-center gap-2">
          <div className="text-3xl font-extrabold text-pink-200">Glamure</div>
          <div className="text-xl text-white font-semibold">APPAREL</div>
        </div>
      </div>

      {/* Main */}
      <div className="p-8 flex-1">
        <div className="flex flex-col lg:flex-row gap-10">
          {/* LEFT: profile info */}
          <div className="lg:w-1/3">
            <div className="bg-pink-100 text-black rounded-3xl p-6 mb-6 shadow-md">
              <div className="flex items-center gap-4 mb-6">
                {/* Avatar + Username + Role */}
                <div className="w-24 h-24 bg-pink-300 rounded-full flex items-center justify-center overflow-hidden">
                  {designer.avatar ? (
                    <img src={designer.avatar} alt="avatar" className="w-full h-full object-cover" />
                  ) : (
                    <User className="w-12 h-12 text-black" />
                  )}
                </div>
                <div>
                  <h2 className="text-xl font-bold text-pink-900">{designer.name}</h2>
                  <p className="text-sm text-gray-700">{designer.role}</p>
                </div>
              </div>

              {/* Stats (Likes / Posts) */}
              <div className="flex justify-around mb-6">
                <div className="text-center">
                  <div className="text-xs font-semibold text-pink-700 mb-1">LIKES</div>
                  <div className="text-lg font-bold text-black">{designer.likes}</div>
                </div>
                <div className="text-center">
                  <div className="text-xs font-semibold text-pink-700 mb-1">POSTS</div>
                  <div className="text-lg font-bold text-black">{designer.posts}</div>
                </div>
              </div>

              <button onClick={() => setShowPostModal(true)} className="w-full bg-black text-pink-200 font-semibold py-3 rounded-full flex items-center justify-center gap-2 hover:bg-pink-300 hover:text-black transition">
                <Plus className="w-5 h-5" /> Add Post
              </button>
            </div>

            {/* Designer info - only email */}
            <div className="bg-pink-100 text-black rounded-3xl p-6 shadow-md">
              <h3 className="text-lg font-bold mb-4">DESIGNER INFO</h3>
              <div className="text-sm">
                <p><span className="font-semibold">E-MAIL:</span> {designer.email}</p>
              </div>
            </div>
          </div>

          {/* RIGHT: Top 3 and Posts */}
          <div className="flex-1">
            {/* Top 3 Designs */}
            <div className="mb-8">
              <div className="flex items-center gap-2 mb-4">
                <h3 className="text-xl font-bold text-pink-200">TOP 3 DESIGNS</h3>
                <span className="text-2xl">🔥</span>
              </div>

              {loadingPosts ? (
                <p className="text-gray-300">Loading top designs...</p>
              ) : postsError ? (
                <p className="text-red-400">Error loading designs: {postsError}</p>
              ) : top3Designs.length === 0 ? (
                <p className="text-gray-500">No designs yet</p>
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                  {top3Designs.map(post => {
                    const liked = !!likesState[post.id];
                    const bookmarked = !!bookmarksState[post.id];
                    return (
                      <div
                        key={post.id}
                        className="bg-pink-100 text-black rounded-2xl overflow-hidden shadow-lg flex flex-col transform transition-transform duration-300 hover:scale-105"
                      >
                        <div
                          className="aspect-[4/3] w-full overflow-hidden cursor-pointer"
                          onClick={() => openTopModal(post)}
                        >
                          {post.images && post.images.length > 0 ? (
                            <img
                              src={post.images[0]}
                              alt="design"
                              className="w-full h-full object-cover transform transition-transform duration-500 hover:scale-110"
                            />
                          ) : (
                            <div className="w-full h-full bg-gray-200 flex items-center justify-center text-gray-600">No image</div>
                          )}
                        </div>

                        <div className="p-4 flex items-center justify-between">
                          <div className="text-sm">
                            <div className="font-semibold">{post.style || "Design"}</div>
                            <div className="text-xs text-gray-700">{(post.tags || []).slice(0,2).join(" | ")}</div>
                          </div>

                          <div className="flex items-center gap-4">
                            {/* Heart */}
                            <button
                              onClick={(e) => { e.stopPropagation(); toggleLikeLocal(post.id); }}
                              className={`flex items-center gap-2 focus:outline-none ${liked ? "scale-110" : "scale-100"} transition-transform duration-200`}
                              aria-label="like"
                            >
                              <Heart className={liked ? "w-5 h-5 text-red-500" : "w-5 h-5 text-black"} />
                              <span className="font-semibold">{(post.likes || 0) + (liked ? 1 : 0)}</span>
                            </button>

                            {/* Bookmark */}
                            <button
                              onClick={(e) => { e.stopPropagation(); toggleBookmarkLocal(post); }}
                              className={`flex items-center gap-2 focus:outline-none ${bookmarked ? "scale-110" : "scale-100"} transition-transform duration-200`}
                              aria-label="bookmark"
                            >
                              <Bookmark className={bookmarked ? "w-5 h-5 text-yellow-600" : "w-5 h-5 text-black"} />
                              <span className="font-semibold">{bookmarked ? 1 : 0}</span>
                            </button>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            {/* Posts list (unchanged PostFeed) */}
            <div id="profile-posts-section">
              <h3 className="text-xl font-bold text-pink-200 mb-4">POSTS</h3>

              {loadingPosts ? (
                <p className="text-center text-gray-300">Loading posts...</p>
              ) : postsError ? (
                <p className="text-center text-red-400">Error: {postsError}</p>
              ) : (
                <PostFeed posts={normalizedPosts} variant="profile" />
              )}
            </div>

            {showPostModal && (
              <CreatePost onClose={() => setShowPostModal(false)} addPost={handleAddPost} />
            )}
          </div>
        </div>
      </div>

      {/* Expanded modal for Top-3 (matches PostFeed expanded functionality) */}
      {expandedPost && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          {/* backdrop */}
          <div
            className="absolute inset-0 bg-black/70 backdrop-blur-sm transition-opacity duration-300"
            onClick={closeTopModal}
          />
          <div className="relative w-full max-w-[1100px] h-[700px] bg-white rounded-3xl flex shadow-2xl overflow-hidden transform transition-all duration-300 scale-100">
            <div className="flex-1 bg-gray-200 flex items-center justify-center relative">
              <img src={expandedPost.images[currentImageIndex]} alt="expanded" className="h-full object-cover w-full" />
              {expandedPost.images.length > 1 && (
                <>
                  <button onClick={prevImage} className="absolute left-3 top-1/2 -translate-y-1/2 bg-black/50 text-white p-3 rounded-full hover:bg-black/70 transition-colors">◀</button>
                  <button onClick={nextImage} className="absolute right-3 top-1/2 -translate-y-1/2 bg-black/50 text-white p-3 rounded-full hover:bg-black/70 transition-colors">▶</button>
                </>
              )}
            </div>

            <div className="w-[400px] flex flex-col justify-between p-6">
              <div className="flex items-center gap-3 mb-4">
                <span className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-gray-200 text-xl">👤</span>
                <span className="font-semibold text-black text-lg">{expandedPost.username}</span>
                <button onClick={closeTopModal} className="ml-auto text-2xl font-bold text-gray-700 hover:text-black hover:scale-110 transition-transform duration-200">×</button>
              </div>

              <div className="text-sm text-black mb-2 break-words whitespace-pre-wrap max-w-[100ch]">
                {renderModalDescription(expandedPost.description)}
                {expandedPost.description && expandedPost.description.length > 100 && (
                  <button className="ml-2 text-blue-600 underline" onClick={() => setModalDescExpanded(v => !v)}>
                    {modalDescExpanded ? "Less" : "More"}
                  </button>
                )}
              </div>

              <div className="mb-4 text-sm text-black">
                <p>{expandedPost.gender} | {expandedPost.style}</p>
                <p>{(expandedPost.tags || []).slice(0,3).join(" | ")}</p>
              </div>

              <div className="flex justify-between items-center mb-4 text-2xl">
                <div className="flex items-center gap-2 cursor-pointer" onClick={() => toggleLikeLocal(expandedPost.id)}>
                  <Heart className={likesState[expandedPost.id] ? "w-6 h-6 text-red-500" : "w-6 h-6 text-black"} />
                  <span>{(expandedPost.likes || 0) + (likesState[expandedPost.id] ? 1 : 0)}</span>
                </div>

                <div className="flex items-center gap-2 cursor-pointer" onClick={() => toggleBookmarkLocal(expandedPost)}>
                  <Bookmark className={bookmarksState[expandedPost.id] ? "w-6 h-6 text-yellow-600" : "w-6 h-6 text-black"} />
                  <span>{bookmarksState[expandedPost.id] ? 1 : 0}</span>
                </div>
              </div>

              <div className="flex gap-2 mb-4">
                <input
                  type="text"
                  className="w-full border rounded-lg px-3 py-2 text-black focus:outline-none focus:ring-2 focus:ring-gray-400"
                  placeholder="Write a comment..."
                  value={commentInputs[expandedPost.id] || ""}
                  onChange={e => setCommentInputs(prev => ({ ...prev, [expandedPost.id]: e.target.value }))}
                  onKeyDown={e => { if (e.key === "Enter") handleAddCommentLocal(expandedPost.id); }}
                />
                <button onClick={() => handleAddCommentLocal(expandedPost.id)} className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">Send</button>
              </div>

              <div className="flex-1 overflow-y-auto border-t pt-2">
                {(commentsState[expandedPost.id] || []).map((c, idx) => (
                  <div key={idx} className="flex items-start gap-2 mb-2">
                    <span className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-gray-200 text-xs">👤</span>
                    <div className="text-sm text-black">
                      <p className="font-semibold">{c.username}</p>
                      <p>{c.text}</p>
                    </div>
                  </div>
                ))}
              </div>

            </div>
          </div>
        </div>
      )}
    </div>
  );
}
