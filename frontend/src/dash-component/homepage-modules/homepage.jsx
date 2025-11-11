import React, { useState, useEffect } from "react";
import CreatePost from "./CreatePost";
import PostFeed from "./PostFeed";
import TagSearchBar from "./TagSearchBar";
import Leaderboard from "./leaderboard-modules/leaderboard";


const EXPRESS_API = import.meta.env.VITE_EXPRESS_API;

export default function Homepage() {
  const [showPostModal, setShowPostModal] = useState(false);
  const [posts, setPosts] = useState([]);
  const [filteredPosts, setFilteredPosts] = useState([]);
  const [showLeaderboard, setShowLeaderboard] = useState(false); // <-- new state

  useEffect(() => {
    const fetchPosts = async () => {
      try {
        const res = await fetch(`${EXPRESS_API}/post/Displaypost`);
        const data = await res.json();

        if (!data.success) throw new Error(data.error || "Failed to fetch posts");

        const formattedPosts = data.results.map(post => ({
          id: post.id, // comes from backend Post_id
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
      }
    };

    fetchPosts();
  }, []);


  const handleAddPost = (newPost) => {
    setPosts(prev => [newPost, ...prev]);
    setFilteredPosts(prev => [newPost, ...prev]);
    setShowPostModal(true);
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

  // Render Leaderboard or default homepage
  if (showLeaderboard) {
    return <Leaderboard goBack={() => setShowLeaderboard(false)} />;
  }

  return (
    <div className="w-full h-full relative flex flex-col gap-10 items-center bg-gradient-to-b from-[#1b1b1b] via-[#2b2b2b] to-[#f9c5d1] pt-6">
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
      <PostFeed posts={filteredPosts.length ? filteredPosts : posts} />

      {/* CreatePost modal */}
      {showPostModal && (
        <CreatePost onClose={() => setShowPostModal(false)} addPost={handleAddPost} />
      )}
    </div>
  );
}
