import React, { useState } from "react";
import CreatePost from "./CreatePost";
import PostFeed from "./PostFeed";
import TagSearchBar from "./TagSearchBar";
import Leaderboard from "./leaderboard-modules/leaderboard";


export default function Homepage() {
  const [showPostModal, setShowPostModal] = useState(false);
  const [posts, setPosts] = useState([]);
  const [filteredPosts, setFilteredPosts] = useState([]);
  const [showLeaderboard, setShowLeaderboard] = useState(false); // <-- new state

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

  // Render Leaderboard or default homepage
  if (showLeaderboard) {
    return <Leaderboard goBack={() => setShowLeaderboard(false)} />;
  }

  return (
    <div className="w-full h-full relative flex flex-col gap-10 items-center bg-red-100 pt-6">
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
              className="w-10 h-10 object-cover rounded mb-2 transition-transform duration-200 hover:scale-105"
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
            className="w-10 h-10 object-cover rounded mb-2 transition-transform duration-200 hover:scale-105"
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
