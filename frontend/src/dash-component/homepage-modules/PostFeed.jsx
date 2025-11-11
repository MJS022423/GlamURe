import React, { useEffect, useState } from "react";

const EXPRESS_API = import.meta.env.VITE_EXPRESS_API
const token = localStorage.getItem('token');
const userid = localStorage.getItem('userid');
const FEED_DESC_LIMIT = 30; // characters to show in feed
const MODAL_DESC_LIMIT = 100; // characters to show initially in modal

// SVG URLs
const HEART_FALSE = "https://www.svgrepo.com/show/532473/heart.svg";
const HEART_TRUE = "https://www.svgrepo.com/show/535436/heart.svg";
const BOOKMARK_FALSE = "https://www.svgrepo.com/show/533035/bookmark.svg";
const BOOKMARK_TRUE = "https://www.svgrepo.com/show/535228/bookmark.svg";

const CONTAINER_VARIANTS = {
  default: "mt-20 mb-5 w-full max-w-[95%] mx-auto px-5 py-5",
  profile: "mt-8 mb-5 w-full px-0",
};

const GRID_VARIANTS = {
  default: "grid grid-cols-5 justify-items-center gap-8 h-full w-full",
  profile: "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 w-full",
};

export default function PostFeed({ posts, variant = "default" }) {
  const [expandedPost, setExpandedPost] = useState(null);
  const [likesState, setLikesState] = useState({});
  const [bookmarksState, setBookmarksState] = useState({});
  const [commentsState, setCommentsState] = useState({});
  const [commentInputs, setCommentInputs] = useState({});
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [modalDescExpanded, setModalDescExpanded] = useState(false);

  const toggleLike = (postId) => {
    setLikesState(prev => ({ ...prev, [postId]: !prev[postId] }));
  };

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
      } catch  { }
    }

    loadBookmarks();
  }, []);

  //  ######################
  //  Bookmark toggle button
  //  ######################
  
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

  const handleAddComment = (postId) => {
    const input = commentInputs[postId]?.trim();
    if (!input) return;

    setCommentsState(prev => ({
      ...prev,
      [postId]: [...(prev[postId] || []), { username: "Jzar Alaba", text: input }]
    }));

    setCommentInputs(prev => ({ ...prev, [postId]: "" }));
  };

  const openPost = (post) => {
    setExpandedPost(post);
    setCurrentImageIndex(0);
    setModalDescExpanded(false);
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

  const renderFeedDescription = (desc, post) => {
    if (desc.length <= FEED_DESC_LIMIT) return desc;
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
    if (desc.length <= MODAL_DESC_LIMIT) return desc;
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

  const containerClass = CONTAINER_VARIANTS[variant] || CONTAINER_VARIANTS.default;
  const gridClass = GRID_VARIANTS[variant] || GRID_VARIANTS.default;
  const cardClass = variant === "profile"
    ? "border border-gray-700 rounded-lg w-full h-[320px] bg-white flex flex-col p-3 hover:scale-[1.02] shadow-lg transition-transform duration-200 cursor-pointer"
    : "border border-gray-700 rounded-lg w-[240px] h-[320px] bg-white flex flex-col p-3 hover:scale-105 shadow-lg transition-transform duration-200 cursor-pointer";

  return (
    <div className={containerClass}>
      {posts.length === 0 ? (
        <p className="text-center text-gray-500 text-xl mt-20">No posts yet</p>
      ) : (
        <div className={gridClass}>
          {posts.map(post => (
            <div
              key={post.id}
              className={cardClass}
              onClick={() => openPost(post)}
            >
              <div className={`grid ${post.images.length === 1 ? "grid-cols-1" : "grid-cols-2"} gap-1 w-full h-[180px] mb-2`}>
                {post.images.slice(0, 4).map((img, idx) => (
                  <div key={idx} className="relative w-full h-full flex items-center justify-center bg-gray-100 rounded overflow-hidden">
                    <img src={img} alt={`post-${idx}`} className="h-full object-cover transition-transform duration-200 hover:scale-105" />
                    {idx === 3 && post.images.length > 4 && (
                      <div className="absolute inset-0 bg-black/50 flex items-center justify-center text-white text-xl font-bold rounded">
                        +{post.images.length - 4} more
                      </div>
                    )}
                  </div>
                ))}
              </div>

              <div className="text-sm text-black mb-1">
                {renderFeedDescription(post.description, post)}
              </div>

              <div className="mb-2 text-sm text-black">
                <p>{post.gender} | {post.style}</p>
                <p>{post.tags.slice(0, 3).join(" | ")}</p>
              </div>

              <div className="flex justify-between items-center w-full text-black text-sm">
                {/* Heart / Like */}
                <div className="flex items-center gap-1 cursor-pointer" onClick={e => { e.stopPropagation(); toggleLike(post.id); }}>
                  <img
                    src={likesState[post.id] ? HEART_TRUE : HEART_FALSE}
                    alt="heart"
                    className="w-6 h-6"
                  />
                  <span>{post.likes + (likesState[post.id] ? 1 : 0)}</span>
                </div>
                {/* Bookmark */}
                <div className="flex items-center gap-1 cursor-pointer" onClick={e => { e.stopPropagation(); toggleBookmark(post); }}>
                  <img src={bookmarksState[post.id] ? BOOKMARK_TRUE : BOOKMARK_FALSE} alt="bookmark" className="w-6 h-6" />
                  <span>{bookmarksState[post.id] ? 1 : 0}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

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
                  onKeyDown={e => { if (e.key === "Enter") handleAddComment(expandedPost.id); }}
                />
                <button onClick={() => handleAddComment(expandedPost.id)} className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">Send</button>
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