import React, { useState } from "react";

export default function PostFeed({ posts }) {
  const [expandedPost, setExpandedPost] = useState(null);
  const [likesState, setLikesState] = useState({});
  const [bookmarksState, setBookmarksState] = useState({});
  const [commentsState, setCommentsState] = useState({});
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [commentInput, setCommentInput] = useState("");

  const toggleLike = (postId) => {
    setLikesState((prev) => {
      const liked = !prev[postId];
      const post = posts.find(p => p.id === postId);
      if (post) {
        post.likes = liked ? post.likes + 1 : post.likes - 1;
      }
      return { ...prev, [postId]: liked };
    });
  };

  const toggleBookmark = (postId) => {
    setBookmarksState((prev) => ({ ...prev, [postId]: !prev[postId] }));
  };

  const handleAddComment = (postId) => {
    if (!commentInput.trim()) return;
    setCommentsState((prev) => ({
      ...prev,
      [postId]: [
        ...(prev[postId] || []),
        { username: "Jzar Alaba", text: commentInput.trim() },
      ],
    }));
    setCommentInput("");
  };

  const openPost = (post) => {
    setExpandedPost(post);
    setCurrentImageIndex(0);
  };

  const closePost = () => setExpandedPost(null);

  const nextImage = () => {
    if (expandedPost) {
      setCurrentImageIndex((prev) =>
        prev + 1 < expandedPost.images.length ? prev + 1 : 0
      );
    }
  };

  const prevImage = () => {
    if (expandedPost) {
      setCurrentImageIndex((prev) =>
        prev - 1 >= 0 ? prev - 1 : expandedPost.images.length - 1
      );
    }
  };

  return (
    <div className="mt-20 mb-5 w-full max-w-[95%] mx-auto px-5 py-5">
      {posts.length === 0 ? (
        <p className="text-center text-gray-500 text-xl mt-20">No posts yet</p>
      ) : (
        <div className="grid grid-cols-5 justify-items-center gap-8 h-full w-full">
          {posts.map((post) => (
            <div
              key={post.id}
              className="border border-gray-700 rounded-lg w-[240px] h-[320px] bg-white flex flex-col p-3 hover:scale-105 shadow-lg transition-transform duration-200 cursor-pointer"
              onClick={() => openPost(post)}
            >
              <div className="grid grid-cols-2 gap-1 w-full h-[180px] mb-2">
                {post.images.slice(0, 4).map((img, idx) => (
                  <div key={idx} className="relative w-full h-full">
                    <img
                      src={img}
                      alt={`post-${idx}`}
                      className="w-full h-full object-cover rounded hover:scale-105 transition-transform duration-200"
                    />
                    {idx === 3 && post.images.length > 4 && (
                      <div className="absolute inset-0 bg-black/50 flex items-center justify-center text-white text-xl font-bold rounded">
                        +{post.images.length - 4} more
                      </div>
                    )}
                  </div>
                ))}
              </div>

              {/* Description */}
              <p className="text-sm text-black mb-1 line-clamp-3">{post.description}</p>

              {/* Display Gender, Style, and Tags */}
              <div className="mb-2 text-sm text-black">
                <p>{post.gender} | {post.style}</p>
                <p>{post.tags.slice(0,3).join(' | ')}</p>
              </div>

              <div className="flex justify-between items-center w-full text-black text-sm">
                <div
                  className="flex items-center gap-1 cursor-pointer"
                  onClick={(e) => {
                    e.stopPropagation();
                    toggleLike(post.id);
                  }}
                >
                  <span
                    className={`text-lg ${likesState[post.id] ? "text-blue-600" : "text-red-600"}`}
                  >
                    ❤️
                  </span>
                  <span>{post.likes}</span>
                </div>
                <div
                  className="flex items-center gap-1 cursor-pointer"
                  onClick={(e) => {
                    e.stopPropagation();
                    toggleBookmark(post.id);
                  }}
                >
                  <span
                    className={`text-lg ${bookmarksState[post.id] ? "text-blue-600" : "text-gray-600"}`}
                  >
                    🔖
                  </span>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal */}
      {expandedPost && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70">
          <div className="relative w-[1000px] max-w-[95%] h-[700px] bg-white rounded-3xl flex shadow-2xl overflow-hidden">
            {/* Left Image */}
            <div className="w-1/2 bg-gray-200 flex items-center justify-center relative">
              <img
                src={expandedPost.images[currentImageIndex]}
                alt="expanded"
                className="w-full h-full object-cover"
              />
              {expandedPost.images.length > 1 && (
                <>
                  <button
                    onClick={prevImage}
                    className="absolute left-2 top-1/2 -translate-y-1/2 bg-black/50 text-white p-3 rounded-full hover:bg-black/70 transition-colors"
                  >
                    ◀
                  </button>
                  <button
                    onClick={nextImage}
                    className="absolute right-2 top-1/2 -translate-y-1/2 bg-black/50 text-white p-3 rounded-full hover:bg-black/70 transition-colors"
                  >
                    ▶
                  </button>
                </>
              )}
            </div>

            {/* Right Panel */}
            <div className="w-1/2 flex flex-col justify-between p-6">
              {/* Header */}
              <div className="flex items-center gap-3 mb-4">
                <span className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-gray-200 text-xl">
                  👤
                </span>
                <span className="font-semibold text-black text-lg">
                  {expandedPost.username}
                </span>
                <button
                  onClick={closePost}
                  className="ml-auto text-2xl font-bold text-gray-700 hover:text-black hover:scale-110 transition-transform duration-200"
                >
                  ×
                </button>
              </div>

              {/* Description */}
              <p className="text-sm text-black mb-2">{expandedPost.description}</p>

              {/* Display Gender, Style, Tags */}
              <div className="mb-4 text-sm text-black">
                <p>{expandedPost.gender} | {expandedPost.style}</p>
                <p>{expandedPost.tags.slice(0,3).join(' | ')}</p>
              </div>

              {/* Interaction Icons */}
              <div className="flex items-center gap-6 mb-4 text-2xl">
                <button
                  onClick={() => toggleLike(expandedPost.id)}
                  className={`${likesState[expandedPost.id] ? "text-blue-600" : "text-red-600"}`}
                >
                  ❤️
                </button>
                <button
                  onClick={() => toggleBookmark(expandedPost.id)}
                  className={`${bookmarksState[expandedPost.id] ? "text-blue-600" : "text-gray-600"}`}
                >
                  🔖
                </button>
              </div>

              {/* Comment Input */}
              <div className="flex gap-2 mb-4">
                <input
                  type="text"
                  className="w-full border rounded-lg px-3 py-2 text-black focus:outline-none focus:ring-2 focus:ring-gray-400"
                  placeholder="Write a comment..."
                  value={commentInput}
                  onChange={(e) => setCommentInput(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === "Enter") handleAddComment(expandedPost.id);
                  }}
                />
                <button
                  onClick={() => handleAddComment(expandedPost.id)}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                >
                  Send
                </button>
              </div>

              {/* Comments List */}
              <div className="flex-1 overflow-y-auto border-t pt-2">
                {(commentsState[expandedPost.id] || []).map((c, idx) => (
                  <div key={idx} className="flex items-start gap-2 mb-2">
                    <span className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-gray-200 text-xs">
                      👤
                    </span>
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

      <style jsx>{`
        .no-scrollbar::-webkit-scrollbar {
          display: none;
        }
        .no-scrollbar {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
    </div>
  );
}
