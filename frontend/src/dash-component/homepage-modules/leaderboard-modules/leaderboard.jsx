// homepage-modules/leaderboard-modules/Leaderboard.jsx
import React, { useMemo, useState } from "react";

export default function Leaderboard({ goBack }) {
  const leaderboardData = [
    { name: "User A", likes: 500, category: "Casual" },
    { name: "User B", likes: 450, category: "Formal" },
    { name: "User C", likes: 400, category: "Streetwear" },
    { name: "User D", likes: 370, category: "Casual" },
    { name: "User E", likes: 350, category: "Luxury" },
    { name: "User F", likes: 320, category: "Streetwear" },
    { name: "User G", likes: 310, category: "Casual" },
  ];

  const [searchTerm, setSearchTerm] = useState("");
  const [activeCategory, setActiveCategory] = useState("All");

  const categories = useMemo(
    () => ["All", ...Array.from(new Set(leaderboardData.map(({ category }) => category)))],
    []
  );

  const filteredLeaderboard = useMemo(() => {
    const lowerSearch = searchTerm.toLowerCase();
    return leaderboardData
      .filter(
        (user) =>
          (activeCategory === "All" || user.category === activeCategory) &&
          user.name.toLowerCase().includes(lowerSearch)
      )
      .sort((a, b) => b.likes - a.likes);
  }, [leaderboardData, searchTerm, activeCategory]);

  return (
    <div className="w-full min-h-screen flex flex-col items-center justify-start pt-12 bg-pink-50 text-gray-900">
      {/* Header */}
      <div className="w-full max-w-4xl flex flex-col gap-6 px-6 mb-10">
        <div className="flex justify-between items-center gap-4">
          <h1 className="text-4xl font-extrabold text-pink-600 tracking-wide">
            Leaderboard
          </h1>
          <button
            onClick={goBack}
            className="text-lg px-4 py-2 rounded-full bg-pink-200 text-pink-900 hover:bg-pink-300 hover:scale-105 transition-transform duration-300 shadow-md"
          >
            ← Back
          </button>
        </div>

        <div className="flex flex-col lg:flex-row gap-4 items-center">
          <input
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full lg:flex-1 rounded-full border border-pink-200 px-5 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-pink-400"
            type="search"
            placeholder="Search designers..."
          />
          <div className="flex flex-wrap gap-2 justify-center lg:justify-start">
            {categories.map((category) => (
              <button
                key={category}
                onClick={() => setActiveCategory(category)}
                className={`px-4 py-2 rounded-full text-sm font-semibold transition-transform duration-200 shadow-sm ${
                  activeCategory === category
                    ? "bg-pink-500 text-white scale-105"
                    : "bg-white text-pink-600 border border-pink-200 hover:bg-pink-100"
                }`}
              >
                {category}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Leaderboard Card */}
      <div className="w-full max-w-4xl bg-white rounded-2xl shadow-2xl p-8 border border-pink-200">
        {filteredLeaderboard.length === 0 ? (
          <p className="text-center text-gray-500">No designers match your filters.</p>
        ) : (
          filteredLeaderboard.map((user, index) => (
            <div
              key={user.name + user.category}
              className={`flex justify-between items-center py-3 px-6 rounded-xl mb-3 transition-all duration-300 ${
                index === 0
                  ? "bg-pink-100 text-pink-700 font-semibold shadow-inner"
                  : "hover:bg-pink-50"
              }`}
            >
              <div className="flex flex-col">
                <span className="text-lg font-medium">
                  {index + 1}. {user.name}
                </span>
                <span className="text-sm text-pink-500">{user.category}</span>
              </div>
              <span className="text-lg font-semibold text-pink-600 flex items-center gap-2">
                <span className="text-2xl">❤</span>
                {user.likes} likes
              </span>
            </div>
          ))
        )}

        <p className="text-gray-500 text-center mt-6 italic">
          ...more users coming soon
        </p>
      </div>
    </div>
  );
}

