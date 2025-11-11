import React, { useState, useEffect, useCallback } from "react";
import CreatePost from "./CreatePost";
import PostFeed from "./PostFeed";
import TagSearchBar from "./TagSearchBar";
import Leaderboard from "./leaderboard-modules/leaderboard";


const EXPRESS_API = import.meta.env.VITE_EXPRESS_API;

export default function Homepage() {
  const [showPostModal, setShowPostModal] = useState(false);
  const [posts, setPosts] = useState([]);
  const [filteredPosts, setFilteredPosts] = useState([]);
  const [showLeaderboard, setShowLeaderboard] = useState(false);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);

  const fetchPosts = useCallback(async (pageNum = 1, append = false) => {
    try {
      setLoading(true);
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

      if (append) {
        setPosts(prev => [...prev, ...formattedPosts]);
        setFilteredPosts(prev => [...prev, ...formattedPosts]);
      } else {
        setPosts(formattedPosts);
        setFilteredPosts(formattedPosts);
      }

      if (formattedPosts.length < 30) {
        setHasMore(false);
      }
    } catch (err) {
      console.error("Failed to load posts:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchPosts(1, false);
  }, [fetchPosts]);

  const loadMore = useCallback(() => {
    if (!loading && hasMore) {
      const nextPage = page + 1;
      setPage(nextPage);
      fetchPosts(nextPage, true);
    }
  }, [loading, hasMore, page, fetchPosts]);

  const handleScroll = useCallback((e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.target;
    const threshold = 5; // Load more when within 5 posts of the bottom
    const postHeight = 320; // Approximate height of each post card
    const thresholdPixels = threshold * postHeight;

    if (scrollTop + clientHeight >= scrollHeight - thresholdPixels) {
      loadMore();
    }
  }, [loadMore]);

  const handleAddPost = (newPost) => {
    setPosts(prev => [newPost, ...prev]);
    setFilteredPosts(prev => [newPost, ...prev]);
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
      <div className="mt-30 overflow-y-auto no-scrollbar h-[100%]" onScroll={handleScroll}>
        <style jsx>{`
          .no-scrollbar::-webkit-scrollbar {
            display: none;
          }
          .no-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
          }
        `}</style>
        <PostFeed posts={filteredPosts.length ? filteredPosts : posts} />
      </div>

      {/* CreatePost modal */}
      {showPostModal && (
        <CreatePost onClose={() => setShowPostModal(false)} addPost={handleAddPost} />
      )}
    </div>
  );
}
