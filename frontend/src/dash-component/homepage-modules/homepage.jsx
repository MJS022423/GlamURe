import React, { useState } from "react";
import CreatePost from "./CreatePost";
import PostFeed from "./PostFeed";

export default function Homepage() {
  const [showPostModal, setShowPostModal] = useState(false);
  const [posts, setPosts] = useState([]);

  // Callback when a new post is uploaded
  const handleAddPost = (newPost) => {
    setPosts((prevPosts) => [newPost, ...prevPosts]); // prepend new post
    setShowPostModal(false); // close modal
  };

  return (
    <div className="w-full h-full relative flex flex-col gap-10 items-center bg-red-100 pt-6">
      {/* Search and icons */}
      <div className="flex flex-row fixed items-center justify-between w-full max-w-4xl mt-1 z-20">
        <div className="flex-1 flex items-center">
          <input
            type="text"
            placeholder="Search"
            className="rounded-lg px-4 py-2 w-full max-w-lg text-black"
          />
          <button className="ml-2 text-black text-2xl">&#10006;</button>
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

          {/* Other icons */}
          <button className="text-black text-2xl">🏆</button>
          <button className="text-black text-2xl">🔔</button>
        </div>
      </div>

      {/* Post feed */}
      <PostFeed posts={posts} />

      {/* CreatePost modal */}
      {showPostModal && (
        <CreatePost onClose={() => setShowPostModal(false)} addPost={handleAddPost} />
      )}
    </div>
  );
}
