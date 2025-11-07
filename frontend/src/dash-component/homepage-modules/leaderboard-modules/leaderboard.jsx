// homepage-modules/leaderboard-modules/Leaderboard.jsx
import React from "react";

export default function Leaderboard({ goBack }) {
  return (
    <div className="w-full h-full flex flex-col items-center justify-start pt-10 bg-yellow-100">
      <div className="w-full max-w-4xl flex justify-between items-center px-6 mb-6">
        <h1 className="text-2xl font-bold">Leaderboard</h1>
        <button
          onClick={goBack}
          className="text-xl px-3 py-1 rounded-full bg-gray-200 hover:bg-gray-300 hover:scale-105 transition-transform duration-200"
        >
          ← Back
        </button>
      </div>

      {/* Sample leaderboard content */}
      <div className="w-full max-w-4xl bg-white rounded-xl shadow-lg p-6">
        <p className="text-gray-700 mb-2">1. User A - 500 points</p>
        <p className="text-gray-700 mb-2">2. User B - 450 points</p>
        <p className="text-gray-700 mb-2">3. User C - 400 points</p>
        <p className="text-gray-500">...more users</p>
      </div>
    </div>
  );
}
