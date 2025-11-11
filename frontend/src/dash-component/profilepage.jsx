import React, { useState, useEffect } from "react";
import CreatePost from "./homepage-modules/CreatePost";
import PostFeed from "./homepage-modules/PostFeed";
import TagSearchBar from "./homepage-modules/TagSearchBar";
import Leaderboard from "./homepage-modules/leaderboard-modules/leaderboard";

const EXPRESS_API = import.meta.env.VITE_EXPRESS_API;

export default function ProfilePage() {
  const [showPostModal, setShowPostModal] = useState(false);
  const [posts, setPosts] = useState([]);
  const [filteredPosts, setFilteredPosts] = useState([]);
  const [showLeaderboard, setShowLeaderboard] = useState(false);
  const [userProfile, setUserProfile] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchUserPosts = async () => {
      try {
        const userid = localStorage.getItem('userid');
        const res = await fetch(`${EXPRESS_API}/post/Displaypost`);
        const data = await res.json();

        if (!data.success) throw new Error(data.error || "Failed to fetch posts");

        const userPosts = data.results.filter(post => post.userId === userid);

        const formattedPosts = userPosts.map(post => ({
          id: post.id,
          username: post.username || "Unknown User",
          description: post.caption || "",
          images: post.images || [],
          tags: post.tags || [],
          gender: post.gender || "Unisex",
          style: post.style || "Casual",
          likes: post.likes || 0,
        }));

        setPosts(formattedPosts);
        setFilteredPosts(formattedPosts);
      } catch (err) {
        console.error("Failed to load posts:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchUserPosts();
  }, []);

  const handleAddPost = (newPost) => {
    setPosts(prev => [newPost, ...prev]);
    setFilteredPosts(prev => [newPost, ...prev]);
    setShowPostModal(false);
  };

  const handleTagSearch = (selectedTags) => {
    if (!selectedTags || selectedTags.length === 0) {
      setFilteredPosts(posts);
      return;
    }
    const filtered = posts.filter(post =>
      post.tags.some(tag => selectedTags.includes(tag))
    );
    setFilteredPosts(filtered);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-b from-[#1b1b1b] via-[#2b2b2b] to-[#f9c5d1] flex items-center justify-center">
        <div className="text-white text-xl">Loading your profile...</div>
      </div>
    );
  }

  return (
    <div className="w-full h-full relative flex flex-col gap-10 items-center bg-gradient-to-b from-[#1b1b1b] via-[#2b2b2b] to-[#f9c5d1] pt-6">
      {/* Profile Header */}
      <div className="w-full max-w-4xl px-8 mt-8">
        <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8 text-center">
          <div className="w-24 h-24 bg-gradient-to-br from-pink-400 to-rose-400 rounded-full mx-auto mb-4 flex items-center justify-center text-3xl font-bold text-white">
            👤
          </div>
          <h1 className="text-3xl font-bold text-white mb-2">Your Profile</h1>
          <p className="text-pink-200">Welcome back! Here are your designs.</p>
        </div>
      </div>

      {/* Search and icons */}
      <div className="flex flex-row fixed items-center justify-between w-full max-w-4xl mt-1 z-20">
        <div className="flex-1 flex items-center">
          <TagSearchBar onSearch={handleTagSearch} />
        </div>

        <div className="flex items-center gap-20">
          {/* Create Post button */}
          <button
            onClick={() => setShowPostModal(true)}
            className="rounded-full w-10 h-10 transition-transform duration-200 hover:scale-105"
          >
            <img
              src="https://www.svgrepo.com/show/521942/add-ellipse.svg"
              alt="Add Post"
              className="w-10 h-10 object-cover rounded mb-2 transition-transform duration-200 hover:scale-105 filter invert"
            />
          </button>

          {/* Leaderboard icon */}
          <button
            onClick={() => setShowLeaderboard(true)}
            className="rounded-full w-10 h-10 transition-transform duration-200 hover:scale-105"
          >
            <img
              src="https://www.svgrepo.com/show/487506/leaderboard.svg"
              alt="Leaderboard"
              className="w-10 h-10 object-cover rounded mb-2 transition-transform duration-200 hover:scale-105 filter invert"
            />
          </button>
        </div>
      </div>

      {/* Post feed */}
      <PostFeed posts={filteredPosts.length ? filteredPosts : posts} variant="profile" />

      {/* CreatePost modal */}
      {showPostModal && (
        <CreatePost onClose={() => setShowPostModal(false)} addPost={handleAddPost} />
      )}

      {/* Leaderboard modal */}
      {showLeaderboard && (
        <Leaderboard goBack={() => setShowLeaderboard(false)} />
      )}
    </div>
  );
}
