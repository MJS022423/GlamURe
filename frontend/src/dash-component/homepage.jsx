import React, { useState, useRef, useEffect } from "react";

// Tag component
const Tag = ({ label, removable, onRemove }) => {
  const map = {
    Men: "bg-blue-600/20 text-blue-300",
    Women: "bg-pink-600/20 text-pink-300",
    Unisex: "bg-slate-600/20 text-slate-300",
    "Old Money": "bg-amber-600/20 text-amber-300",
    Goth: "bg-violet-700/20 text-violet-300",
    Casual: "bg-green-600/20 text-green-300"
  };
  const classes = map[label] || "bg-slate-600/10 text-slate-300";
  return (
    <div className={`inline-flex items-center text-xs font-medium px-3 py-1 rounded-full ${classes} border border-slate-700/50`}>
      <span>{label}</span>
      {removable && (
        <button onClick={onRemove} className="ml-2 text-slate-300 hover:text-white font-bold">
          ✖
        </button>
      )}
    </div>
  );
};

// Utility to display "time ago"
const timeAgo = (timestamp) => {
  const diff = Math.floor((Date.now() - timestamp) / 1000);
  if (diff < 60) return `${diff}s ago`;
  if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
  if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
  return `${Math.floor(diff / 86400)}d ago`;
};

const sampleTags = ["Old Money", "Men", "Women", "Unisex", "Casual", "Goth"];

