import { useState, useEffect } from "react";
import CreatePost from "./homepage-modules/CreatePost";
import PostFeed from "./homepage-modules/PostFeed";
import { Heart, Plus, User, Bookmark } from "lucide-react";

const EXPRESS_API = import.meta.env.VITE_EXPRESS_API;
const token = localStorage.getItem('token');
const userid = localStorage.getItem('userid');
const username = localStorage.getItem('username') || 'Anonymous';

// SVG URLs
const HEART_FALSE = "https://www.svgrepo.com/show/532473/heart.svg";
const HEART_TRUE = "https://www.svgrepo.com/show/535436/heart.svg";
const BOOKMARK_FALSE = "https://www.svgrepo.com/show/533035/bookmark.svg";
const BOOKMARK_TRUE = "https://www.svgrepo.com/show/535228/bookmark.svg";

export default function ProfilePage() {
  const [showPostModal, setShowPostModal] = useState(false);
  const [stats, setStats] = useState({ totalPosts: 0, totalLikes: 0 });
  const [info, setInfo] = useState({ email: "", socialMedia: {}, contact: "" });
  const [isEditing, setIsEditing] = useState(false);
  const [editData, setEditData] = useState({ socialMedia: {}, contact: "" });
  const [topDesigns, setTopDesigns] = useState([]);
  const [userPosts, setUserPosts] = useState([]);
  const [expandedPost, setExpandedPost] = useState(null);
  const [likesState, setLikesState] = useState({});
  const [bookmarksState, setBookmarksState] = useState({});
  const [commentsState, setCommentsState] = useState({});
  const [commentInputs, setCommentInputs] = useState({});
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [modalDescExpanded, setModalDescExpanded] = useState(false);
  const [isSending, setIsSending] = useState(false);


  // Get user data from localStorage
  const profileName = localStorage.getItem("profile_name") || "User";
  const userRole = localStorage.getItem("userRole") || "Designer";
  const profileAvatar = localStorage.getItem("profile_avatar");

  // Sample data (update with actual backend data if available)
  const designer = {
    name: userRole, // Use userRole for type
    email: info.email,
    likes: stats.totalLikes,
    followers: 0,
    posts: stats.totalPosts,
    facebook: info.socialMedia.facebook || "",
    instagram: info.socialMedia.instagram || "",
    threads: info.socialMedia.threads || "",
    twitter: info.socialMedia.twitter || "",
    contact: info.contact,
  };

  const toggleLike = async (postId) => {
    const currentLiked = likesState[postId] || false;
    const newLiked = !currentLiked;

    // Optimistically update UI
    setLikesState(prev => ({ ...prev, [postId]: newLiked }));

    try {
      const res = await fetch(`${EXPRESS_API}/like/ToggleLike?postId=${postId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });
      const data = await res.json();
      if (data.success) {
        // Update the post's likes in the topDesigns and userPosts
        setTopDesigns(prev => prev.map(post => post.id === postId ? { ...post, likes: data.likes } : post));
        setUserPosts(prev => prev.map(post => post.id === postId ? { ...post, likes: data.likes } : post));
      } else {
        // Revert on failure
        setLikesState(prev => ({ ...prev, [postId]: currentLiked }));
        console.error("Failed to toggle like:", data.error);
      }
    } catch (err) {
      // Revert on error
      setLikesState(prev => ({ ...prev, [postId]: currentLiked }));
      console.error("Error toggling like:", err);
    }
  };

  const toggleBookmark = async (post) => {
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
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({ newItem }),
        });
      } else {
        await fetch(`${EXPRESS_API}/bookmark/RemoveBookmark?userId=${userid}`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({ postId: post.id }),
        });
      }
    } catch (err) {
      console.error("Bookmark update failed:", err);
      setBookmarksState(prev => ({ ...prev, [postId]: !next }));
    }
  };

  const openPost = async (post) => {
    setExpandedPost(post);
    setCurrentImageIndex(0);
    setModalDescExpanded(false);

    // Fetch comments for the post
    try {
      const res = await fetch(`${EXPRESS_API}/comment/Displaycomment?postid=${post.id}`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      const data = await res.json();
      if (data.comments) {
        setCommentsState(prev => ({ ...prev, [post.id]: data.comments }));
      }
    } catch (err) {
      console.error("Failed to fetch comments:", err);
    }
  };

  const closePost = () => setExpandedPost(null);

  const nextImage = () => {
    if (!expandedPost) return;
    setCurrentImageIndex(prev => (prev + 1 < expandedPost.images.length ? prev + 1 : 0));
  };

  const prevImage = () => {
    if (!expandedPost) return;
    setCurrentImageIndex(prev => (prev - 1 >= 0 ? prev - 1 : expandedPost.images.length - 1));
  };

  const handleAddComment = async (postId) => {
    const input = commentInputs[postId]?.trim();
    if (!input) return;

    setIsSending(true);
    try {
      const res = await fetch(`${EXPRESS_API}/comment/Addcomment?Userid=${userid}&postid=${postId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ comment: input, username }),
      });
      const data = await res.json();
      if (data.success) {
        // Add to local state with username
        setCommentsState(prev => ({
          ...prev,
          [postId]: [...(prev[postId] || []), { username, text: input }]
        }));
        setCommentInputs(prev => ({ ...prev, [postId]: "" }));
      } else {
        console.error("Failed to add comment:", data.error);
      }
    } catch (err) {
      console.error("Error adding comment:", err);
    } finally {
      setIsSending(false);
    }
  };

  const renderFeedDescription = (desc, post) => {
    const FEED_DESC_LIMIT = 30;
    if (!desc || desc.length <= FEED_DESC_LIMIT) return desc || "";
    return (
      <>
        {desc.slice(0, FEED_DESC_LIMIT)}...
        <span
          className="ml-1 text-blue-600 cursor-pointer hover:underline"
          onClick={() => openPost(post)}
        >
          More
        </span>
      </>
    );
  };

  const renderModalDescription = (desc) => {
    const MODAL_DESC_LIMIT = 100;
    if (!desc || desc.length <= MODAL_DESC_LIMIT) return desc || "";
    return (
      <>
        {modalDescExpanded ? desc : desc.slice(0, MODAL_DESC_LIMIT) + "... "}
        <span
          className="text-blue-600 cursor-pointer hover:underline"
          onClick={() => setModalDescExpanded(prev => !prev)}
        >
          {modalDescExpanded ? "Less" : "More"}
        </span>
      </>
    );
  };

  useEffect(() => {
    async function fetchData() {
      try {
        const [statsRes, postsRes] = await Promise.all([
          fetch(`${EXPRESS_API}/auth/ProfileStats`, {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }),
          fetch(`${EXPRESS_API}/post/DisplayPost`, {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          })
        ]);

        const statsData = await statsRes.json();
        const postsData = await postsRes.json();

        if (statsData.success) {
          setStats(statsData.stats);
          setInfo(statsData.info);
          setEditData({ socialMedia: statsData.info.socialMedia || {}, contact: statsData.info.contact || "" });
        }

        if (postsData.success) {
          // Filter posts by current user
          const userPosts = postsData.results.filter(post => post.userId === localStorage.getItem('userid'));
          // Sort by likes descending for top 3 designs
          const sortedPosts = userPosts.sort((a, b) => b.likes - a.likes);
          const top3 = sortedPosts.slice(0, 3);
          setTopDesigns(top3);
          setUserPosts(userPosts);
        }
      } catch (err) {
        console.error("Failed to fetch data:", err);
      }
    }

    fetchData();
  }, []);

  useEffect(() => {
    async function loadBookmarks() {
      try {
        const res = await fetch(`${EXPRESS_API}/bookmark/DisplayBookmark?userId=${userid}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });
        const data = await res.json();
        if (data.success) {
          const map = data.bookmarks.reduce((acc, item) => {
            acc[item.id] = true;
            return acc;
          }, {});
          setBookmarksState(map);
        }
      } catch (err) {
        console.error("Failed to load bookmarks:", err);
      }
    }

    loadBookmarks();
  }, []);

  return (
    <div className="flex flex-col min-h-screen bg-gradient-to-b from-[#1b1b1b] via-[#2b2b2b] to-[#f9c5d1] text-white overflow-y-auto no-scrollbar">
      {/* Header */}
      <div className="bg-[#1b1b1b] backdrop-blur-sm border-b border-pink-300 p-6 flex items-center justify-between sticky top-0 z-10">
        <div className="flex items-center">
          <h1 className="text-4xl font-extrabold text-pink-200 tracking-wide">
            PROFILE
          </h1>
        </div>

        <div className="flex items-center gap-2">
          <div className="text-3xl font-extrabold text-pink-200">Glamure</div>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-8 flex-1">
        <div className="flex flex-col lg:flex-row gap-10">
          <div className="lg:w-1/3">
            <div className="bg-pink-100 text-black rounded-3xl p-6 mb-6 shadow-md">
              <div className="flex items-center gap-4 mb-6">
                {/* Left Side - Profile Info */}
                <div className="w-24 h-24 bg-pink-300 rounded-full flex items-center justify-center overflow-hidden">
                  {profileAvatar ? (
                    <img
                      src={profileAvatar}
                      alt="Profile Avatar"
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <User className="w-12 h-12 text-black" />
                  )}
                </div>
                <div>
                  <h2 className="text-xl font-bold text-pink-900">{profileName}</h2>
                  <h4 className="text-md font-semibold text-pink-800">{username}</h4>
                  <p className="text-black">{userRole}</p>
                </div>
              </div>

              {/* Stats */}
              <div className="flex justify-around mb-6">
                <div className="text-center">
                  <div className="text-xs font-semibold text-pink-700 mb-1">
                    LIKES
                  </div>
                  <div className="text-lg font-bold text-black">
                    {designer.likes}
                  </div>
                </div>
                <div className="text-center">
                  <div className="text-xs font-semibold text-pink-700 mb-1">
                    POSTS
                  </div>
                  <div className="text-lg font-bold text-black">
                    {userPosts.length}
                  </div>
                </div>
              </div>

              <button onClick={() => setShowPostModal(true)} className="w-full bg-black text-pink-200 font-semibold py-3 rounded-full flex items-center justify-center gap-2 hover:bg-pink-300 hover:text-black transition">
                <Plus className="w-5 h-5" />
                Add Post
              </button>
            </div>

            <div className="bg-pink-100 text-black rounded-3xl p-6 shadow-md">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-bold">{profileName}'s Information</h3>
                <button
                  onClick={() => setIsEditing(!isEditing)}
                  className="bg-pink-500 text-white px-3 py-1 rounded-full text-sm hover:bg-pink-600 transition"
                >
                  {isEditing ? "Cancel" : "Edit"}
                </button>
              </div>
              <div className="space-y-2 text-sm">
                <p>
                  <span className="font-semibold">E-MAIL:</span>{" "}
                  {designer.email}
                </p>
                <p className="font-semibold">Social Medias:</p>
                {isEditing ? (
                  <>
                    <div className="flex items-center gap-2">
                      <label className="text-xs">FB:</label>
                      <input
                        type="text"
                        value={editData.socialMedia.facebook || ""}
                        onChange={(e) => setEditData(prev => ({
                          ...prev,
                          socialMedia: { ...prev.socialMedia, facebook: e.target.value }
                        }))}
                        className="border border-pink-300 rounded px-2 py-1 text-xs flex-1"
                        placeholder="Facebook username"
                      />
                    </div>
                    <div className="flex items-center gap-2">
                      <label className="text-xs">IG:</label>
                      <input
                        type="text"
                        value={editData.socialMedia.instagram || ""}
                        onChange={(e) => setEditData(prev => ({
                          ...prev,
                          socialMedia: { ...prev.socialMedia, instagram: e.target.value }
                        }))}
                        className="border border-pink-300 rounded px-2 py-1 text-xs flex-1"
                        placeholder="Instagram username"
                      />
                    </div>
                    <div className="flex items-center gap-2">
                      <label className="text-xs">Threads:</label>
                      <input
                        type="text"
                        value={editData.socialMedia.threads || ""}
                        onChange={(e) => setEditData(prev => ({
                          ...prev,
                          socialMedia: { ...prev.socialMedia, threads: e.target.value }
                        }))}
                        className="border border-pink-300 rounded px-2 py-1 text-xs flex-1"
                        placeholder="Threads username"
                      />
                    </div>
                    <div className="flex items-center gap-2">
                      <label className="text-xs">Twitter:</label>
                      <input
                        type="text"
                        value={editData.socialMedia.twitter || ""}
                        onChange={(e) => setEditData(prev => ({
                          ...prev,
                          socialMedia: { ...prev.socialMedia, twitter: e.target.value }
                        }))}
                        className="border border-pink-300 rounded px-2 py-1 text-xs flex-1"
                        placeholder="Twitter username"
                      />
                    </div>
                  </>
                ) : (
                  <>
                    <p>FB: {designer.facebook || "Not set"}</p>
                    <p>IG: {designer.instagram || "Not set"}</p>
                    <p>Threads: {designer.threads || "Not set"}</p>
                    <p>Twitter: {designer.twitter || "Not set"}</p>
                  </>
                )}
                <div className="flex items-center gap-2">
                  <span className="font-semibold">CONTACT:</span>
                  {isEditing ? (
                    <input
                      type="text"
                      value={editData.contact}
                      onChange={(e) => setEditData(prev => ({ ...prev, contact: e.target.value }))}
                      className="border border-pink-300 rounded px-2 py-1 text-xs flex-1"
                      placeholder="Contact number"
                    />
                  ) : (
                    <span>{designer.contact || "Not set"}</span>
                  )}
                </div>
                {isEditing && (
                  <button
                    onClick={async () => {
                      try {
                        const res = await fetch(`${EXPRESS_API}/auth/UpdateDesignerInfo`, {
                          method: "POST",
                          headers: {
                            "Content-Type": "application/json",
                            Authorization: `Bearer ${token}`,
                          },
                          body: JSON.stringify(editData),
                        });
                        const data = await res.json();
                        if (data.success) {
                          setInfo(prev => ({ ...prev, socialMedia: editData.socialMedia, contact: editData.contact }));
                          setIsEditing(false);
                          alert("Designer info updated successfully!");
                        } else {
                          alert("Failed to update: " + data.error);
                        }
                      } catch (err) {
                        console.error("Error updating designer info:", err);
                        alert("Error updating designer info");
                      }
                    }}
                    className="bg-green-500 text-white px-4 py-2 rounded-full text-sm hover:bg-green-600 transition mt-2"
                  >
                    Save Changes
                  </button>
                )}
              </div>
            </div>
          </div>

          {/* Right Side - Designs */}
          <div className="flex-1">
            {/* Top 3 Designs */}
            <div className="mb-8">
              <div className="flex items-center gap-2 mb-4">
                <h3 className="text-xl font-bold text-pink-200">
                  TOP 3 DESIGNS
                </h3>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {topDesigns.length > 0 ? (
                  topDesigns.map((design) => (
                    <div
                      key={design.id}
                      className="bg-pink-100 text-black rounded-2xl overflow-hidden shadow-md cursor-pointer hover:scale-[1.02] transition-transform duration-200"
                      onClick={() => openPost(design)}
                    >
                      <div className={`grid ${design.images.length === 1 ? "grid-cols-1" : "grid-cols-2"} gap-1 w-full h-[180px] mb-2`}>
                        {design.images.slice(0, 4).map((img, idx) => (
                          <div key={idx} className="relative w-full h-full flex items-center justify-center bg-gray-100 rounded overflow-hidden">
                            <img src={img} alt={`design-${idx}`} className="h-full object-cover transition-transform duration-200 hover:scale-105" />
                            {idx === 3 && design.images.length > 4 && (
                              <div className="absolute inset-0 bg-black/50 flex items-center justify-center text-white text-xl font-bold rounded">
                                +{design.images.length - 4} more
                              </div>
                            )}
                          </div>
                        ))}
                      </div>

                      <div className="text-sm text-black mb-1 px-3">
                        {renderFeedDescription(design.description, design)}
                      </div>

                      <div className="mb-2 text-sm text-black px-3">
                        <p>{design.gender} | {design.style}</p>
                        <p>{design.tags.slice(0, 3).join(" | ")}</p>
                      </div>

                      <div className="flex justify-between items-center w-full text-black text-sm px-3 pb-3">
                        {/* Heart / Like */}
                        <div className="flex items-center gap-1 cursor-pointer" onClick={e => { e.stopPropagation(); toggleLike(design.id); }}>
                          <img
                            src={likesState[design.id] ? HEART_TRUE : HEART_FALSE}
                            alt="heart"
                            className="w-6 h-6"
                          />
                          <span>{design.likes + (likesState[design.id] ? 1 : 0)}</span>
                        </div>
                        {/* Bookmark */}
                        <div className="flex items-center gap-1 cursor-pointer" onClick={e => { e.stopPropagation(); toggleBookmark(design); }}>
                          <img src={bookmarksState[design.id] ? BOOKMARK_TRUE : BOOKMARK_FALSE} alt="bookmark" className="w-6 h-6" />
                        </div>
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="col-span-full text-center text-pink-200 font-semibold">
                    No ranking yet
                  </div>
                )}
              </div>
            </div>

            {/* Posts */}
            <div>
              <h3 className="text-xl font-bold text-pink-200 mb-4">POSTS</h3>
              <PostFeed posts={userPosts} variant="profile" />
            </div>
            {showPostModal && (
              <CreatePost onClose={() => setShowPostModal(false)} addPost={() => setShowPostModal(false)} />
            )}
          </div>
        </div>
      </div>

      {/* Expanded Modal */}
      {expandedPost && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70">
          <div className="relative max-w-[95%] h-[700px] bg-white rounded-3xl flex shadow-2xl overflow-hidden">
            <div className="flex-1 bg-gray-200 flex items-center justify-center relative">
              <img src={expandedPost.images[currentImageIndex]} alt="expanded" className="h-full object-cover" />
              {expandedPost.images.length > 1 && (
                <>
                  <button onClick={prevImage} className="absolute left-2 top-1/2 -translate-y-1/2 bg-black/50 text-white p-3 rounded-full hover:bg-black/70 transition-colors">◀</button>
                  <button onClick={nextImage} className="absolute right-2 top-1/2 -translate-y-1/2 bg-black/50 text-white p-3 rounded-full hover:bg-black/70 transition-colors">▶</button>
                </>
              )}
            </div>

            <div className="w-[400px] flex flex-col justify-between p-6">
              <div className="flex items-center gap-3 mb-4">
                <span className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-gray-200 text-xl">👤</span>
                <span className="font-semibold text-black text-lg">{expandedPost.username}</span>
                <button onClick={closePost} className="ml-auto text-2xl font-bold text-gray-700 hover:text-black hover:scale-110 transition-transform duration-200">×</button>
              </div>

              <div className="text-sm text-black mb-2 break-words whitespace-pre-wrap max-w-[100ch]">
                {renderModalDescription(expandedPost.description)}
              </div>

              <div className="mb-4 text-sm text-black">
                <p>{expandedPost.gender} | {expandedPost.style}</p>
                <p>{expandedPost.tags.slice(0, 3).join(" | ")}</p>
              </div>

              {/* Icons row: Heart left, Bookmark right */}
              <div className="flex justify-between items-center mb-4 text-2xl">
                <div className="flex items-center gap-1 cursor-pointer" onClick={() => toggleLike(expandedPost.id)}>
                  <img src={likesState[expandedPost.id] ? HEART_TRUE : HEART_FALSE} alt="heart" className="w-6 h-6" />
                  <span>{expandedPost.likes + (likesState[expandedPost.id] ? 1 : 0)}</span>
                </div>
                <div className="flex items-center gap-1 cursor-pointer" onClick={() => toggleBookmark(expandedPost)}>
                  <img src={bookmarksState[expandedPost.id] ? BOOKMARK_TRUE : BOOKMARK_FALSE} alt="bookmark" className="w-6 h-6" />
                </div>
              </div>

              <div className="flex gap-2 mb-4">
                <input
                  type="text"
                  className="w-full border rounded-lg px-3 py-2 text-black focus:outline-none focus:ring-2 focus:ring-gray-400"
                  placeholder="Write a comment..."
                  value={commentInputs[expandedPost.id] || ""}
                  onChange={e => setCommentInputs(prev => ({ ...prev, [expandedPost.id]: e.target.value }))}
                  onKeyDown={e => { if (e.key === "Enter") handleAddComment(expandedPost.id); }}
                />
                <button
                  onClick={() => handleAddComment(expandedPost.id)}
                  disabled={isSending}
                  className={`px-4 py-2 rounded-lg transition-all duration-200 ${
                    isSending
                      ? 'bg-gray-400 text-gray-200 cursor-not-allowed scale-95'
                      : 'bg-black text-white hover:bg-red-200 hover:text-black hover:scale-105'
                  }`}
                >
                  {isSending ? 'Sending...' : 'Send'}
                </button>
              </div>

              <div className="flex-1 overflow-y-auto border-t pt-2">
                {(commentsState[expandedPost.id] || []).map((c, idx) => (
                  <div key={idx} className="flex items-start gap-2 mb-2">
                    <span className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-gray-200 text-xs">👤</span>
                    <div className="text-sm text-black">
                      <p className="font-semibold">{c.username || 'Anonymous'}</p>
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
