import React, { useEffect, useState } from "react";
import { X } from "lucide-react";

const FEED_DESC_LIMIT = 30;
const MODAL_DESC_LIMIT = 100;

const HEART_FALSE = "https://www.svgrepo.com/show/532473/heart.svg";
const HEART_TRUE = "https://www.svgrepo.com/show/535436/heart.svg";
const BOOKMARK_TRUE = "https://www.svgrepo.com/show/535228/bookmark.svg";

const GlamureBookmarks = () => {
  const [selectedPost, setSelectedPost] = useState(null);
  const [savedPosts, setSavedPosts] = useState([]);
  const [likesState, setLikesState] = useState({});
  const [commentsState, setCommentsState] = useState({});
  const [commentInputs, setCommentInputs] = useState({});
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [modalDescExpanded, setModalDescExpanded] = useState(false);

  useEffect(() => {
    try {
      const saved = JSON.parse(localStorage.getItem("bookmarks") || "[]");
      setSavedPosts(saved);
      
      // Initialize likes state from saved posts
      const initialLikes = {};
      saved.forEach(post => {
        initialLikes[post.id] = false;
      });
      setLikesState(initialLikes);
    } catch (error) {
      console.error('Error loading bookmarks:', error);
    }

    const onStorage = (e) => {
      if (e.key === "bookmarks") {
        try {
          const saved = JSON.parse(e.newValue || "[]");
          setSavedPosts(saved);
        } catch (error) {
          console.error('Error handling storage event:', error);
        }
      }
    };
    window.addEventListener("storage", onStorage);
    return () => window.removeEventListener("storage", onStorage);
  }, []);

  const toggleLike = (postId) => {
    setLikesState(prev => ({ ...prev, [postId]: !prev[postId] }));
  };

  const removeBookmark = (postId) => {
    try {
      const updatedPosts = savedPosts.filter(post => post.id !== postId);
      setSavedPosts(updatedPosts);
      localStorage.setItem("bookmarks", JSON.stringify(updatedPosts));
      
      // If the removed post is currently selected, close the modal
      if (selectedPost?.id === postId) {
        setSelectedPost(null);
      }
    } catch (error) {
      console.error('Error removing bookmark:', error);
    }
  };

  const handleAddComment = (postId) => {
    const input = commentInputs[postId]?.trim();
    if (!input) return;

    setCommentsState(prev => ({
      ...prev,
      [postId]: [...(prev[postId] || []), { username: "User", text: input }]
    }));

    setCommentInputs(prev => ({ ...prev, [postId]: "" }));
  };

  const openPost = (post) => {
    setSelectedPost(post);
    setCurrentImageIndex(0);
    setModalDescExpanded(false);
  };

  const closePost = () => setSelectedPost(null);

  const nextImage = () => {
    if (!selectedPost?.images?.length) return;
    setCurrentImageIndex(prev => (prev + 1 < selectedPost.images.length ? prev + 1 : 0));
  };

  const prevImage = () => {
    if (!selectedPost?.images?.length) return;
    setCurrentImageIndex(prev => (prev - 1 >= 0 ? prev - 1 : selectedPost.images.length - 1));
  };

  const renderDescription = (desc, limit = FEED_DESC_LIMIT, post = null) => {
    if (!desc || desc.length <= limit) return desc;
    if (post) {
      return (
        <>
          {desc.slice(0, limit)}...
          <span
            className="ml-1 text-blue-600 cursor-pointer hover:underline"
            onClick={(e) => { e.stopPropagation(); openPost(post); }}
          >
            More
          </span>
        </>
      );
    }
    return (
      <>
        {modalDescExpanded ? desc : desc.slice(0, limit)}
        <span
          className="ml-1 text-blue-600 cursor-pointer hover:underline"
          onClick={() => setModalDescExpanded(prev => !prev)}
        >
          {modalDescExpanded ? " Show less" : "... Show more"}
        </span>
      </>
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-[#1b1b1b] via-[#2b2b2b] to-[#f9c5d1]">
      {/* Header */}
      <div className="sticky top-0 z-50 bg-[#1b1b1b] border-b border-pink-300 py-6 px-8">
  <div className="max-w-10xl mx-auto flex items-center justify-start">
    <h1 className="text-4xl font-bold text-white">BOOKMARKS</h1>
  </div>
</div>

      {/* Section Title */}
      <div className="max-w-7xl mx-auto px-8 mt-12">
        <h2 className="text-2xl font-semibold text-pink-400 mb-2 text-center">
          ~Saved Designs~
        </h2>
      </div>

      {/* Main Content */}
  <div className="mt-20 mb-5 w-full max-w-[95%] mx-auto px-5 py-5">
        {savedPosts.length === 0 ? (
          <div className="text-center text-gray-500 py-12">
            No bookmarks yet. Save posts using the bookmark icon.
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 justify-items-center gap-8">
            {savedPosts.map(post => (
              <div
                key={post.id}
                className="border border-gray-700 rounded-lg w-[240px] h-[320px] bg-white flex flex-col p-3 hover:scale-105 shadow-lg transition-transform duration-200 cursor-pointer"
                onClick={() => openPost(post)}
              >
                <div className={`grid ${post.images?.length === 1 ? "grid-cols-1" : "grid-cols-2"} gap-1 w-full h-[180px] mb-2`}>
                  {(post.images || [post.image]).slice(0, 4).map((img, idx) => (
                    <div key={idx} className="relative w-full h-full flex items-center justify-center bg-gray-100 rounded overflow-hidden">
                      <img src={img} alt={`post-${idx}`} className="max-w-full max-h-full object-contain transition-transform duration-200 hover:scale-105" />
                      {idx === 3 && post.images?.length > 4 && (
                        <div className="absolute inset-0 bg-black/50 flex items-center justify-center text-white text-xl font-bold rounded">
                          +{post.images.length - 4} more
                        </div>
                      )}
                    </div>
                  ))}
                </div>

                <div className="text-sm text-black mb-1">
                  {renderDescription(post.description, FEED_DESC_LIMIT, post)}
                </div>

                <div className="mb-2 text-sm text-black">
                  {post.gender && <p>{post.gender} | {post.style}</p>}
                  {post.tags && <p>{post.tags.slice(0, 3).join(" | ")}</p>}
                </div>

                <div className="flex justify-between items-center w-full text-black text-sm mt-auto">
                  <div className="flex items-center gap-1 cursor-pointer" onClick={e => { e.stopPropagation(); toggleLike(post.id); }}>
                    <img 
                      src={likesState[post.id] ? HEART_TRUE : HEART_FALSE} 
                      alt="heart" 
                      className="w-6 h-6" 
                    />
                    <span>{(post.likes || 0) + (likesState[post.id] ? 1 : 0)}</span>
                  </div>
                  <div className="flex items-center gap-1 cursor-pointer" onClick={e => { e.stopPropagation(); removeBookmark(post.id); }}>
                    <img src={BOOKMARK_TRUE} alt="bookmark" className="w-6 h-6" />
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Expanded Modal */}
      {selectedPost && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70">
          <div className="relative max-w-[95%] h-[700px] bg-white rounded-3xl flex shadow-2xl overflow-hidden">
            <div className="flex-1 bg-gray-200 flex items-center justify-center relative">
              <img 
                src={selectedPost.images?.[currentImageIndex] || selectedPost.image} 
                alt="expanded" 
                className="h-full object-cover" 
              />
              {selectedPost.images?.length > 1 && (
                <>
                  <button onClick={prevImage} className="absolute left-2 top-1/2 -translate-y-1/2 bg-black/50 text-white p-3 rounded-full hover:bg-black/70 transition-colors">◀</button>
                  <button onClick={nextImage} className="absolute right-2 top-1/2 -translate-y-1/2 bg-black/50 text-white p-3 rounded-full hover:bg-black/70 transition-colors">▶</button>
                </>
              )}
            </div>

            <div className="w-[400px] flex flex-col justify-between p-6">
              <div className="flex items-center gap-3 mb-4">
                <span className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-gray-200 text-xl">👤</span>
                <span className="font-semibold text-black text-lg">{selectedPost.username}</span>
                <button onClick={closePost} className="ml-auto text-2xl font-bold text-gray-700 hover:text-black hover:scale-110 transition-transform duration-200">×</button>
              </div>

              <div className="text-sm text-black mb-2 break-words whitespace-pre-wrap max-w-[100ch]">
                {renderDescription(selectedPost.description, MODAL_DESC_LIMIT)}
              </div>

              <div className="mb-4 text-sm text-black">
                {selectedPost.gender && <p>{selectedPost.gender} | {selectedPost.style}</p>}
                {selectedPost.tags && <p>{selectedPost.tags.slice(0, 3).join(" | ")}</p>}
              </div>

              {/* Icons row: Heart left, Bookmark right */}
              <div className="flex justify-between items-center mb-4 text-2xl">
                <div className="flex items-center gap-1 cursor-pointer" onClick={() => toggleLike(selectedPost.id)}>
                  <img src={likesState[selectedPost.id] ? HEART_TRUE : HEART_FALSE} alt="heart" className="w-6 h-6" />
                  <span>{(selectedPost.likes || 0) + (likesState[selectedPost.id] ? 1 : 0)}</span>
                </div>
                <div className="flex items-center gap-1 cursor-pointer" onClick={() => removeBookmark(selectedPost.id)}>
                  <img src={BOOKMARK_TRUE} alt="bookmark" className="w-6 h-6" />
                </div>
              </div>

              <div className="flex gap-2 mb-4">
                <input
                  type="text"
                  className="w-full border rounded-lg px-3 py-2 text-black focus:outline-none focus:ring-2 focus:ring-gray-400"
                  placeholder="Write a comment..."
                  value={commentInputs[selectedPost.id] || ""}
                  onChange={e => setCommentInputs(prev => ({ ...prev, [selectedPost.id]: e.target.value }))}
                  onKeyDown={e => { if (e.key === "Enter") handleAddComment(selectedPost.id); }}
                />
                <button onClick={() => handleAddComment(selectedPost.id)} className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">Send</button>
              </div>

              <div className="flex-1 overflow-y-auto border-t pt-2">
                {(commentsState[selectedPost.id] || []).map((c, idx) => (
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
};

const DesignCard = ({ design, onClick }) => (
  <div 
    onClick={onClick}
    className="bg-white rounded-2xl overflow-hidden shadow-lg hover:shadow-2xl hover:scale-105 transition-all cursor-pointer"
  >
    <div className="aspect-[3/4] bg-gray-100 overflow-hidden">
      <img 
        src={design.image} 
        alt={design.title}
        className="w-full h-full object-cover"
      />
    </div>
    <div className="p-4">
      <h3 className="font-semibold text-gray-800 text-center">{design.title}</h3>
    </div>
  </div>
);

const ExpandedView = ({ design, onClose }) => (
  <div className="max-w-7xl mx-auto p-8 animate-fadeIn">
    <button
      onClick={onClose}
      className="mb-6 flex items-center gap-2 px-4 py-2 bg-white bg-opacity-50 hover:bg-opacity-70 rounded-lg transition-colors"
    >
      <X className="w-5 h-5" />
      <span className="font-semibold">Close</span>
    </button>
    
    <div className="grid grid-cols-2 gap-8">
      {/* Image Section */}
      <div className="bg-white rounded-3xl overflow-hidden shadow-2xl">
        <img 
          src={design.image} 
          alt={design.title}
          className="w-full h-full object-cover"
        />
      </div>

      {/* Details Section */}
      <div className="space-y-6">
        <div className="bg-white rounded-3xl p-8 shadow-xl">
          <h2 className="text-3xl font-bold text-gray-800 mb-4">{design.title}</h2>
          <p className="text-gray-600 text-lg mb-6">{design.description}</p>
          
          <div className="space-y-4">
            <div className="flex justify-between items-center py-3 border-b border-gray-200">
              <span className="font-semibold text-gray-700">Category:</span>
              <span className="text-gray-600">Apparel</span>
            </div>
            <div className="flex justify-between items-center py-3 border-b border-gray-200">
              <span className="font-semibold text-gray-700">Collection:</span>
              <span className="text-gray-600">2024 Season</span>
            </div>
            <div className="flex justify-between items-center py-3 border-b border-gray-200">
              <span className="font-semibold text-gray-700">Saved Date:</span>
              <span className="text-gray-600">Nov 7, 2025</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-3xl p-8 shadow-xl">
          <h3 className="text-xl font-bold text-gray-800 mb-4">Design Notes</h3>
          <p className="text-gray-600">
            This design represents a perfect blend of elegance and modern style. 
            The attention to detail and craftsmanship makes it a standout piece 
            in the collection.
          </p>
        </div>

        <div className="flex gap-4">
          <button className="flex-1 bg-gradient-to-r from-pink-400 to-rose-400 text-white font-semibold py-4 rounded-xl hover:shadow-lg transition-all">
            View Full Collection
          </button>
          <button className="flex-1 bg-white text-gray-800 font-semibold py-4 rounded-xl hover:shadow-lg transition-all">
            Share Design
          </button>
        </div>
      </div>
    </div>
  </div>
);

export default GlamureBookmarks;