const Homepage = () => {
  const [posts, setPosts] = useState([]);
  const [newPost, setNewPost] = useState({ description: "", images: [], tags: [] });
  const [isCreatingPost, setIsCreatingPost] = useState(false);
  const [showTagList, setShowTagList] = useState(false);
  const [expandedPost, setExpandedPost] = useState(null);
  const [commentInputs, setCommentInputs] = useState({});
  const [carouselIndex, setCarouselIndex] = useState(0);

  const fileInputRef = useRef();

  // Fetch posts from backend JSON
  useEffect(() => {
    fetch("http://localhost:5000/api/posts")
      .then(res => res.json())
      .then(data => {
        const formatted = data.map(p => ({ ...p, likes: new Set(p.likes || []) }));
        setPosts(formatted);
      });
  }, []);

  // Handle adding images
  const handleAddImages = (e) => {
    const files = Array.from(e.target.files || []);
    const urls = files.map(f => URL.createObjectURL(f));
    setNewPost(prev => ({ ...prev, images: [...prev.images, ...urls] }));
  };

  // Handle creating a post
  const handleCreatePost = async () => {
    if (!newPost.description && newPost.images.length === 0) return;

    const postData = {
      id: Date.now(), // unique id for React key
      username: "You",
      profilePic: "https://via.placeholder.com/40",
      images: newPost.images.length ? newPost.images : ["https://via.placeholder.com/400"],
      description: newPost.description,
      tags: newPost.tags.length ? newPost.tags : ["Unisex"],
      likes: new Set(),
      commentsList: [],
      createdAt: Date.now()
    };

    // Immediately update UI
    setPosts(prev => [postData, ...prev]);

    // Optional: send to backend
    try {
      await fetch("http://localhost:5000/api/posts", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ...postData, likes: [], commentsList: [] })
      });
    } catch (err) {
      console.error(err);
    }

    setNewPost({ description: "", images: [], tags: [] });
    setIsCreatingPost(false);
  };

  const handleToggleLike = (postId, userId = "current") => {
    setPosts(posts.map(p => {
      if (p.id !== postId) return p;
      const likes = new Set(p.likes);
      likes.has(userId) ? likes.delete(userId) : likes.add(userId);
      return { ...p, likes };
    }));
  };

  const handleAddTag = (tag) => {
    if (!newPost.tags.includes(tag)) setNewPost(prev => ({ ...prev, tags: [...prev.tags, tag] }));
  };

  const handleRemoveTag = (tag) => {
    setNewPost(prev => ({ ...prev, tags: prev.tags.filter(t => t !== tag) }));
  };

  const handleAddComment = (postId) => {
    const text = (commentInputs[postId] || "").trim();
    if (!text) return;
    setPosts(posts.map(p => {
      if (p.id !== postId) return p;
      return {
        ...p,
        commentsList: [...p.commentsList, { id: Date.now(), user: "You", avatar: "https://via.placeholder.com/30", text }]
      };
    }));
    setCommentInputs({ ...commentInputs, [postId]: "" });
  };

  const nextImage = () => {
    if (!expandedPost) return;
    setCarouselIndex((carouselIndex + 1) % expandedPost.images.length);
  };

  const prevImage = () => {
    if (!expandedPost) return;
    setCarouselIndex((carouselIndex - 1 + expandedPost.images.length) % expandedPost.images.length);
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 py-8 px-4">
      <div className="max-w-2xl mx-auto space-y-6">

        {/* Create Post */}
        <div className="bg-slate-800 border border-slate-700 rounded-xl p-4 shadow-md relative">
          {!isCreatingPost ? (
            <div onClick={() => setIsCreatingPost(true)} className="flex items-center gap-3 cursor-pointer px-3 py-3 rounded-lg bg-slate-800 hover:bg-slate-800/80">
              <img src="https://via.placeholder.com/40" alt="you" className="w-10 h-10 rounded-full"/>
              <div className="flex-1 text-slate-400">What’s on your mind?</div>
            </div>
          ) : (
            <>
              <button onClick={() => { setIsCreatingPost(false); setNewPost({ description: "", images: [], tags: [] }); }}
                className="absolute top-3 right-3 text-slate-300 hover:text-white p-1 rounded hover:bg-slate-700/50">✖</button>
              <textarea
                rows={3}
                value={newPost.description}
                onChange={e => setNewPost(prev => ({ ...prev, description: e.target.value }))}
                placeholder="Share something..."
                className="w-full resize-none p-3 rounded-lg bg-slate-800 border border-slate-700 focus:ring-2 focus:ring-indigo-600 mb-3"
              />
              <input type="file" multiple ref={fileInputRef} className="hidden" onChange={handleAddImages} />
              <button onClick={() => fileInputRef.current.click()} className="px-3 py-2 bg-slate-700 rounded-lg hover:bg-slate-600 mb-2">＋ Add Images</button>
              <div className="flex flex-wrap gap-2 mb-2">
                {newPost.images.map((img, i) => <img key={i} src={img} alt="preview" className="w-24 h-24 object-cover rounded-lg" />)}
              </div>
              <button onClick={() => setShowTagList(prev => !prev)} className="px-3 py-2 bg-slate-700 rounded-lg hover:bg-slate-600 mb-2">
                {showTagList ? "− Minimize Tags" : "➕ Add Tags"}
              </button>
              {showTagList && (
                <div className="flex flex-wrap gap-2 mb-2">
                  {sampleTags.map(tag => <button key={tag} onClick={() => handleAddTag(tag)} className="px-3 py-1 bg-slate-700 rounded-lg hover:bg-indigo-600">{tag}</button>)}
                </div>
              )}
              <div className="flex flex-wrap gap-2 mb-2">
                {newPost.tags.map((t, i) => <Tag key={i} label={t} removable onRemove={() => handleRemoveTag(t)} />)}
              </div>
              <button onClick={handleCreatePost} className="px-4 py-2 bg-indigo-600 rounded-lg hover:bg-indigo-700 text-white">
                Post
              </button>
            </>
          )}
        </div>

        {/* Posts Feed */}
        <div className="space-y-6">
          {posts.map(post => (
            <div key={post.id} className="bg-slate-800 border border-slate-700 rounded-xl shadow-md overflow-hidden cursor-pointer"
              onClick={() => { setExpandedPost(post); setCarouselIndex(0); }}
            >
              <div className="flex items-center gap-3 px-4 py-3 border-b border-slate-700">
                <img src={post.profilePic} alt={post.username} className="w-10 h-10 rounded-full"/>
                <div className="flex-1">
                  <div className="font-semibold">{post.username}</div>
                  <div className="text-xs text-slate-400">{timeAgo(post.createdAt)}</div>
                </div>
              </div>

              <div className={`grid gap-1 ${post.images.length === 1 ? "grid-cols-1" : post.images.length === 2 ? "grid-cols-2" : "grid-cols-2 grid-rows-2"}`}>
                {post.images.map((img, i) => (
                  <img key={i} src={img} alt="post" className="w-full h-48 object-cover"/>
                ))}
              </div>

              {post.description && <div className="px-4 py-3">{post.description}</div>}
              <div className="px-4 pb-3 flex flex-wrap gap-2">
                {post.tags.map((t, i) => <Tag key={i} label={t} />)}
              </div>

              <div className="px-4 py-3 border-t border-slate-700 flex items-center gap-6">
                <button onClick={(e) => { e.stopPropagation(); handleToggleLike(post.id); }}
                  className="flex items-center gap-2 text-lg">
                  <span className={post.likes.has("current") ? "text-red-500" : "text-slate-300"}>
                    {post.likes.has("current") ? "❤️" : "🤍"}
                  </span>
                  <span>{post.likes.size}</span>
                </button>
                <span className="flex items-center gap-2 text-lg text-slate-300">💬 {post.commentsList.length}</span>
              </div>
            </div>
          ))}
        </div>

        {/* Expanded Post Modal */}
        {expandedPost && (
          <div className="fixed inset-0 z-50 flex bg-black/70 justify-center items-center">
            <div className="bg-slate-900 rounded-xl flex max-w-5xl w-full max-h-[90vh] overflow-hidden">
              <div className="relative flex-1 bg-black flex items-center justify-center">
                <img src={expandedPost.images[carouselIndex]} alt="expanded" className="w-full h-full object-contain"/>
                {expandedPost.images.length > 1 && (
                  <>
                    <button onClick={prevImage} className="absolute left-2 text-white text-2xl bg-black/40 rounded-full px-2">‹</button>
                    <button onClick={nextImage} className="absolute right-2 text-white text-2xl bg-black/40 rounded-full px-2">›</button>
                  </>
                )}
              </div>
              <div className="flex flex-col flex-1 p-4 overflow-y-auto">
                <button onClick={() => setExpandedPost(null)} className="self-end text-white mb-2">✖</button>
                <div className="flex items-center gap-3 mb-4">
                  <img src={expandedPost.profilePic} alt={expandedPost.username} className="w-10 h-10 rounded-full"/>
                  <div>
                    <div className="font-semibold">{expandedPost.username}</div>
                    <div className="text-xs text-slate-400">{timeAgo(expandedPost.createdAt)}</div>
                  </div>
                </div>
                {expandedPost.description && <div className="mb-3">{expandedPost.description}</div>}
                <div className="flex flex-wrap gap-2 mb-3">
                  {expandedPost.tags.map((t, i) => <Tag key={i} label={t} />)}
                </div>
                <div className="flex items-center gap-4 mb-3">
                  <button onClick={() => handleToggleLike(expandedPost.id)} className="flex items-center gap-2">
                    <span className={expandedPost.likes.has("current") ? "text-red-500" : "text-slate-300"}>
                      {expandedPost.likes.has("current") ? "❤️" : "🤍"}
                    </span>
                    <span>{expandedPost.likes.size}</span>
                  </button>
                  <span className="text-slate-300">💬 {expandedPost.commentsList.length}</span>
                </div>
                <div className="space-y-3 flex-1 overflow-y-auto">
                  {expandedPost.commentsList.map(c => (
                    <div key={c.id} className="flex items-start gap-3">
                      <img src={c.avatar} alt={c.user} className="w-8 h-8 rounded-full mt-1"/>
                      <div className="bg-slate-800 border border-slate-700 rounded-lg p-3">
                        <div className="text-sm font-semibold">{c.user}</div>
                        <div className="text-sm text-slate-300">{c.text}</div>
                      </div>
                    </div>
                  ))}
                </div>
                <div className="flex gap-2 mt-2">
                  <input
                    value={commentInputs[expandedPost.id] || ""}
                    onChange={e => setCommentInputs(prev => ({ ...prev, [expandedPost.id]: e.target.value }))}
                    className="flex-1 px-3 py-2 rounded-lg bg-slate-800 border border-slate-700 text-slate-100"
                    placeholder="Write a comment..."
                  />
                  <button onClick={() => handleAddComment(expandedPost.id)} className="px-3 py-2 bg-indigo-600 rounded-lg hover:bg-indigo-700 text-white">📤</button>
                </div>
              </div>
            </div>
          </div>
        )}

      </div>
    </div>
  );
};

export default Homepage;
